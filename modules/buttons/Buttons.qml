// modules/buttons/Buttons.qml
import QtQuick
import Quickshell
import qs.globals
import qs.components

Item {
    id: root

    // Injected by LayoutLoader
    property bool   isHorizontal: true
    property real   barThickness: 40
    property string barFont:      "JetBrainsMono Nerd Font"

    readonly property bool isSide: !root.isHorizontal
    readonly property real baseSize: root.barThickness / 1.65

    implicitWidth:  root.isHorizontal ? (container.implicitWidth + 15) : root.barThickness
    implicitHeight: root.isHorizontal ? root.barThickness : (container.implicitHeight + 15)

    Rectangle {
        anchors.centerIn: parent
        width:  root.isSide ? root.baseSize : (container.implicitWidth + 15)
        height: root.isSide ? (container.implicitHeight + 15) : root.baseSize
        radius: (root.isSide ? width : height) / 2
        
        color: Colors.color3
        opacity: 0.325
    }

    Flow {
        id: container
        anchors.centerIn: parent
        spacing: 13
        flow: root.isHorizontal ? Flow.LeftToRight : Flow.TopToBottom

        Button {
            labelText:   "󱊣"
            labelFont:   root.barFont
            buttonSize:  root.baseSize
            buttonColor: Colors.color3
            onButtonClicked: EventBus.togglePanel("tray")
        }

        Button {
            labelText:   "󰂚"
            labelFont:   root.barFont
            buttonSize:  root.baseSize
            buttonColor: Colors.color3
            onButtonClicked: EventBus.togglePanel("notifications")
        }

        Button {
            labelText:   ""
            labelFont:   root.barFont
            buttonSize:  root.baseSize
            buttonColor: Colors.color3
            onButtonClicked: EventBus.togglePanel("settings")
        }

        Button {
            labelText:   "⏻"
            labelFont:   root.barFont
            buttonSize:  root.baseSize
            buttonColor: Colors.color3
            onButtonClicked: Quickshell.execDetached({ command: ["wlogout"] })
        }
    }
}