// quickshell/components/widgets/Workspaces.qml
import QtQuick
import Quickshell.Hyprland
import "../../shared"

ListView {
    id: root
    
    readonly property bool isSide: navbar.location === "left" || navbar.location === "right"
    orientation: isSide ? ListView.Vertical : ListView.Horizontal
    spacing: 13
    
    model: Hyprland.workspaces

    readonly property real delegateSize: (isSide ? parent.width : parent.height) / 1.65
    readonly property real minWorkspaces: 5
    readonly property real minCalculatedSize: (delegateSize * minWorkspaces) + (spacing * (minWorkspaces - 1))

    implicitWidth: isSide ? parent.width : Math.max(contentWidth, minCalculatedSize)
    implicitHeight: isSide ? Math.max(contentHeight, minCalculatedSize) : parent.height

    clip: false 

    delegate: Rectangle {
        required property var modelData
        
        anchors.horizontalCenter: isSide ? parent.horizontalCenter : undefined
        anchors.verticalCenter: isSide ? undefined : parent.verticalCenter
        
        height: root.delegateSize
        width: height
        radius: height / 2
        
        Text {
            id: label
            anchors.centerIn: parent
            text: modelData.focused ? "  " : modelData.name
            color: modelData.focused ? Colors.background : Colors.foreground
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 12
            font.weight: Font.ExtraBold
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: modelData.activate()
        }

        color: modelData.focused ? Colors.color7 : Colors.color5

        Behavior on color { ColorAnimation { duration: 150 } }
    }
}
