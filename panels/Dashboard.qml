// panels/Dashboard.qml
import QtQuick
import qs.modules.music
import qs.components
import qs.global

Panel {
    id: dashboardPanel

    panelWidth:      800
    panelHeight:     475
    animationPreset: "slide"
    edgePadding:     15

    Rectangle {
        id: launcherRoot
        anchors.fill: parent
        color: "transparent"
        border.color: Colors.color13
        border.width: 2
        radius: 10
        clip: true
        Column {
            anchors.fill: parent
            anchors.margins: 15
            spacing: 15

            Item {
                width: parent.width
                height: 30 
                
                Text {
                    text:           "󰕮  Dashboard"
                    color:           Colors.foreground
                    font.family:     "JetBrainsMono Nerd Font"
                    font.pixelSize:  18
                    font.weight:     Font.ExtraBold
                    anchors.centerIn: parent 
                }
            }

            Rectangle { width: parent.width; height: 1; color: Colors.color8; opacity: 0.5 }

            Music { }
        }
    }
}
