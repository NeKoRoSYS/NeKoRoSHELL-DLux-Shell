import QtQuick
import qs.shared

Rectangle {
    id: root
    signal buttonClicked()
    property string labelText
    property string labelFont
    property real buttonSize: parent.height / 1.65
    property color buttonColor

    height: buttonSize
    width: height
    radius: height / 2
    color: buttonColor

    Text {
        id: label
        anchors.centerIn: parent
        text: root.labelText
        font.family: root.labelFont
        color: Colors.background
        font.pixelSize: parent.height / 1.65
    }

    Button {
        color: root.buttonColor
    }
}