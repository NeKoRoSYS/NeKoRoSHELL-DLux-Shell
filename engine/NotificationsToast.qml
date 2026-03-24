// engine/NotificationsToast.qml
import Quickshell
import QtQuick
import Quickshell.Wayland
import qs.global
import qs.components

Scope {
    id: root
    
    property bool allowToasts: true

    Variants {
        model: Quickshell.screens

        PanelWindow {
            required property var modelData
            screen: modelData

            anchors { top: true; right: true }
            
            margins {
                top:    (Config.navbarLocation === "top"    ? loader.barSize : 0) + 15
                bottom: (Config.navbarLocation === "bottom" ? loader.barSize : 0) + 15
                left:   (Config.navbarLocation === "left"   ? loader.barSize : 0) + 15
                right:  (Config.navbarLocation === "right"  ? loader.barSize : 0) + 15
            }
            
            WlrLayershell.layer: WlrLayer.Overlay
            exclusionMode: ExclusionMode.Ignore
            WlrLayershell.namespace: "quickshell-notification"
            
            color: "transparent"
            
            visible: NotificationsEngine.activePopups.count > 0 && root.allowToasts
            
            width: 400
            height: Math.max(1, popupList.contentHeight)

            ListView {
                id: popupList
                
                width: parent.width
                height: contentHeight
                
                spacing: 15
                interactive: false
                
                model: NotificationsEngine.activePopups 
                
                displaced: Transition {
                    NumberAnimation { properties: "x,y"; duration: 250; easing.type: Easing.OutCubic }
                }

                delegate: AnimatedElement {
                    id: animWrapper
                    width: 400
                    height: card.height
                    
                    preset: "slide"
                    edge: "right"
                    show: false
                    
                    Component.onCompleted: {
                        show = true
                    }

                    NotificationCard {
                        id: card
                        notification: model.notif 
                        
                        function dismissPopup() {
                            if (!animWrapper.show) return;
                            animWrapper.show = false;
                            removeTimer.start();
                        }

                        Timer {
                            id: removeTimer
                            interval: 300 
                            onTriggered: NotificationsEngine.removePopup(model.notif) 
                        }
                        
                        Timer {
                            running: true
                            
                            property int timeVal: (card.notification && card.notification.expireTimeout !== undefined) ? card.notification.expireTimeout : -1
                            
                            interval: timeVal > 0 ? timeVal : 5000
                            
                            onTriggered: {
                                if (timeVal !== 0) {
                                    card.dismissPopup()
                                }
                            }
                        }

                        Connections {
                            target: card.notification
                            function onClosed() {
                                card.dismissPopup()
                            }
                        }
                    }
                }
            }
        }
    }
}