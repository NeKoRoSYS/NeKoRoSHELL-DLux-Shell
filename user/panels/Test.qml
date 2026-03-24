// user/panels/Test.qml
import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import qs.components
import qs.global

Panel {
    id: trayPanel

    property int trayItemCount: SystemTray.items.values.length
    panelWidth:      400
    panelHeight:     85 + (trayItemCount > 0 ? (trayItemCount * 58) : 25)
    animationPreset: "slide"
    edgePadding:     15

    Behavior on panelHeight {
        NumberAnimation {
            duration: Animations.normal
            easing.type: Animations.easeOut
        }
    }

    Rectangle {
        id: launcherRoot
        anchors.fill: parent
        color: "transparent"
        border.color: Colors.color13
        border.width: 2
        radius: 10
        clip: true

        Column {
            anchors.fill: parent
            anchors.margins: 15
            width: parent.width
            spacing: 10

            Item {
                width: parent.width
                height: 30 
                
                Text {
                    text:           "󱊣  Tray"
                    color:           Colors.foreground
                    font.family:     "JetBrainsMono Nerd Font"
                    font.pixelSize:  18
                    font.weight:     Font.ExtraBold
                    anchors.centerIn: parent 
                }
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
                            color:          itemHover.containsMouse ? "white" : Colors.foreground
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
                visible:        trayPanel.trayItemCount === 0
                text:           "No tray items"
                color:          Colors.color8
                font.family:    "JetBrainsMono Nerd Font"
                font.pixelSize: 12
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }
}