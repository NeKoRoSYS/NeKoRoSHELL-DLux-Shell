// panels/Dashboard.qml
import QtQuick
import qs.modules.music
import qs.components
import qs.globals

Panel {
    id: dashboardPanel

    panelWidth:      800
    panelHeight:     475
    animationPreset: "slide"

    Column {
        anchors.fill: parent
        spacing: 20

        Text {
            text:            "󰕮  Dashboard"
            color:           Colors.foreground
            font.family:     "JetBrainsMono Nerd Font"
            font.pixelSize:  18
            font.weight:     Font.ExtraBold
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Rectangle { width: parent.width; height: 1; color: Colors.color8; opacity: 0.5 }

        Text {
            text:           Time.date
            color:          Colors.color7
            font.family:    "JetBrainsMono Nerd Font"
            font.pixelSize: 14
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Rectangle { width: parent.width; height: 1; color: Colors.color8; opacity: 0.5 }

        Music { }
    }
}
