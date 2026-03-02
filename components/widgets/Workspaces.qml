// quickshell/components/widgets/Workspaces.qml
import QtQuick
import Quickshell.Hyprland
import "../../shared"
import "../../components"

ListView {
    id: root
    
    readonly property bool isSide: navbar.isVertical
    orientation: isSide ? ListView.Vertical : ListView.Horizontal
    spacing: 13
    
    model: Hyprland.workspaces

    readonly property real delegateSize: (isSide ? parent.width : parent.height) / 1.65
    readonly property real minWorkspaces: 5
    readonly property real minCalculatedSize: (delegateSize * minWorkspaces) + (spacing * (minWorkspaces - 1))

    implicitWidth: isSide ? parent.width : Math.max(contentWidth, minCalculatedSize)
    implicitHeight: isSide ? Math.max(contentHeight, minCalculatedSize) : parent.height

    clip: false 

    delegate: Item {
        required property var modelData

        width: root.isSide ? ListView.view.width : root.delegateSize
        height: root.isSide ? root.delegateSize : ListView.view.height

        Rectangle {
            anchors.centerIn: parent
            
            height: root.delegateSize
            width: height
            radius: height / 2
            
            color: modelData.focused ? Colors.color7 : Colors.color5
            Behavior on color { ColorAnimation { duration: 150 } }

            Text {
                id: label
                anchors.centerIn: parent
                text: modelData.focused ? "󰣇" : modelData.name
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
        }
    }
}