// quickshell/components/SettingsPanel.qml
import Quickshell
import QtQuick
import qs.shared

Scope {
    id: settingsScope

    property bool showPanel: false
    property bool bordersEnabled: false
    
    signal locationSelected(string newLocation)
    signal bordersToggled(bool state)

    Variants {
        model: Quickshell.screens

        PanelWindow {
            required property var modelData
            screen: modelData

            visible: settingsScope.showPanel
            color: "transparent"

            anchors { top: false; bottom: false; left: false; right: false }
            
            implicitWidth: 260
            implicitHeight: 350
            Rectangle {
                anchors.fill: parent
                color: Colors.background
                radius: 20
                border.color: Colors.color7
                border.width: 2

                Column {
                    anchors.fill: parent
                    anchors.margins: 25
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
                            labelText: "Borders"
                            checked: settingsScope.bordersEnabled
                            onToggled: (state) => settingsScope.bordersToggled(state)
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
                                onButtonClicked: settingsScope.locationSelected("top")
                            }
                            Button {
                                anchors { bottom: parent.bottom; horizontalCenter: parent.horizontalCenter }
                                labelText: "󰁅"
                                labelFont: "JetBrainsMono Nerd Font"
                                buttonSize: 40
                                buttonColor: Colors.color7
                                onButtonClicked: settingsScope.locationSelected("bottom")
                            }
                            Button {
                                anchors { left: parent.left; verticalCenter: parent.verticalCenter }
                                labelText: "󰁍"
                                labelFont: "JetBrainsMono Nerd Font"
                                buttonSize: 40
                                buttonColor: Colors.color7
                                onButtonClicked: settingsScope.locationSelected("left")
                            }
                            Button {
                                anchors { right: parent.right; verticalCenter: parent.verticalCenter }
                                labelText: "󰁔"
                                labelFont: "JetBrainsMono Nerd Font"
                                buttonSize: 40
                                buttonColor: Colors.color7
                                onButtonClicked: settingsScope.locationSelected("right")
                            }
                        }
                    }
                }
            }
        }
    }
}