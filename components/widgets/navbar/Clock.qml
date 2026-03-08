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
        text: root.isSide ? Time.timeVertical : Time.time
        font.family: label.font.family
        font.pixelSize: label.font.pixelSize
        font.weight: label.font.weight
        lineHeight: 0.8
        visible: false
    }

    implicitWidth: isSide ? (timeMetrics.implicitHeight + 30) : (timeMetrics.implicitWidth + 30)
    implicitHeight: isSide ? (timeMetrics.implicitWidth + 30) : (timeMetrics.implicitHeight + 30)

    Rectangle {
        id: pill
        anchors.centerIn: parent
        
        readonly property real thickness: (root.isSide ? parent.width - 10 : parent.height) / 1.65
        readonly property real length: root.isSide ? (timeMetrics.implicitHeight + 20) : (timeMetrics.implicitWidth + 30)

        implicitWidth: root.isSide ? thickness : length
        implicitHeight: root.isSide ? length : thickness

        width: root.isSide ? thickness : length
        height: root.isSide ? length : thickness
        radius: (root.isSide ? width : height) / 2

        color: mouseArea.containsMouse ? "white" : Colors.color3
        Behavior on color { ColorAnimation { duration: 150 } }
        
        Text {
            id: label
            anchors.centerIn: parent
            
            text: mouseArea.containsMouse ? "󰣇" : (root.isSide ? Time.timeVertical : Time.time)
            color: mouseArea.containsMouse ? Colors.color5 : "white"
            
            font.weight: Font.ExtraBold
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            
            lineHeight: 0.8 
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