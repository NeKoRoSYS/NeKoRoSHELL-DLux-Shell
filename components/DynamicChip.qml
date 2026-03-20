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

    implicitWidth:  isHorizontal ? hRow.implicitWidth : barThickness
    implicitHeight: isHorizontal ? barThickness       : vCol.implicitHeight

    component ChipDelegate: Rectangle {
        required property var modelData

        readonly property color resolvedBg: Config.transparentNavbar ? Colors.background : Colors.color3
        readonly property color resolvedFg: Config.lightMode && Config.transparentNavbar ? "black" : "white"

        implicitWidth:  root.isHorizontal ? (hInner.implicitWidth + root.barThickness * 0.6) : root.barThickness
        implicitHeight: root.isHorizontal ? root.barThickness : (vInner.implicitHeight + root.barThickness * 0.6)
        radius: root.isHorizontal ? height / 2 : (root.inPill ? 0 : root.barThickness / 2)
        color:  resolvedBg
        Behavior on color { ColorAnimation { duration: 150 } }

        // ── Horizontal: icon beside label ─────────────────────────────────
        Row {
            id: hInner
            visible:          root.isHorizontal
            anchors.centerIn: parent
            spacing: 5

            Text {
                visible:        (modelData.icon ?? "") !== ""
                text:           modelData.icon ?? ""
                font.family:    Style.barFont
                font.pixelSize: root.barThickness * 0.55
                color:          resolvedFg
                anchors.verticalCenter: parent.verticalCenter
            }
            Text {
                visible:        (modelData.label ?? "") !== ""
                text:           modelData.label ?? ""
                font.family:    Style.barFont
                font.pixelSize: root.barThickness * 0.48
                font.weight:    Font.Bold
                color:          resolvedFg
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        // ── Vertical: icon over label, both centered independently ────────
        Column {
            id: vInner
            visible:          !root.isHorizontal
            anchors.centerIn: parent
            spacing: 0

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text:           modelData.icon ?? ""
                font.family:    Style.barFont
                font.pixelSize: root.barThickness * 0.40
                color:          resolvedFg
            }
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text:           modelData.label ?? ""
                font.family:    Style.barFont
                font.pixelSize: root.barThickness * 0.34
                font.weight:    Font.Bold
                color:          resolvedFg
            }
        }

        MouseArea {
            anchors.fill:    parent
            cursorShape:     Qt.PointingHandCursor
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            onClicked: (e) => {
                    if (e.button === Qt.RightButton) {
                        if (modelData.onRightClicked) modelData.onRightClicked(root.barScreen)
                    } else {
                        if (modelData.onClicked) modelData.onClicked(root.barScreen)
                    }
                }
            onWheel:         (e) => { if (modelData.onScrolled) modelData.onScrolled(e.angleDelta.y > 0 ? 1 : -1) }
        }
    }

    Row {
        id: hRow
        visible:          root.isHorizontal
        anchors.centerIn: parent
        spacing: 6
        Repeater { model: root.isHorizontal ? root.items : []; delegate: ChipDelegate {} }
    }

    Column {
        id: vCol
        visible:          !root.isHorizontal
        anchors.centerIn: parent
        spacing: 4
        Repeater { model: root.isHorizontal ? [] : root.items; delegate: ChipDelegate {} }
    }
}
