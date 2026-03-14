// components/NotificationCard.qml
import QtQuick
import Quickshell.Services.Notifications
import qs.global

Rectangle {
    id: cardRoot
    width: parent ? parent.width : 400
    
    height: contentCol.childrenRect.height + 20
    
    color: Colors.color0
    border.color: Colors.color13
    border.width: 2
    radius: 8
    clip: true

    property var notification

    Column {
        id: contentCol
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 10
        spacing: 10

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
                        if (notification.image)   return notification.image.startsWith("/") ? "file://" + notification.image : notification.image;
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
                    color: Colors.foreground
                    font.weight: Font.Bold
                    elide: Text.ElideRight
                    width: parent.width
                }
                Text {
                    text: notification ? notification.body : ""
                    color: Colors.color8
                    font.pixelSize: 12
                    wrapMode: Text.Wrap
                    width: parent.width
                }
            }
        }

        Rectangle {
            width: parent.width
            height: 4
            color: Colors.color1
            radius: 2
            visible: notification && notification.hints && notification.hints.value !== undefined
            
            Rectangle {
                width: parent.width * ((notification && notification.hints && notification.hints.value !== undefined) ? (notification.hints.value / 100) : 0)
                height: parent.height
                color: Colors.color5
                radius: 2
            }
        }

        Row {
            spacing: 5
            visible: notification && notification.actions ? notification.actions.length > 0 : false
            
            height: childrenRect.height 
            
            Repeater {
                model: notification ? notification.actions : null
                delegate: Rectangle {
                    width: actionLabel.implicitWidth + 20
                    height: 24
                    color: Colors.color1
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
                        onClicked: modelData.invoke()
                    }
                }
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.RightButton
        onClicked: {
            if (notification) {
                notification.dismiss(); 
            }
        }
    }
}