import Quickshell
import qs.components
import qs.shared

Scope {
    id: root
    property string navbarLocation: "top"
    property bool enableBorders: true
    property real navbarSize: 40
    property real fontSize: 12
    property real borderWidth: 10
    property real cornerRadius: 20

    property bool isPanelOpen: false

    ScreenBorder {
        enabled: enableBorders
        location: root.navbarLocation
        borderColor: Colors.background
        borderWidth: root.borderWidth
        cornerRadius: root.cornerRadius

        Navbar {
            location: root.navbarLocation
            barColor: Colors.background
            barSize: root.navbarSize
            fontSize: root.fontSize

            onToggleSettingsPanel: {
                root.isPanelOpen = !root.isPanelOpen
            }
        }
    }

    SettingsPanel {
        showPanel: root.isPanelOpen
        bordersEnabled: root.enableBorders
        
        onLocationSelected: (newLocation) => {
            root.navbarLocation = newLocation
        }

        onBordersToggled: (state) => {
            root.enableBorders = state
        }
    }
}