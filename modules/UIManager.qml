import Quickshell
import "../components"
import "../components/widgets"
import "../shared"

Scope {
    id: root
    property string navbarLocation: "top"
    property real navbarSize: 40
    property real fontSize: 12
    property real borderWidth: 10
    property real cornerRadius: 20

    property bool isPanelOpen: false

    Bar {
        location: root.navbarLocation
        barColor: Colors.background
        barSize: root.navbarSize
        fontSize: root.fontSize

        onToggleSettingsPanel: {
            root.isPanelOpen = !root.isPanelOpen
        }
    }

    ScreenBorder {
        location: root.navbarLocation
        borderColor: Colors.background
        borderWidth: root.borderWidth
        cornerRadius: root.cornerRadius
    }

    PositionPanel {
        showPanel: root.isPanelOpen
        
        onLocationSelected: (newLocation) => {
            root.navbarLocation = newLocation
            root.isPanelOpen = false 
        }
    }
}