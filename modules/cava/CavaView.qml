// modules/cava/CavaView.qml
import QtQuick
import qs.global

Item {
    id: root
    property bool   isHorizontal: true
    property real   barThickness: 28
    property bool   inPill:       false
    property string barFont:      "JetBrainsMono Nerd Font"

    visible:        Cava.present
    
    implicitWidth:  visible ? (root.isHorizontal ? label.implicitWidth + 20 : root.barThickness) : 0
    implicitHeight: visible ? (root.isHorizontal ? root.barThickness : label.implicitWidth + 20) : 0

    Text {
        id: label
        anchors.centerIn: parent
        text:           Cava.bars
        color:          Colors.foreground
        font.family:    root.barFont
        font.pixelSize: root.barThickness * 0.55
        rotation: root.isHorizontal 
            ? 0 
            : (Config.navbarLocation === "right" ? 90 : -90)
    }
}