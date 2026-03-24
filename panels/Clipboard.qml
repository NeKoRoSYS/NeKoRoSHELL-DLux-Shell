// panels/Clipboard.qml
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.global
import qs.components

Panel {
    id: clipboardPanel

    edgePadding: 15
    panelWidth:  500
    panelHeight: 500
    animationPreset: "slide"
    anchorAlignment: "center"
    keyboardFocus: WlrKeyboardFocus.OnDemand

    Rectangle {
        id: clipRoot
        anchors.fill: parent
        color: "transparent"
        border.color: Colors.color13
        border.width: 2
        radius: 10
        clip: true

        property string currentTab: "history"  
        property string backendScript: Quickshell.env("HOME") + "/.config/quickshell/scripts/cliphist.py"

        ListModel { id: clipModel }

        property var favoriteArray: []

        FileView {
            id: favFile
            path: Quickshell.env("HOME") + "/.config/quickshell/clipboard_favorites.json"
            watchChanges: true
            onFileChanged: reload()
            onLoaded: {
                let content = favFile.text()
                if (!content || content.trim().length === 0) {
                    clipRoot.favoriteArray = []
                    return
                }
                try {
                    clipRoot.favoriteArray = JSON.parse(content)
                } catch(e) {
                    clipRoot.favoriteArray = []
                }
            }
        }

        Process {
            id: fetchProcess
            property string mode: "list-history"
            command: ["python3", clipRoot.backendScript, mode]
            running: false
            
            stdout: SplitParser {
                onRead: data => {
                    if (data.trim() !== "") {
                        try {
                            let obj = JSON.parse(data);
                            clipModel.append({ 
                                "clipId": obj.id,
                                "clipText": obj.preview 
                            })
                        } catch(e) {}
                    }
                }
            }
        }

        Connections {
            target: clipboardPanel
            function onShowPanelChanged() {
                if (clipboardPanel.showPanel) {
                    clipRoot.refreshData()
                }
            }
        }

        Timer {
            id: refreshDelay
            interval: 150
            onTriggered: clipRoot.refreshData()
        }

        function refreshData() {
            clipModel.clear()
            fetchProcess.mode = (clipRoot.currentTab === "history") ? "list-history" : "list-favs"
            fetchProcess.running = true
        }

        Component.onCompleted: {
            refreshData()
        }

        function executeAction(action, arg) {
            Quickshell.execDetached({ command: ["python3", clipRoot.backendScript, action, arg] })
            if (action === "wipe" || action === "rm-hist" || action === "rm-fav" || action === "rm-fav-hist") {
                refreshDelay.restart()
            }
        }

        Column {
            anchors.fill: parent
            anchors.margins: 15
            spacing: 10

            Item {
                width:  parent.width
                height: 36

                Row {
                    anchors.centerIn: parent
                    spacing: 8

                    Repeater {
                        model: ["History", "Favorites"]
                        delegate: Rectangle {
                            required property string modelData

                            width:  100
                            height: 30
                            radius: 15
                            
                            readonly property bool isActive: clipRoot.currentTab === modelData.toLowerCase()
                            
                            color:  isActive ? Colors.color7 : Colors.color0
                            Behavior on color { ColorAnimation { duration: 150 } }

                            Text {
                                anchors.centerIn: parent
                                text:        parent.modelData
                                color:       parent.isActive ? Colors.background : Colors.foreground
                                font.family: Style.barFont
                                font.pixelSize: 12
                                font.weight: Font.Bold
                                Behavior on color { ColorAnimation { duration: 150 } }
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape:  Qt.PointingHandCursor
                                onClicked: {
                                    clipRoot.currentTab = parent.modelData.toLowerCase()
                                    clipRoot.refreshData()
                                }
                            }
                        }
                    }
                }
            }

            Rectangle { width: parent.width; height: 1; color: Colors.color8; opacity: 0.5 }

            ListView {
                id: clipList
                width: parent.width
                height: parent.height - 95
                clip: true
                spacing: 5
                model: clipModel

                delegate: Rectangle {
                    id: delegateRoot
                    width: clipList.width
                    height: 45
                    radius: 5
                    color: clipMouse.containsMouse ? Colors.color13 : "transparent"

                    property string clipId: model.rawText.indexOf('\t') !== -1 ? model.rawText.substring(0, model.rawText.indexOf('\t')) : ""
                    property string clipText: clipRoot.currentTab === "history" ? model.rawText.substring(model.rawText.indexOf('\t') + 1) : model.rawText

                    MouseArea {
                        id: clipMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        acceptedButtons: Qt.LeftButton | Qt.RightButton
                        cursorShape: Qt.PointingHandCursor
                        
                        onClicked: (mouse) => {
                            if (mouse.button === Qt.RightButton) {
                                let action = (clipRoot.currentTab === "history") ? "rm-hist" : "rm-fav"
                                clipRoot.executeAction(action, model.clipId)
                            } else {
                                let action = (clipRoot.currentTab === "history") ? "copy-hist" : "copy-fav"
                                clipRoot.executeAction(action, model.clipId)
                                EventBus.togglePanel("clipboard")
                            }
                        }
                    }

                    Row {
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 10

                        Text {
                            text: model.clipText
                            color: Colors.foreground
                            font.family: "JetBrains Mono"
                            font.pixelSize: 13
                            elide: Text.ElideRight
                            width: parent.width - 40
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        
                        Item {
                            width: 30
                            height: parent.height
                            anchors.verticalCenter: parent.verticalCenter
                            
                            property bool isFav: {
                                if (clipRoot.currentTab === "favorites") return true;
                                return clipRoot.favoriteArray.some(fav => fav.preview === model.clipText);
                            }

                            Text {
                                text: clipRoot.currentTab === "history" ? (parent.isFav ? "⭐" : "☆") : "❌"
                                font.pixelSize: 16
                                color: Colors.foreground
                                anchors.centerIn: parent
                            }
                            
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (clipRoot.currentTab === "history") {
                                        let action = parent.isFav ? "rm-fav-hist" : "add-fav"
                                        clipRoot.executeAction(action, model.clipId)
                                    } else {
                                        clipRoot.executeAction("rm-fav", model.clipId)
                                    }
                                }
                            }
                        }
                    }
                }
            }

            Rectangle {
                width: parent.width
                height: 30
                radius: 15
                visible: clipRoot.currentTab === "history"
                
                color: clearMouse.containsMouse ? Colors.foreground : Colors.color0
                Behavior on color { ColorAnimation { duration: 150 } }
                
                Text {
                    anchors.centerIn: parent
                    text: "Clear History"
                    color: clearMouse.containsMouse ? Colors.background : Colors.foreground
                    font.family: Style.barFont
                    font.pixelSize: 12
                    font.weight: Font.Bold
                    Behavior on color { ColorAnimation { duration: 150 } }
                }
                
                MouseArea {
                    id: clearMouse
                    anchors.fill: parent
                    hoverEnabled: true 
                    cursorShape: Qt.PointingHandCursor
                    onClicked: clipRoot.executeAction("wipe", "")
                }
            }
        }
    }
}