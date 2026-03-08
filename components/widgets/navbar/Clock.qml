// quickshell/components/widgets/navbar/Clock.qml
import QtQuick
import qs.shared

Item {
    id: root
    
    property string location: "top"
    property alias clockFont: label.font.family
    property alias clockSize: label.font.pixelSize

    readonly property bool isSide: !navbar.isHorizontal

    Text {
        id: timeMetrics
        text: Time.time
        font.family: label.font.family
        font.pixelSize: label.font.pixelSize
        font.weight: label.font.weight
        visible: false
    }

    implicitWidth: isSide ? (timeMetrics.implicitHeight + 30) : (timeMetrics.implicitWidth + 30)
    implicitHeight: isSide ? (timeMetrics.implicitWidth + 30) : (timeMetrics.implicitHeight + 30)

    Rectangle {
        id: pill
        anchors.centerIn: parent
        
        readonly property real thickness: (root.isSide ? parent.parent.width : parent.parent.height) / 1.65
        readonly property real length: timeMetrics.implicitWidth + 30

        width: root.isSide ? thickness : length
        height: root.isSide ? length : thickness
        radius: (root.isSide ? width : height) / 2

        color: mouseArea.containsMouse ? Colors.foreground : Colors.color3
        Behavior on color { ColorAnimation { duration: 150 } }
        
        Text {
            id: label
            anchors.centerIn: parent
            rotation: root.location === "left" ? -90 : (root.location === "right" ? 90 : 0)
            
            color: mouseArea.containsMouse ? Colors.background : Colors.foreground 
            text: mouseArea.containsMouse ? "󰣇" : Time.time
            font.weight: Font.ExtraBold
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        MouseArea {
            id: mouseArea
            hoverEnabled: true
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: EventBus.togglePanel("dashboard")
        }
    }
}