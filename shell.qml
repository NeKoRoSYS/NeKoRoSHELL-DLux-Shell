// shell.qml — entry point
//@ pragma UseQApplication
import Quickshell
import Quickshell.Wayland
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

    Variants {
        model: Quickshell.screens

        PanelWindow {
            required property var modelData
            screen: modelData

            anchors { top: true; bottom: true; left: true; right: true }
            
            margins {
                top:    Config.navbarLocation === "top"    ? loader.barSize : 0
                bottom: Config.navbarLocation === "bottom" ? loader.barSize : 0
                left:   Config.navbarLocation === "left"   ? loader.barSize : 0
                right:  Config.navbarLocation === "right"  ? loader.barSize : 0
            }

            WlrLayershell.layer: WlrLayer.Top
            exclusionMode: ExclusionMode.Ignore
            
            color: "transparent"
            visible: shell.activePanel !== ""

            MouseArea {
                anchors.fill: parent
                onClicked: shell.activePanel = ""
            }
        }
    }

    Dashboard {
        showPanel:    shell.activePanel === "dashboard"
        navbarOffset: loader.barSize
    }

    Settings {
        showPanel:      shell.activePanel === "settings"
        navbarOffset:   loader.barSize
        bordersEnabled: Config.enableBorders
        lightMode:      Config.lightMode
    }

    Tray {
        showPanel:    shell.activePanel === "tray"
        navbarOffset: loader.barSize
    }
    
    WallpaperPicker {
        showPanel:    shell.activePanel === "wallpaper"
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
