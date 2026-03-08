// panels/Tray.qml
import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import qs.components
import qs.globals

Panel {
    id: trayPanel

    panelWidth:      400
    panelHeight:     475
    animationPreset: "slide"

    Column {
        anchors.fill: parent
        spacing: 4

        Text {
            text:           "󱊣  Tray"
            color:          Colors.foreground
            font.family:    "JetBrainsMono Nerd Font"
            font.pixelSize: 14
            font.weight:    Font.ExtraBold
            anchors.horizontalCenter: parent.horizontalCenter
            bottomPadding:  4
        }

        Rectangle {
            width: parent.width; height: 1
            color: Colors.color8; opacity: 0.5
        }

        Repeater {
            model: SystemTray.items.values

            delegate: Rectangle {
                id: trayRow
                required property var modelData

                width:  parent.width
                height: 40
                color:  itemHover.containsMouse ? Colors.color1 : Colors.color3
                radius: 8
                Behavior on color { ColorAnimation { duration: 150 } }

                Row {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left:          parent.left
                    anchors.leftMargin:    8
                    spacing: 10

                    Image {
                        width:  24; height: 24
                        source: trayRow.modelData.icon
                        anchors.verticalCenter: parent.verticalCenter
                        smooth: true
                    }

                    Text {
                        text:           trayRow.modelData.tooltip?.title || trayRow.modelData.title || ""
                        color:          itemHover.containsMouse ? "black" : "white"
                        font.family:    "JetBrainsMono Nerd Font"
                        font.pixelSize: 12
                        elide:          Text.ElideRight
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                // QsMenuAnchor must be a child of the item it anchors to
                QsMenuAnchor {
                    id: menuAnchor
                    anchor.window: trayRow.QsWindow.window
                    menu: trayRow.modelData.menu
                }

                MouseArea {
                    id: itemHover
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape:  Qt.PointingHandCursor
                    acceptedButtons: Qt.LeftButton | Qt.RightButton

                    onClicked: (event) => {
                        if (event.button === Qt.RightButton && trayRow.modelData.hasMenu) {
                            menuAnchor.open()
                        } else {
                            trayRow.modelData.activate()
                        }
                    }
                }
            }
        }

        Text {
            visible:        SystemTray.items.values.length === 0
            text:           "No tray items"
            color:          Colors.color8
            font.family:    "JetBrainsMono Nerd Font"
            font.pixelSize: 12
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }
}