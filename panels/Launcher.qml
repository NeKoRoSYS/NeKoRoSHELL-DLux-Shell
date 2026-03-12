// panels/Launcher.qml
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.globals
import qs.components

Panel {
    id: launcherPanel

    edgePadding: 15
    panelWidth:  500
    panelHeight: 520
    animationPreset: "slide"
    anchorAlignment: "center"
    keyboardFocus: WlrKeyboardFocus.Exclusive

    Rectangle {
        id: launcherRoot
        anchors.fill: parent
        color: Colors.background
        border.color: Colors.color13
        border.width: 2
        radius: 10
        clip: true

        property string searchQuery: ""
        property var allAppsRaw: [] 
        property int selectedIndex: 0

        onSearchQueryChanged: updateSearch()

        ListModel {
            id: appsModel
        }

        Process {
            id: appsProcess
            running: true
            command: ["sh", "-c", "python3 ~/.config/quickshell/scripts/get-apps.py"]
        }

        FileView {
            id: appsFile
            path: Quickshell.env("HOME") + "/.cache/quickshell/apps.json"
            watchChanges: true
            onFileChanged: reload()
            onLoaded: launcherRoot.parseAppsJson()
        }

        Connections {
            target: launcherPanel
            function onShowPanelChanged() {
                if (launcherPanel.showPanel) {
                    searchInput.text = ""
                    launcherRoot.searchQuery = ""
                    launcherRoot.selectedIndex = 0
                    searchInput.forceActiveFocus()
                    
                    if (launcherRoot.allAppsRaw.length === 0) {
                        appsProcess.running = true
                    } else {
                        launcherRoot.updateSearch()
                    }
                }
            }
        }

        function parseAppsJson() {
            let content = appsFile.text();
            if (!content || content.trim().length === 0) return;
            
            try {
                let parsed = JSON.parse(content);
                if (Array.isArray(parsed)) {
                    launcherRoot.allAppsRaw = parsed;
                    launcherRoot.updateSearch();
                }
            } catch (e) {
                console.log("Launcher JSON Parse Error: ", e);
            }
        }

        function fuzzyMatch(str, pattern) {
            if (!pattern) return true;
            pattern = pattern.toLowerCase().replace(/\s+/g, "")
            str = str.toLowerCase()
            let patternIdx = 0
            for (let i = 0; i < str.length && patternIdx < pattern.length; i++) {
                if (str[i] === pattern[patternIdx]) patternIdx++
            }
            return patternIdx === pattern.length
        }

        function updateSearch() {
            appsModel.clear();
            let filtered = [];
            
            if (launcherRoot.searchQuery.trim() === "") {
                filtered = launcherRoot.allAppsRaw;
            } else {
                filtered = launcherRoot.allAppsRaw.filter(app => launcherRoot.fuzzyMatch(app.name, launcherRoot.searchQuery));
            }

            for (let i = 0; i < filtered.length; i++) {
                appsModel.append({
                    "appName": filtered[i].name,
                    "appIcon": filtered[i].icon,
                    "appExec": filtered[i].exec
                });
            }
            launcherRoot.selectedIndex = 0;
        }

        function launchSelected() {
            if (appsModel.count > 0 && launcherRoot.selectedIndex >= 0 && launcherRoot.selectedIndex < appsModel.count) {
                let cmd = appsModel.get(launcherRoot.selectedIndex).appExec;
                Quickshell.execDetached({ command: ["sh", "-c", cmd] });
                EventBus.togglePanel("launcher");
            }
        }

        Column {
            anchors.fill: parent
            anchors.margins: 15
            spacing: 10
            
            Rectangle {
                width: parent.width
                height: 36
                color: Colors.color0
                border.color: Colors.color8
                border.width: 1
                radius: 5

                TextInput {
                    id: searchInput
                    anchors.fill: parent
                    anchors.margins: 8
                    verticalAlignment: TextInput.AlignVCenter
                    color: Colors.foreground
                    font.family: "JetBrains Mono"
                    font.pixelSize: 14
                    focus: true
                    
                    onTextEdited: launcherRoot.searchQuery = text
                    
                    Text {
                        text: "  Search apps..."
                        color: Colors.color8
                        visible: !parent.text
                        font.family: "JetBrains Mono"
                        font.pixelSize: 14
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: appsModel.count + " apps"
                        color: Colors.color8
                        font.family: "JetBrains Mono"
                        font.pixelSize: 12
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        visible: appsModel.count > 0
                    }
                    
                    Keys.onDownPressed: {
                        launcherRoot.selectedIndex = Math.min(launcherRoot.selectedIndex + 1, appsModel.count - 1)
                        appList.positionViewAtIndex(launcherRoot.selectedIndex, ListView.Contain)
                    }
                    Keys.onUpPressed: {
                        launcherRoot.selectedIndex = Math.max(launcherRoot.selectedIndex - 1, 0)
                        appList.positionViewAtIndex(launcherRoot.selectedIndex, ListView.Contain)
                    }
                    Keys.onReturnPressed: launcherRoot.launchSelected()
                    Keys.onEscapePressed: EventBus.togglePanel("launcher")
                }
            }

            Rectangle { width: parent.width; height: 1; color: Colors.color8; opacity: 0.5 }

            ListView {
                id: appList
                width: parent.width
                height: parent.height - 50 
                clip: true
                spacing: 2
                model: appsModel

                delegate: Rectangle {
                    width: appList.width
                    height: 45
                    radius: 5
                    
                    property bool isSelected: index === launcherRoot.selectedIndex
                    
                    color: isSelected ? Colors.color5 : (appMouse.containsMouse ? Colors.color13 : "transparent")
                    
                    Rectangle {
                        anchors.bottom: parent.bottom
                        width: parent.width
                        height: 2
                        color: Colors.color13
                        visible: isSelected
                    }

                    Row {
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 10
                        
                        Image {
                            width: 24; height: 24
                            source: model.appIcon ? "image://icon/" + model.appIcon : ""
                            anchors.verticalCenter: parent.verticalCenter
                            smooth: true
                        }

                        Text {
                            text: model.appName
                            color: isSelected ? "white" : appMouse.containsMouse ? "white" : Colors.foreground
                            font.family: "JetBrains Mono"
                            font.weight: isSelected ? Font.Bold : Font.Normal
                            font.pixelSize: 14
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    MouseArea {
                        id: appMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            launcherRoot.selectedIndex = index;
                            launcherRoot.launchSelected();
                        }
                    }
                }
            }
        }
    }
}