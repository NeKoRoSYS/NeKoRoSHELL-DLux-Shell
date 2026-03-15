// components/DynamicChip.qml
import QtQuick
import qs.global

Item {
    id: root

    property bool isHorizontal: Config.isHorizontal
    property real barThickness: Style.moduleSize
    property bool inPill:       false
    property var  items:        []
    property var  barScreen:    null

    implicitWidth:  grid.implicitWidth
    implicitHeight: grid.implicitHeight

    Grid {
        id: grid
        anchors.centerIn: parent
        
        rows: root.isHorizontal ? 1 : -1
        columns: root.isHorizontal ? -1 : 1
        spacing: root.isHorizontal ? 6 : 4
        
        Repeater {
            model: root.items
            delegate: Rectangle {
                required property var modelData
                
                readonly property color resolvedBg: Config.transparentNavbar ? Colors.background : Colors.color3
                readonly property color resolvedFg: Config.lightMode && Config.transparentNavbar ? "black" : "white"

                implicitWidth: root.isHorizontal ? 
                    (iconText.implicitWidth + labelText.implicitWidth + (iconText.visible && labelText.visible ? 5 : 0) + root.barThickness * 0.6) : root.barThickness
                implicitHeight: root.isHorizontal ? 
                    root.barThickness : (iconText.implicitHeight + labelText.implicitHeight + (iconText.visible && labelText.visible ? 2 : 0) + root.barThickness * 0.6)
                
                radius: root.isHorizontal ? height / 2 : root.barThickness / 2
                color: resolvedBg
                Behavior on color { ColorAnimation { duration: 150 } }

                Item {
                    anchors.centerIn: parent
                    width: root.isHorizontal ? 
                        (iconText.implicitWidth + labelText.implicitWidth + (iconText.visible && labelText.visible ? 5 : 0)) : Math.max(iconText.implicitWidth, labelText.implicitWidth)
                    height: root.isHorizontal ? 
                        Math.max(iconText.implicitHeight, labelText.implicitHeight) : (iconText.implicitHeight + labelText.implicitHeight)

                    Text {
                        id: iconText
                        visible: (modelData.icon ?? "") !== ""
                        text: modelData.icon ?? ""
                        font.family: Style.barFont
                        font.pixelSize: root.isHorizontal ? (root.barThickness * 0.55) : (root.barThickness * 0.40)
                        color: resolvedFg
                        
                        anchors.top: root.isHorizontal ? undefined : parent.top
                        anchors.left: root.isHorizontal ? parent.left : undefined
                        anchors.horizontalCenter: root.isHorizontal ? undefined : parent.horizontalCenter
                        anchors.verticalCenter: root.isHorizontal ? parent.verticalCenter : undefined
                    }

                    Text {
                        id: labelText
                        visible: (modelData.label ?? "") !== ""
                        text: modelData.label ?? ""
                        font.family: Style.barFont
                        font.pixelSize: root.isHorizontal ? (root.barThickness * 0.48) : (root.barThickness * 0.34)
                        font.weight: Font.Bold
                        color: resolvedFg
                        
                        anchors.top: root.isHorizontal ? undefined : iconText.bottom
                        anchors.left: root.isHorizontal ? (iconText.visible ? iconText.right : parent.left) : undefined
                        anchors.leftMargin: root.isHorizontal && iconText.visible ? 5 : 0
                        anchors.topMargin: !root.isHorizontal && iconText.visible ? 2 : 0
                        anchors.horizontalCenter: root.isHorizontal ? undefined : parent.horizontalCenter
                        anchors.verticalCenter: root.isHorizontal ? parent.verticalCenter : undefined
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    onClicked: (e) => {
                        if (e.button === Qt.RightButton) {
                            if (modelData.onRightClicked) modelData.onRightClicked(root.barScreen, e)
                        } else {
                            if (modelData.onClicked) modelData.onClicked(root.barScreen, e)
                        }
                    }
                    onWheel: (e) => { 
                        if (modelData.onScrolled) modelData.onScrolled(e.angleDelta.y > 0 ? 1 : -1, e) 
                    }
                }
            }
        }
    }
}