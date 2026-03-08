// quickshell/components/widgets/Dashboard.qml
import QtQuick
import qs.components
import qs.shared

Panel {
    id: dashboardScope
    
    panelWidth: 800
    panelHeight: 400
    animationPreset: "slide"

    Column {
        anchors.fill: parent
        spacing: 20

        Text {
            text: "󰕮 Dashboard"
            color: Colors.foreground
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 18
            font.weight: Font.ExtraBold
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Rectangle { width: parent.width; height: 1; color: Colors.color8; opacity: 0.5 }
    }
}