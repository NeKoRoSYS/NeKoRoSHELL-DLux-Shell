// components/StaticChip.qml

import QtQuick
import qs.global

Item {
    id: root

    property bool   isHorizontal: true
    property real   barThickness: 28
    property bool   inPill:       false
    property string barFont:      "JetBrainsMono Nerd Font"
    property var    barScreen:    null

    property var item: ({})

    implicitWidth:  barThickness
    implicitHeight: barThickness

    Rectangle {
        anchors.centerIn: parent
        width:  root.barThickness
        height: root.barThickness
        radius: height / 2

        readonly property color resolvedBg: mouseArea.containsMouse
            ? "white"
            : (root.inPill 
                ? (Config.transparentNavbar ? Colors.background : Colors.color3)
                : (root.item.active 
                    ? (Config.transparentNavbar ? Colors.background : Colors.color3)
                    : (Config.transparentNavbar ? Colors.background : Colors.color3)))

        color: resolvedBg
        Behavior on color { ColorAnimation { duration: 150 } }

        Text {
            anchors.centerIn: parent
            
            anchors.horizontalCenterOffset: root.item.xOffset ?? 1
            anchors.verticalCenterOffset: root.item.yOffset ?? 1

            text:           root.item.icon ?? ""
            font.family:    root.barFont
            font.pixelSize: root.barThickness * 0.6
            
            color: mouseArea.containsMouse
                ? (root.item.hoverFgColor ?? "black")
                : (root.inPill 
                    ? Config.lightMode && Config.transparentNavbar ? "black" : "white"
                    : (root.item.active
                        ? (Config.lightMode && Config.transparentNavbar ? "black" : "white")
                        : (root.item.fgColor ?? (Config.lightMode && Config.transparentNavbar) ? "black" : "white")))
            
            Behavior on color { ColorAnimation { duration: 150 } }
        }

        MouseArea {
            id: mouseArea
            anchors.fill:    parent
            cursorShape:     Qt.PointingHandCursor
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            hoverEnabled:    true 
            
            onClicked: (e) => {
                if (e.button === Qt.RightButton) {
                    if (root.item.onRightClicked) root.item.onRightClicked(root.barScreen, e)
                } else {
                    if (root.item.onClicked) root.item.onClicked(root.barScreen, e)
                }
            }
        }
    }
}