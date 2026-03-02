import Quickshell
import "../components"
import "../shared"

Scope {
    id: root
    property string navbarLocation: "top"
    property real navbarSize: 35
    property real fontSize: 12
    property real borderWidth: 13
    property real cornerRadius: 20

    Bar {
        location: root.navbarLocation
        barColor: Colors.background
        barSize: root.navbarSize
        fontSize: root.fontSize
    }

    ScreenBorder {
        location: root.navbarLocation
        borderColor: Colors.background
        borderWidth: root.borderWidth
        cornerRadius: root.cornerRadius
    }
    
    AudioVisualizer {}
}