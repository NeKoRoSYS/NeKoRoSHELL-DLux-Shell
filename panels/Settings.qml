// panels/Settings.qml
import Quickshell
import QtQuick
import QtQuick.Controls
import Qt.labs.folderlistmodel
import qs.components
import qs.global

Panel {
    id: settingsPanel

    panelWidth:  400
    panelHeight: 500

    property bool bordersEnabled: Config.enableBorders
    property bool lightMode: Config.lightMode

    edgePadding:     15

    property var builtinLayoutsModel: FolderListModel {
        folder: "file://" + Quickshell.env("HOME") + "/.config/quickshell/layouts"
        nameFilters: ["*.json"]
        showDirs: false
    }

    property var customLayoutsModel: FolderListModel {
        folder: "file://" + Quickshell.env("HOME") + "/.config/quickshell/user/layouts"
        nameFilters: ["*.json"]
        showDirs: false
    }
    
    Rectangle {
        id: launcherRoot
        anchors.fill: parent
        color: "transparent"
        border.color: Colors.color13
        border.width: 2
        radius: 10
        clip: true

        ScrollView {
            id: scroll
            anchors.fill: parent
            anchors.margins: 2
            clip: true
            
            ScrollBar.vertical: ScrollBar {
                policy: ScrollBar.AsNeeded
                contentItem: Rectangle { implicitWidth: 4; radius: 2; color: Colors.color7; opacity: 0.4 }
            }
            ScrollBar.horizontal: ScrollBar { policy: ScrollBar.AlwaysOff }
            
            contentWidth: width
            contentHeight: mainCol.height + 30

            Column {
                id: mainCol
                width: scroll.width - 30 
                x: 15
                y: 15
                spacing: 20

                Text {
                    text:            "󰒓  Settings"
                    color:           Colors.foreground
                    font.family:     "JetBrainsMono Nerd Font"
                    font.pixelSize:  18
                    font.weight:     Font.ExtraBold
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Rectangle { width: parent.width; height: 1; color: Colors.color8; opacity: 0.5 }

                // ── Toggles ───────────────────────────────────────────────────────
                Column {
                    width: parent.width
                    spacing: 15
                    
                    Toggle {
                        labelText: "Transparent Navbar"
                        checked: Config.transparentNavbar
                        onToggled: (state) => Config.saveSetting("transparentNavbar", state)
                    }

                    Toggle {
                        labelText: "Show Borders"
                        checked: settingsPanel.bordersEnabled
                        onToggled: (state) => EventBus.toggleBorders(state)
                    }

                    Toggle {
                        labelText: "Light Mode"
                        checked: settingsPanel.lightMode
                        onToggled: (state) => EventBus.toggleLightMode(state)
                    }

                    Toggle {
                        labelText: "Wallpaper Parallax"
                        checked: Config.enableParallax
                        onToggled: (state) => Config.saveSetting("enableParallax", state)
                    }
                }

                Rectangle { width: parent.width; height: 1; color: Colors.color8; opacity: 0.5 }

                Column {
                    width: parent.width
                    spacing: 15

                    Text {
                        text: "Wallpaper Path"
                        color: Colors.foreground
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 14
                        font.weight: Font.Bold
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    Rectangle {
                        anchors.horizontalCenter: parent.horizontalCenter
                        width:  parent.width - 40
                        height: 36
                        radius: 18
                        color:  wallArea.containsMouse ? Colors.color7 : Colors.color0
                        Behavior on color { ColorAnimation { duration: 150 } }

                        Text {
                            anchors.centerIn: parent
                            text:           "󰒓  Select Wallpaper"
                            color:          wallArea.containsMouse ? Colors.background : Colors.foreground
                            Behavior on color { ColorAnimation { duration: 150 } }
                            font.family:    Style.barFont
                            font.pixelSize: 13
                            font.weight:    Font.Bold
                        }

                        MouseArea {
                            id: wallArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape:  Qt.PointingHandCursor
                            onClicked:    EventBus.togglePanel("wallpaper", settingsPanel.targetScreen)
                        }
                    }
                }

                Rectangle { width: parent.width; height: 1; color: Colors.color8; opacity: 0.5 }

                // ── Navbar position ───────────────────────────────────────────────
                Text {
                    text:            "Navbar Position"
                    color:           Colors.foreground
                    font.family:     "JetBrainsMono Nerd Font"
                    font.pixelSize:  14
                    font.weight:     Font.Bold
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Item {
                    width:  130
                    height: 130
                    anchors.horizontalCenter: parent.horizontalCenter

                    Button { anchors { top: parent.top; horizontalCenter: parent.horizontalCenter }
                            labelText: "󰁝"; labelFont: "JetBrainsMono Nerd Font"
                            buttonSize: 40; buttonColor: Colors.color3
                            onButtonClicked: EventBus.changeLocation("top") }
                    Button { anchors { bottom: parent.bottom; horizontalCenter: parent.horizontalCenter }
                            labelText: "󰁅"; labelFont: "JetBrainsMono Nerd Font"
                            buttonSize: 40; buttonColor: Colors.color3
                            onButtonClicked: EventBus.changeLocation("bottom") }
                    Button { anchors { left: parent.left; verticalCenter: parent.verticalCenter }
                            labelText: "󰁍"; labelFont: "JetBrainsMono Nerd Font"
                            buttonSize: 40; buttonColor: Colors.color3
                            onButtonClicked: EventBus.changeLocation("left") }
                    Button { anchors { right: parent.right; verticalCenter: parent.verticalCenter }
                            labelText: "󰁔"; labelFont: "JetBrainsMono Nerd Font"
                            buttonSize: 40; buttonColor: Colors.color3
                            onButtonClicked: EventBus.changeLocation("right") }
                }
                
                Rectangle { width: parent.width; height: 1; color: Colors.color8; opacity: 0.5 }

                // ── Layout switcher ───────────────────────────────────────────────
                Text {
                    text:            "Bar Layout"
                    color:           Colors.foreground
                    font.family:     "JetBrainsMono Nerd Font"
                    font.pixelSize:  14
                    font.weight:     Font.Bold
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Flow {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width - 20
                    spacing: 10
                    layoutDirection: Qt.LeftToRight
                    
                    Repeater {
                        model: settingsPanel.builtinLayoutsModel
                        delegate: Rectangle {
                            property string fName: model.fileName !== undefined ? model.fileName : ""
                            property string layoutId: fName.replace(".json", "")

                            visible: fName !== ""
                            width:  layoutText.implicitWidth + 24
                            height: 28
                            radius: 14
                            color:  Config.activeLayout === layoutId ? Colors.color3 : Colors.color0
                            Behavior on color { ColorAnimation { duration: 150 } }

                            Text {
                                id: layoutText
                                anchors.centerIn: parent
                                text:            layoutId
                                color:           Config.activeLayout === parent.layoutId ? "white" : Colors.foreground
                                font.family:     "JetBrainsMono Nerd Font"
                                font.pixelSize:  11
                                font.weight:     Font.Bold
                            }
                            MouseArea {
                                anchors.fill: parent
                                cursorShape:  Qt.PointingHandCursor
                                onClicked:    Config.saveSetting("activeLayout", parent.layoutId)
                            }
                        }
                    }

                    Repeater {
                        model: settingsPanel.customLayoutsModel
                        delegate: Rectangle {
                            property string fName: model.fileName !== undefined ? model.fileName : ""
                            property string layoutId: "custom:" + fName.replace(".json", "")

                            visible: fName !== ""
                            width:  layoutText.implicitWidth + 24
                            height: 28
                            radius: 14
                            color:  Config.activeLayout === layoutId ? Colors.color3 : Colors.color0
                            Behavior on color { ColorAnimation { duration: 150 } }

                            Text {
                                id: layoutText
                                anchors.centerIn: parent
                                text:            fName.replace(".json", "")
                                color:           Config.activeLayout === parent.layoutId ? "white" : Colors.foreground
                                font.family:     "JetBrainsMono Nerd Font"
                                font.pixelSize:  11
                                font.weight:     Font.Bold
                            }
                            MouseArea {
                                anchors.fill: parent
                                cursorShape:  Qt.PointingHandCursor
                                onClicked:    Config.saveSetting("activeLayout", parent.layoutId)
                            }
                        }
                    }
                }

                Rectangle { width: parent.width; height: 1; color: Colors.color8; opacity: 0.5 }

                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width:  parent.width - 40
                    height: 36
                    radius: 18
                    color:  advArea.containsMouse ? Colors.color7 : Colors.color0
                    Behavior on color { ColorAnimation { duration: 150 } }

                    Text {
                        anchors.centerIn: parent
                        text:           "󰒓  Advanced Settings"
                        color:          advArea.containsMouse ? Colors.background : Colors.foreground
                        Behavior on color { ColorAnimation { duration: 150 } }
                        font.family:    Style.barFont
                        font.pixelSize: 13
                        font.weight:    Font.Bold
                    }

                    MouseArea {
                        id: advArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape:  Qt.PointingHandCursor
                        onClicked:    EventBus.togglePanel("advanced", settingsPanel.targetScreen)
                    }
                }
            }
        }
    }
}