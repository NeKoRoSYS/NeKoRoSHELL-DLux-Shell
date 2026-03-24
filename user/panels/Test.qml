import QtQuick
import qs.global
import qs.components

Panel {
    id: testPanel
    
    panelWidth: 300
    panelHeight: 300
    animationPreset: "slide"

    panelContent: Component {
        Rectangle {
            anchors.fill: parent
            color: Colors.foreground
            radius: Style.cornerRadius
            
            Text {
                anchors.centerIn: parent
                text: "SANDBOX WORKS!"
                color: Colors.background
                font.pixelSize: 24
                font.bold: true
            }
        }
    }
}