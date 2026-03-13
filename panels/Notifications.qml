// panels/Notifications.qml
import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Notifications
import qs.global
import qs.components

Panel {
    id: ncPanel

    panelWidth: 420
    panelHeight: 700
    animationPreset: "slide"
    edgePadding: 15

    Rectangle {
        id: ncRoot
        anchors.fill: parent
        color: Colors.background
        border.color: Colors.color13
        border.width: 2
        radius: 10
        clip: true

        function clearAllNotifications() {
            let notifs = Notifs.trackedNotifications;
            for (let i = notifs.length - 1; i >= 0; i--) {
                notifs[i].dismiss();
            }
        }

        Column {
            anchors.fill: parent
            anchors.margins: 15
            spacing: 15

            Item {
                width: parent.width
                height: 30

                Text {
                    text: "  Notifications"
                    color: Colors.foreground
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 18
                    font.weight: Font.ExtraBold
                    anchors.verticalCenter: parent.verticalCenter
                }

                Row {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 15

                    Toggle {
                        labelText: "DND"
                        toggleStyle: "checkbox"
                        checked: Config.dndEnabled
                        onToggled: (newState) => { Config.dndEnabled = newState }
                        width: 70 
                    }

                    Button {
                        labelText: ""
                        labelFont: "JetBrainsMono Nerd Font"
                        buttonColor: Colors.color1
                        width: height
                        height: 30
                        onButtonClicked: ncRoot.clearAllNotifications()
                    }
                }
            }

            Rectangle { width: parent.width; height: 2; color: Colors.color13 }

            ListView {
                id: notifList
                width: parent.width
                height: parent.height - 60
                clip: true
                spacing: 10
                
                model: Notifs.trackedNotifications
                
                section.property: "appName"
                section.criteria: ViewSection.FullString
                section.delegate: Item {
                    width: notifList.width
                    height: 30
                    
                    Text {
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 5
                        text: section
                        color: Colors.color5
                        font.family: "JetBrains Mono"
                        font.weight: Font.Bold
                        font.pixelSize: 13
                        font.capitalization: Font.AllUppercase
                    }
                }

                delegate: NotificationCard {
                    notification: modelData 
                }

                Text {
                    anchors.centerIn: parent
                    text: "No new notifications\nYou're all caught up!"
                    color: Colors.color8
                    font.family: "JetBrains Mono"
                    font.pixelSize: 14
                    horizontalAlignment: Text.AlignHCenter
                    visible: notifList.count === 0
                }
            }
        }
    }
}