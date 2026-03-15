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
                enabled: shell.activePanel !== ""
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
        anchorEdge: "center"
    }

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
            visible: Notifs.activePopups.length > 0
            
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
                    notification: modelData 
                    
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
        let extra = [
            "/usr/share/pixmaps",
            Qt.resolvedUrl("file://" + Quickshell.env("HOME") + "/.local/share/icons"),
            Qt.resolvedUrl("file://" + Quickshell.env("HOME") + "/.icons"),
        ]
        for (let p of extra) {
            if (!(Qt.iconSearchPaths ?? []).includes(p))
                Qt.iconSearchPaths = (Qt.iconSearchPaths ?? []).concat([p])
        }
    }
}