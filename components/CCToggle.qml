// components/CCToggle.qml
import QtQuick
import qs.global

Item {
    property string icon:   ""
    property string label:  ""
    property bool   active: false
    signal tap()
    signal rightTap()

    Column {
        anchors.centerIn: parent
        spacing: 4
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text:           icon
            color:          active ? Colors.color7 : Colors.foreground
            font.family:    Style.barFont
            font.pixelSize: 22
            Behavior on color { ColorAnimation { duration: 150 } }
        }
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text:           label
            color:          Colors.color8
            font.family:    Style.barFont
            font.pixelSize: 9
            font.weight:    Font.Bold
        }
    }
    MouseArea {
        anchors.fill:    parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        cursorShape:     Qt.PointingHandCursor
        onClicked: (e) => { if (e.button === Qt.RightButton) parent.rightTap(); else parent.tap() }
    }
}
