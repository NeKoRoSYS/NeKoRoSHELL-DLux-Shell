// shell.qml — entry point
//@ pragma UseQApplication
import Quickshell
import QtQuick
import qs.globals
import qs.components
import qs.engine
import qs.panels

Scope {
    id: shell

    LayoutLoader { id: loader }

    Wallpaper { }

    ScreenBorder {
        enabled:      Config.enableBorders
        location:     Config.navbarLocation
        borderColor:  Colors.background
        borderWidth:  10
        cornerRadius: 20
    }

    property string activePanel: ""

    Dashboard {
        showPanel:    shell.activePanel === "dashboard"
        navbarOffset: loader.barSize
    }

    Settings {
        showPanel:      shell.activePanel === "theming"
        navbarOffset:   loader.barSize
        bordersEnabled: Config.enableBorders
        lightMode:      Config.lightMode
    }

    Tray {
        showPanel:    shell.activePanel === "tray"
        navbarOffset: loader.barSize
    }

    Connections {
        target: EventBus

        function onTogglePanel(panelId) {
            shell.activePanel = (shell.activePanel === panelId) ? "" : panelId
        }
        function onChangeLocation(newLocation) {
            Config.saveSetting("navbarLocation", newLocation)
        }
        function onToggleBorders(state) {
            Config.saveSetting("enableBorders", state)
        }
        function onChangeLayout(layoutName) {
            Config.saveSetting("activeLayout", layoutName)
        }
        function onToggleLightMode(state) {
            Config.saveSetting("lightMode", state)
            Colors.reloadColors()
        }
    }
}
