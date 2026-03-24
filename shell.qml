// shell.qml — entry point
//@ pragma UseQApplication
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Notifications
import QtQuick
import qs.global
import qs.components
import qs.engine
import qs.panels

Scope {
    id: shell

    LayoutLoader { id: loader }

    Wallpaper { }

    ScreenBorder {
        enabled:      Config.enableBorders && !Config.transparentNavbar
        location:     Config.navbarLocation
        borderColor:  Colors.background
        borderWidth:  Style.borderWidth
        cornerRadius: Style.cornerRadius
    }

    NotificationsToast {
        allowToasts: shell.activePanel !== "notifications"
    }

    property string activePanel: ""
    property var    activeScreen: null

    Dashboard {
        showPanel:    shell.activePanel === "dashboard"
        navbarOffset: loader.barSize
        panelId:      "dashboard"
        anchorEdge: "top"
        anchorAlignment: "center"
    }

    Settings {
        showPanel:      shell.activePanel === "settings"
        navbarOffset:   loader.barSize
        panelId:      "settings"
        bordersEnabled: Config.enableBorders
        lightMode:      Config.lightMode
        anchorAlignment: "end"
    }

    AdvancedSettings {
        showPanel:    shell.activePanel === "advanced"
        navbarOffset: loader.barSize
        panelId:      "advanced"
        anchorAlignment: "end"
    }

    Tray {
        showPanel:    shell.activePanel === "tray"
        navbarOffset: loader.barSize
        panelId:      "tray"
        anchorAlignment: "end"
    }

    Launcher {
        showPanel:    shell.activePanel === "launcher"
        navbarOffset: loader.barSize
        panelId:      "launcher"
        anchorEdge: "bottom"
        anchorAlignment: "center"
    }
    
    WallpaperPicker {
        showPanel:    shell.activePanel === "wallpaper"
        navbarOffset: loader.barSize
        panelId:      "wallpaper"
        anchorEdge: "bottom"
        anchorAlignment: "center"
    }

    Clipboard {
        showPanel:    shell.activePanel === "clipboard"
        navbarOffset: loader.barSize
        panelId:      "clipboard"
        anchorAlignment: "center"
    }

    Notifications {
        showPanel:    shell.activePanel === "notifications"
        navbarOffset: loader.barSize
        panelId:      "notifications"
        anchorEdge: "right"
        anchorAlignment: "center"
    }

    Overview {
        showPanel:    shell.activePanel === "overview"
        navbarOffset: loader.barSize
        panelId:      "overview"
        anchorEdge: "center"
    }

    PowerManager {
        showPanel:    shell.activePanel === "power"
    }

    AppPreview {}

    Connections {
        target: EventBus

        function onTogglePanel(panelId, screen) {
            if (shell.activePanel === panelId) {
                shell.activePanel = ""
                shell.activeScreen = null
            } else {
                shell.activePanel = panelId
                shell.activeScreen = screen
            }
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