import Quickshell
import QtQuick
import qs.components
import qs.components.widgets.panels
import qs.shared

Scope {
    id: root

    property real navbarSize: 40
    property real fontSize: 12
    property real borderWidth: 10
    property real cornerRadius: 20

    property string activePanel: ""

    Connections {
        target: EventBus
        
        function onTogglePanel(panelId) {
            if (root.activePanel === panelId) {
                root.activePanel = ""
            } else {
                root.activePanel = panelId
            }
        }
        
        function onChangeLocation(newLocation) {
            Config.saveSetting("navbarLocation", newLocation)
        }
        
        function onToggleBorders(state) {
            Config.saveSetting("enableBorders", state)
        }
        
        function onToggleLightMode(state) {
            Config.saveSetting("lightMode", state)
            Colors.reloadColors()
        }
    }

    ScreenBorder {
        enabled: Config.enableBorders 
        location: Config.navbarLocation
        borderColor: Colors.background
        borderWidth: root.borderWidth
        cornerRadius: root.cornerRadius

        Navbar {
            location: Config.navbarLocation
            barColor: Colors.background
            barSize: root.navbarSize
            fontSize: root.fontSize
        }
    }

    Theming {
        showPanel: root.activePanel === "theming"
        bordersEnabled: Config.enableBorders
        lightMode: Config.lightMode
        navbarOffset: root.navbarSize
    }

    Dashboard {
        showPanel: root.activePanel === "dashboard"
        navbarOffset: root.navbarSize
    }
}