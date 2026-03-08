import QtQuick
import Quickshell
import Quickshell.Hyprland
import qs.shared

PanelWindow {
    id: blurPanel
    
    WlrLayershell.namespace: "blurred-panel"
    
    anchors.fill: true
    
    color: Qt.rgba(Colors.background.r, Colors.background.g, Colors.background.b, 0.4)
    
    visible: true

    Keys.onEscapePressed: visible = false

    Column {
        anchors.centerIn: parent
        Text {
            text: "NeKoRoSHELL"
            color: Colors.foreground
            font.pixelSize: 48
            font.weight: Font.Bold
        }
    }
}