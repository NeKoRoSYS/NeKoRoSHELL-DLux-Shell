// components/NotificationCard.qml
import QtQuick
import Quickshell.Services.Notifications
import qs.global

Item {
    id: rootItem
    width: parent ? parent.width : 400
    height: contentCol.childrenRect.height + 20

    property var notification
    property real contentOpacity: 1.0
    property bool swipeEnabled: true 

    function triggerDismiss() {
        if (!dismissTimer.running) {
            cardRoot.x = rootItem.width;
            dismissTimer.start();
        }
    }

    Rectangle {
        id: cardRoot
        width: rootItem.width
        height: rootItem.height
        
        color: mouseArea.containsMouse ? Qt.alpha(Colors.foreground, 0.6) : Qt.alpha(Colors.background, 0.6)
        Behavior on color { ColorAnimation { duration: 150; easing.type: Easing.OutCubic } }

        border.color: Colors.color13
        border.width: 2
        radius: 8
        clip: true

        x: 0
        Behavior on x { 
            enabled: !dragHandler.active
            NumberAnimation { duration: 150; easing.type: Easing.OutCubic } 
        }

        DragHandler {
            id: dragHandler
            target: cardRoot
            enabled: rootItem.swipeEnabled
            xAxis.enabled: true
            yAxis.enabled: false
            
            onActiveChanged: {
                if (!active && enabled) {
                    if (Math.abs(cardRoot.x) > rootItem.width / 3) {
                        cardRoot.x = cardRoot.x > 0 ? rootItem.width : -rootItem.width;
                        dismissTimer.start();
                    } else {
                        cardRoot.x = 0;
                    }
                }
            }
        }

        Timer {
            id: dismissTimer
            interval: 200
            onTriggered: if (rootItem.notification) rootItem.notification.dismiss()
        }

        Column {
            id: contentCol
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 10
            spacing: 10
            
            opacity: rootItem.contentOpacity
            Behavior on opacity { NumberAnimation { duration: 200 } }

            Row {
                width: parent.width
                spacing: 12
                height: childrenRect.height 

                Rectangle {
                    width: 32
                    height: 32
                    radius: 6
                    color: "transparent"
                    clip: true

                    Image {
                        anchors.fill: parent
                        fillMode: Image.PreserveAspectCrop
                        source: {
                            if (!notification) return "image://icon/dialog-information";
                            if (notification.image) return notification.image.startsWith("/") ? "file://" + notification.image : notification.image;
                            if (notification.appIcon) return notification.appIcon.startsWith("/") ? "file://" + notification.appIcon : "image://icon/" + notification.appIcon;
                            return "image://icon/dialog-information";
                        }
                    }
                }

                Column {
                    width: parent.width - 44
                    height: childrenRect.height 
                 
                    Text {
                        text: notification ? notification.summary : ""
                        color: mouseArea.containsMouse ? Qt.alpha(Colors.background, 0.6) : Qt.alpha(Colors.foreground, 0.6)
                        Behavior on color { ColorAnimation { duration: 150; easing.type: Easing.OutCubic } }
                        font.weight: Font.Bold
                        elide: Text.ElideRight
                        width: parent.width
                    }
  
                    Text {
                        text: notification ? notification.body : ""
                        color: mouseArea.containsMouse ? Qt.alpha(Colors.background, 0.6) : Qt.alpha(Colors.foreground, 0.6)
                        Behavior on color { ColorAnimation { duration: 150; easing.type: Easing.OutCubic } }
                        font.pixelSize: 12
                        wrapMode: Text.Wrap
                        width: parent.width
                    }
                }
            }

            Rectangle {
                width: parent.width
                height: 4
                color: Colors.color13
                radius: 2
                visible: notification && notification.hints && notification.hints.value !== undefined
                
                Rectangle {
                    width: parent.width * ((notification && notification.hints && notification.hints.value !== undefined) ? (notification.hints.value / 100) : 0)
                    height: parent.height
                    color: Colors.color13
                    radius: 2
                }
            }

            Row {
                spacing: 5

                property bool hasVisibleActions: {
                    if (!notification || !notification.actions) return false;
                    for (let i = 0; i < notification.actions.length; i++) {
                        if (notification.actions[i].identifier !== "default") return true;
                    }
                    return false;
                }

                visible: hasVisibleActions
                height: childrenRect.height 
                
                Repeater {
                    id: actions
                    model: notification ? notification.actions : null
                    delegate: Rectangle {
                        visible: modelData.id !== "default"
                        width: actionLabel.implicitWidth + 20
                        height: 24
                        color: Colors.color13
                        radius: 4
                        Text {
                            id: actionLabel
                            anchors.centerIn: parent
                            text: modelData.text
                            color: "white"
                            font.pixelSize: 11
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                modelData.invoke()
                                rootItem.triggerDismiss();
                            }
                        }
                    }
                }
            }
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            hoverEnabled: true
            onClicked: (mouse) => {
                if (!rootItem.notification) return;
                
                if (mouse.button === Qt.RightButton) {
                    rootItem.triggerDismiss();
                } else if (mouse.button === Qt.LeftButton) {
                    if (rootItem.notification.actions) {
                        for (let i = 0; i < rootItem.notification.actions.length; i++) {
                            if (rootItem.notification.actions[i].identifier === "default") {
                                 rootItem.notification.actions[i].invoke();
                                break;
                            }
                        }
                    }
                    rootItem.triggerDismiss();
                }
            }
        }
    }
}