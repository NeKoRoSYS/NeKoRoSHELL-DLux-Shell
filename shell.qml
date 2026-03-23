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
        targetScreen: shell.activeScreen
    }

    AppPreview {}

    Variants {
        model: Quickshell.screens

        PanelWindow {
            required property var modelData
            screen: modelData

            anchors { top: true; right: true }
            
            margins {
                top:    (Config.navbarLocation === "top"    ? loader.barSize : 0) + 15
                bottom: (Config.navbarLocation === "bottom" ? loader.barSize : 0) + 15
                left:   (Config.navbarLocation === "left"   ? loader.barSize : 0) + 15
                right:  (Config.navbarLocation === "right"  ? loader.barSize : 0) + 15
            }
            
            WlrLayershell.layer: WlrLayer.Overlay
            exclusionMode: ExclusionMode.Ignore
            
            color: "transparent"
            visible: Notifs.activePopups.count > 0
            
            width: 400
            height: Math.max(1, popupList.contentHeight)

            ListView {
                id: popupList
                
                width: parent.width
                height: contentHeight
                
                spacing: 15
                interactive: false
                
                model: Notifs.activePopups
                
                add: Transition {
                    NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 250 }
                    NumberAnimation { property: "x"; from: 50; to: 0; duration: 250; easing.type: Easing.OutBack }
                }
                remove: Transition {
                    NumberAnimation { property: "opacity"; to: 0; duration: 200 }
                }
                displaced: Transition {
                    NumberAnimation { properties: "x,y"; duration: 250; easing.type: Easing.OutCubic }
                }

                delegate: NotificationCard {
                    id: card
                    notification: model.notif 
                    
                    Timer {
                        running: true
                        interval: (notification && notification.expireTimeout > 0) ? notification.expireTimeout : 5000
                        onTriggered: Notifs.removePopup(notification) 
                    }

                    Connections {
                        target: notification
                        function onClosed() {
                            Notifs.removePopup(notification)
                        }
                    }
                }
            }
        }
    }

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

    Component.onCompleted: {
        console.log("Notification Daemon Active: " + Notifs.bodySupported)
        let extra = [
            "/usr/share/pixmaps",
            Qt.resolvedUrl("file://" + Quickshell.env("HOME") + "/.local/share/icons"),
            Qt.resolvedUrl("file://" + Quickshell.env("HOME") + "/.icons"),
        ]
        
        let currentPaths = Qt.iconSearchPaths ?? [];
        let newPaths = currentPaths.slice(); 
        let needsUpdate = false;
        
        for (let p of extra) {
            if (!newPaths.includes(p)) {
                newPaths.push(p);
                needsUpdate = true;
            }
        }
        
        if (needsUpdate) {
            Qt.iconSearchPaths = newPaths;
        }
    }
}