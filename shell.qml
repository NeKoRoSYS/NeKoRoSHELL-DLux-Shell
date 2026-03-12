// shell.qml — entry point
//@ pragma UseQApplication
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Notifications
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
                onClicked: {
                    if (shell.activePanel !== "") {
                        EventBus.togglePanel(shell.activePanel) 
                    }
                }
            }
        }
    }

    Dashboard {
        showPanel:    shell.activePanel === "dashboard"
        navbarOffset: loader.barSize
        anchorEdge: "top"
        anchorAlignment: "center"
    }

    Settings {
        showPanel:      shell.activePanel === "settings"
        navbarOffset:   loader.barSize
        bordersEnabled: Config.enableBorders
        lightMode:      Config.lightMode
        anchorAlignment: "end"
    }

    Tray {
        showPanel:    shell.activePanel === "tray"
        navbarOffset: loader.barSize
        anchorAlignment: "end"
    }

    Launcher {
        showPanel:    shell.activePanel === "launcher"
        navbarOffset: loader.barSize
        anchorEdge: "bottom"
        anchorAlignment: "center"
    }
    
    WallpaperPicker {
        showPanel:    shell.activePanel === "wallpaper"
        navbarOffset: loader.barSize
        anchorEdge: "bottom"
        anchorAlignment: "center"
    }

    Notifications {
        showPanel:    shell.activePanel === "notifications"
        navbarOffset: loader.barSize
        anchorEdge: "right"
        anchorAlignment: "center"
    }

    Overview {
        showPanel:    shell.activePanel === "overview"
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

    Component.onCompleted: {
        console.log("Notification Daemon Active: " + Notifs.bodySupported)
    }
}
