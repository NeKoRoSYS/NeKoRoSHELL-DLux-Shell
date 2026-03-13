// components/NotificationCard.qml
import QtQuick
import Quickshell.Services.Notifications
import qs.global

Rectangle {
    id: cardRoot
    width: ListView.view ? ListView.view.width : 400
    height: contentCol.height + 20
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

            Image {
                width: 32; height: 32
                source: notification.appIcon ? "image://icon/" + notification.appIcon : "image://icon/dialog-information"
                fillMode: Image.PreserveAspectFit
            }

            Column {
                width: parent.width - 44
                Text {
                    text: notification.summary
                    color: Colors.foreground
                    font.weight: Font.Bold
                    elide: Text.ElideRight
                    width: parent.width
                }
                Text {
                    text: notification.body
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
            visible: notification.hints.value !== undefined
            
            Rectangle {
                width: parent.width * (notification.hints.value / 100)
                height: parent.height
                color: Colors.color5
                radius: 2
            }
        }

        Row {
            spacing: 5
            visible: notification.actions.length > 0
            Repeater {
                model: notification.actions
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
        onClicked: notification.dismiss()
    }
}