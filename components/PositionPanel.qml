
// quickshell/components/PositionPanel.qml
import Quickshell
import QtQuick
import "../shared"

Scope {
    id: positionerScope

    property bool showPanel: false
    signal locationSelected(string newLocation)

    Variants {
        model: Quickshell.screens

        PanelWindow {
            required property var modelData
            screen: modelData

            visible: positionerScope.showPanel
            color: "transparent"

            anchors { top: false; bottom: false; left: false; right: false }
            
            implicitWidth: 220
            implicitHeight: 250

            Rectangle {
                anchors.fill: parent
                color: Colors.background
                radius: 20
                border.color: Colors.color7
                border.width: 2

                Column {
                    anchors.centerIn: parent
                    spacing: 25

                    Text {
                        text: "Move Navbar"
                        color: Colors.foreground
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 16
                        font.weight: Font.ExtraBold
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    Item {
                        width: 130
                        height: 130
                        anchors.horizontalCenter: parent.horizontalCenter

                        Button {
                            anchors { top: parent.top; horizontalCenter: parent.horizontalCenter }
                            labelText: "󰁝" // Nerd Font Up Arrow
                            labelFont: "JetBrainsMono Nerd Font"
                            buttonSize: 45
                            buttonColor: Colors.color7
                            onButtonClicked: positionerScope.locationSelected("top")
                        }
                        Button {
                            anchors { bottom: parent.bottom; horizontalCenter: parent.horizontalCenter }
                            labelText: "󰁅" // Down Arrow
                            labelFont: "JetBrainsMono Nerd Font"
                            buttonSize: 45
                            buttonColor: Colors.color7
                            onButtonClicked: positionerScope.locationSelected("bottom")
                        }
                        Button {
                            anchors { left: parent.left; verticalCenter: parent.verticalCenter }
                            labelText: "󰁍" // Left Arrow
                            labelFont: "JetBrainsMono Nerd Font"
                            buttonSize: 45
                            buttonColor: Colors.color7
                            onButtonClicked: positionerScope.locationSelected("left")
                        }
                        Button {
                            anchors { right: parent.right; verticalCenter: parent.verticalCenter }
                            labelText: "󰁔" // Right Arrow
                            labelFont: "JetBrainsMono Nerd Font"
                            buttonSize: 45
                            buttonColor: Colors.color7
                            onButtonClicked: positionerScope.locationSelected("right")
                        }
                    }
                }
            }
        }
    }
}