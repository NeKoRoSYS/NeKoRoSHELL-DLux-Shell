// panels/Settings.qml
import Quickshell
import QtQuick
import qs.components
import qs.globals

Panel {
    id: settingsPanel

    panelWidth:  400
    panelHeight: 625

    property bool bordersEnabled: Config.enableBorders
    property bool lightMode: Config.lightMode

    edgePadding:     15

    Rectangle {
        id: launcherRoot
        anchors.fill: parent
        color: Colors.background
        border.color: Colors.color13
        border.width: 2
        radius: 10
        clip: true

        Column {
            anchors.fill: parent
            anchors.margins: 15
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
                    labelText: "Show Borders"
                    checked: settingsPanel.bordersEnabled
                    onToggled: (state) => EventBus.toggleBorders(state)
                }

                Toggle {
                    labelText: "Light Mode"
                    checked: settingsPanel.lightMode
                    onToggled: (state) => EventBus.toggleLightMode(state)
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
                    width:  parent.width; height: 28; radius: 14
                    color:  Colors.color3
                    Behavior on color { ColorAnimation { duration: 150 } }

                    Text {
                        anchors.centerIn: parent
                        text:            "Select Wallpaper"
                        color:           "white"
                        font.family:     "JetBrainsMono Nerd Font"
                        font.pixelSize:  11
                        font.weight:     Font.Bold
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape:  Qt.PointingHandCursor
                        onClicked:    EventBus.togglePanel("wallpaper")
                    }
                }

                // Rectangle {
                //     width: parent.width
                //     height: 35
                //     radius: 8
                //     color: Colors.color0
                //     border.color: Colors.color8
                //     border.width: 2
                //     clip: true

                //     TextInput {
                //         id: wpInput
                //         anchors.fill: parent
                //         anchors.margins: 10
                //         verticalAlignment: TextInput.AlignVCenter
                //         color: Colors.foreground
                //         font.family: "JetBrainsMono Nerd Font"
                //         font.pixelSize: 11
                //         text: Config.wallpaperPath
                //         selectByMouse: true
                        
                //         onAccepted: {
                //             Config.saveSetting("wallpaperPath", text)
                //             Colors.reloadColors()
                //             wpInput.focus = false
                //         }
                //     }
                // }
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

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 10

                Repeater {
                    model: ["default", "center", "minimal", "media"]
                    delegate: Rectangle {
                        required property string modelData
                        width:  80; height: 28; radius: 14
                        color:  Config.activeLayout === modelData ? Colors.color3 : Colors.color0
                        Behavior on color { ColorAnimation { duration: 150 } }

                        Text {
                            anchors.centerIn: parent
                            text:            parent.modelData
                            color:           Config.activeLayout === parent.modelData ? "white" : Colors.foreground
                            font.family:     "JetBrainsMono Nerd Font"
                            font.pixelSize:  11
                            font.weight:     Font.Bold
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape:  Qt.PointingHandCursor
                            onClicked:    EventBus.changeLayout(parent.modelData)
                        }
                    }
                }
            }
        }
    }
}