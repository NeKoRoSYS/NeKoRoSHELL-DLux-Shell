// panels/Notifications.qml
import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Notifications
import qs.global
import qs.components

Panel {
    id: ncPanel

    property int maxPanelHeight: 700
    property int notifCount: Notifs.trackedNotifications.values.length
    
    property int trackedContentHeight: 58

    panelWidth:  420
    panelHeight: 720
    animationPreset: "slide"
    edgePadding: 15

    Behavior on panelHeight {
        NumberAnimation {
            duration: Animations.normal
            easing.type: Animations.easeOut
        }
    }

    Rectangle {
        id: ncRoot
        anchors.fill: parent
        color: Colors.background
        border.color: Colors.color13
        border.width: 2
        radius: 10
        clip: true

        function clearAllNotifications() {
            let vals = Notifs.trackedNotifications.values;
            for (let i = vals.length - 1; i >= 0; i--) {
                if (vals[i]) vals[i].dismiss();
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

            Flickable {
                width: parent.width
                height: parent.height - 62 
                
                contentHeight: notifCol.childrenRect.height 
                clip: true
                interactive: contentHeight > height

                Column {
                    id: notifCol
                    width: parent.width
                    spacing: 10
                    
                    property int realHeight: childrenRect.height
                    
                    onRealHeightChanged: {
                        if (realHeight > 50) { 
                            ncPanel.trackedContentHeight = realHeight;
                        }
                    }

                    Repeater {
                        id: rep
                        model: Notifs.trackedNotifications
                        
                        delegate: Item {
                            width: notifCol.width
                            
                            property string currentApp: modelData.appName
                            property string previousApp: index > 0 ? Notifs.trackedNotifications.values[index - 1].appName : ""
                            property bool showSection: index === 0 || currentApp !== previousApp
                            
                            height: (showSection ? 40 : 0) + notifCard.height 
                            
                            Item {
                                id: sectionHeader
                                width: parent.width
                                height: 30
                                visible: showSection
                                
                                Text {
                                    anchors.bottom: parent.bottom
                                    anchors.bottomMargin: 5
                                    text: currentApp
                                    color: Colors.color5
                                    font.family: "JetBrains Mono"
                                    font.weight: Font.Bold
                                    font.pixelSize: 13
                                    font.capitalization: Font.AllUppercase
                                }
                            }

                            NotificationCard {
                                id: notifCard
                                width: parent.width
                                anchors.top: showSection ? sectionHeader.bottom : parent.top
                                anchors.topMargin: showSection ? 10 : 0
                                notification: modelData 
                            }
                        }
                    }
                }
            }
        }
        
        Text {
            anchors.centerIn: parent
            anchors.verticalCenterOffset: 30 
            text: "No new notifications\nYou're all caught up!"
            color: Colors.color8
            font.family: "JetBrains Mono"
            font.pixelSize: 14
            horizontalAlignment: Text.AlignHCenter
            visible: ncPanel.notifCount === 0
        }
    }
}