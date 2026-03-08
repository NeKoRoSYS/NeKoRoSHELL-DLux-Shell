// quickshell/components/widgets/navbar/ButtonsRow.qml
import QtQuick
import Quickshell
import qs.components
import qs.shared

Item {
    id: root
    
    readonly property bool isSide: !navbar.isHorizontal
    readonly property real baseSize: (isSide ? parent.width : parent.height) / 1.65

    implicitWidth: isSide ? parent.width : (container.implicitWidth + 15)
    implicitHeight: isSide ? (container.implicitHeight + 15) : parent.height

    Rectangle {
        anchors.centerIn: parent
        width: root.isSide ? root.baseSize : (container.implicitWidth + 15)
        height: root.isSide ? (container.implicitHeight + 15) : root.baseSize
        radius: (root.isSide ? width : height) / 2
        
        color: Colors.color5
        opacity: 0.325
    }

    Grid {
        id: container
        anchors.centerIn: parent
        spacing: 13
        
        columns: root.isSide ? 1 : 0
        rows: root.isSide ? 0 : 1

        Button {
            id: notif
            labelText: "󰂚"
            labelFont: navbar.font
            labelColor: Colors.foreground
            buttonSize: root.baseSize
            buttonColor: Colors.color3
            onButtonClicked: {
                Quickshell.execDetached({
                    command: ["swaync-client", "-t"]
                })
            }
        }

        Button {
            id: settings
            labelText: ""
            labelFont: navbar.font
            labelColor: Colors.foreground
            buttonSize: root.baseSize
            buttonColor: Colors.color3
            onButtonClicked: EventBus.togglePanel("theming")
        }

        Button {
            id: power
            labelText: "⏻"
            labelFont: navbar.font
            labelColor: Colors.foreground
            buttonSize: root.baseSize
            buttonColor: Colors.color3
            onButtonClicked: {
                Quickshell.execDetached({
                    command: ["wlogout"]
                })
            }
        }
    }
}