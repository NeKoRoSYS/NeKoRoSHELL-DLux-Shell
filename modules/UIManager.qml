import Quickshell
import "../components"
import "../shared"

Scope {
    id: root
    property real navbarSize: 35
    property real fontSize: 12

    Bar {
        barColor: Colors.background
        barSize: root.navbarSize
        fontSize: root.fontSize
    }

    ScreenBorder {
        borderColor: Colors.background
        borderWidth: 13
        cornerRadius: 20
    }

    AudioVisualizer {}
}