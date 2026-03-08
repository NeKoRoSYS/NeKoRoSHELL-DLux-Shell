// quickshell/components/widgets/Theming.qml
import Quickshell
import Quickshell.Wayland
import QtQuick
import qs.components
import qs.shared

Panel {
    id: settingsScope
    
    panelWidth: 400
    panelHeight: 500

    property bool bordersEnabled: false
    property bool lightMode: false

    Column {
        anchors.fill: parent
        spacing: 20

        Text {
            text: "󰒓 Settings"
            color: Colors.foreground
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 18
            font.weight: Font.ExtraBold
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Rectangle { width: parent.width; height: 1; color: Colors.color8; opacity: 0.5 }

        Column {
            width: parent.width
            spacing: 15
            
            Toggle {
                labelText: "Show Borders"
                checked: settingsScope.bordersEnabled
                onToggled: (state) => EventBus.toggleBorders(state)
            }

            Toggle {
                labelText: "Light Mode"
                checked: settingsScope.lightMode
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
                width: parent.width
                height: 35
                radius: 8
                color: Colors.color0
                border.color: Colors.color8
                border.width: 2
                clip: true

                TextInput {
                    id: wpInput
                    anchors.fill: parent
                    anchors.margins: 10
                    verticalAlignment: TextInput.AlignVCenter
                    color: Colors.foreground
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 11
                    text: Config.wallpaperPath
                    selectByMouse: true
                    
                    onAccepted: {
                        Config.saveSetting("wallpaperPath", text)
                        Colors.reloadColors()
                        wpInput.focus = false
                    }
                }
            }
        }

        Rectangle { width: parent.width; height: 1; color: Colors.color8; opacity: 0.5 }

        Column {
            width: parent.width
            spacing: 15

            Text {
                text: "Navbar Position"
                color: Colors.foreground
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 14
                font.weight: Font.Bold
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Item {
                width: 130
                height: 130
                anchors.horizontalCenter: parent.horizontalCenter

                Button {
                    anchors { top: parent.top; horizontalCenter: parent.horizontalCenter }
                    labelText: "󰁝"
                    labelFont: "JetBrainsMono Nerd Font"
                    buttonSize: 40
                    buttonColor: Colors.color7
                    onButtonClicked: EventBus.changeLocation("top")
                }
                Button {
                    anchors { bottom: parent.bottom; horizontalCenter: parent.horizontalCenter }
                    labelText: "󰁅"
                    labelFont: "JetBrainsMono Nerd Font"
                    buttonSize: 40
                    buttonColor: Colors.color7
                    onButtonClicked: EventBus.changeLocation("bottom")
                }
                Button {
                    anchors { left: parent.left; verticalCenter: parent.verticalCenter }
                    labelText: "󰁍"
                    labelFont: "JetBrainsMono Nerd Font"
                    buttonSize: 40
                    buttonColor: Colors.color7
                    onButtonClicked: EventBus.changeLocation("left")
                }
                Button {
                    anchors { right: parent.right; verticalCenter: parent.verticalCenter }
                    labelText: "󰁔"
                    labelFont: "JetBrainsMono Nerd Font"
                    buttonSize: 40
                    buttonColor: Colors.color7
                    onButtonClicked: EventBus.changeLocation("right")
                }
            }
        }
    }
}