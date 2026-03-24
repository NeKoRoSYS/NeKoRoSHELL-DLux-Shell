// shell.qml — entry point
//@ pragma UseQApplication
import Quickshell
import Quickshell.Hyprland
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

    NotificationsToast { allowToasts: shell.activePanel !== "notifications" }

    AppPreview { }

    property string activePanel: "calendar"
    property var    activeScreen: Quickshell.screens.length > 0 ? Quickshell.screens[0] : null

    Instantiator {
        model: PanelRegistry.allPanels
        delegate: Loader {
            id: panelLoader
            source: modelData.file
            
            function resolveTargetScreen(screenConfig, currentActiveScreen, hMonitor) {
                if (screenConfig && screenConfig !== "active") {
                    for (let i = 0; i < Quickshell.screens.length; i++) {
                        if (Quickshell.screens[i].name === screenConfig) {
                            return Quickshell.screens[i];
                        }
                    }
                }
                
                if (currentActiveScreen) { return currentActiveScreen; }
                
                if (hMonitor && hMonitor.name) {
                    for (let j = 0; j < Quickshell.screens.length; j++) {
                        if (Quickshell.screens[j].name === hMonitor.name) {
                            return Quickshell.screens[j];
                        }
                    }
                }
                
                return Quickshell.screens.length > 0 ? Quickshell.screens[0] : null;
            }

            onLoaded: {
                if (!item) return;
                if ("panelId" in item) item.panelId = modelData.id;
                if ("anchorEdge" in item && modelData.anchor !== undefined) item.anchorEdge = modelData.anchor;
                if ("anchorAlignment" in item && modelData.align !== undefined) item.anchorAlignment = modelData.align;
                if ("showPanel" in item) item.showPanel = Qt.binding(() => shell.activePanel === modelData.id);
                if ("navbarOffset" in item) item.navbarOffset = Qt.binding(() => loader.barSize);
                if ("targetScreen" in item) { item.targetScreen = Qt.binding(() => resolveTargetScreen(modelData.screen, Hyprland.focusedMonitor)); }
                if (modelData.id === "settings") {
                    if ("bordersEnabled" in item) item.bordersEnabled = Qt.binding(() => Config.enableBorders);
                    if ("lightMode" in item) item.lightMode = Qt.binding(() => Config.lightMode);
                }
            }
        }
    }

    Connections {
        target: EventBus

        function onTogglePanel(panelId, screen) {
            if (shell.activePanel === panelId) {
                shell.activePanel = "";
            } else {
                shell.activePanel = panelId;
                if (screen) { shell.activeScreen = screen; } else { shell.activeScreen = null; }
            }
        }

        function onChangeLocation(newLocation) { Config.saveSetting("navbarLocation", newLocation) }
        function onToggleBorders(state) { Config.saveSetting("enableBorders", state) }
        function onChangeLayout(layoutName) { Config.saveSetting("activeLayout", layoutName) }
        function onToggleLightMode(state) {
            Config.saveSetting("lightMode", state)
            Colors.reloadColors()
        }
    }
}