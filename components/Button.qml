// components/Button.qml
import QtQuick
import qs.globals

Rectangle {
    id: root

    signal buttonClicked()

    property string style: "circle"
    property string labelText
    property string labelFont
    property string labelColor: "white"
    property real buttonSize: parent.height / 1.65
    property color buttonColor

    height: buttonSize
    width:  style === "circle" ? height : implicitWidth
    radius: height / 2
    
    color: mouseArea.containsMouse ? "white" : root.buttonColor
    Behavior on color { ColorAnimation { duration: 150 } }

    Text {
        id: label
        anchors.centerIn: parent
        anchors.horizontalCenterOffset: 1
        anchors.verticalCenterOffset: 1
        text:             root.labelText
        font.family:      root.labelFont
        color:            mouseArea.containsMouse ? "black" : root.labelColor
        Behavior on color { ColorAnimation { duration: 150 } }
        font.pixelSize:   parent.height / 1.75
    }

    MouseArea {
        id: mouseArea
        hoverEnabled: true
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.buttonClicked()
    }
}
