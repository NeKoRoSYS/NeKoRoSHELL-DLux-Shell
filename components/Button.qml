import QtQuick

Rectangle {
    id: root
    signal buttonClicked()

    property string style: "circle"
    property string labelText
    property string labelFont
    property string labelColor
    property real buttonSize: parent.height / 1.65
    property color buttonColor

    height: buttonSize
    width: {
        if (style == "circle") height
    }
    radius: height / 2
    color: buttonColor
    
    Text {
        id: label
        anchors.centerIn: parent
        anchors.horizontalCenterOffset: 1
        anchors.verticalCenterOffset: 1
        text: root.labelText
        font.family: root.labelFont
        color: labelColor
        font.pixelSize: parent.height / 1.75
    }

    MouseArea {
        id: mouseArea
        hoverEnabled: true
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.buttonClicked()
    }
}