// components/AppPreview.qml
pragma ComponentBehavior: Bound
    
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Io
import QtQuick
import QtQuick.Window
import qs.global

Scope {
    id: rootScope

    property var  targetApp: null
    property bool showPreview: false
    
    property real globalX: 0
    property real globalY: 0

    Connections {
        target: EventBus
        function onShowAppPreview(appData) {
            rootScope.targetApp = appData;
            cursorProcess.running = true;
        }
        function onHideAppPreview() {
            rootScope.showPreview = false;
        }
    }

    Process {
        id: cursorProcess
        command: ["hyprctl", "cursorpos"]
        running: false
        stdout: SplitParser {
            onRead: data => {
                let parts = data.split(",");
                if (parts.length === 2) {
                    rootScope.globalX = parseInt(parts[0].trim());
                    rootScope.globalY = parseInt(parts[1].trim());
                    rootScope.showPreview = true;
                }
            }
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: window
            required property var modelData
            screen: modelData
            
            property var hyprMonitor: {
                let m = Hyprland.monitors.values;
                return m ? m.find(mon => mon.name === window.screen.name) : null;
            }

            readonly property real sX: hyprMonitor ? hyprMonitor.x : 0
            readonly property real sY: hyprMonitor ? hyprMonitor.y : 0
            readonly property real sW: hyprMonitor ? (hyprMonitor.width / hyprMonitor.scale) : 1920
            readonly property real sH: hyprMonitor ? (hyprMonitor.height / hyprMonitor.scale) : 1080
            
            readonly property bool isActiveScreen: 
                rootScope.globalX >= sX && rootScope.globalX <= (sX + sW) &&
                rootScope.globalY >= sY && rootScope.globalY <= (sY + sH)

            visible: rootScope.showPreview && window.isActiveScreen
            color: "transparent"
            
            WlrLayershell.layer: WlrLayer.Overlay
            exclusionMode: ExclusionMode.Ignore
            WlrLayershell.namespace: "quickshell-app-preview"
            
            anchors { top: true; left: true; bottom: false; right: false }
            
            property real localX: rootScope.globalX - sX
            property real localY: rootScope.globalY - sY
            
            property real yOffset: Config.navbarLocation === "top" ? 30 : (Config.navbarLocation === "bottom" ? -menuContainer.height - 30 : -menuContainer.height / 2)
            property real xOffset: Config.navbarLocation === "left" ? 30 : (Config.navbarLocation === "right" ? -menuContainer.width - 30 : -menuContainer.width / 2)
            
            margins.left: Math.min(Math.max(10, localX + xOffset), sW - menuContainer.width - 10)
            margins.top:  Math.min(Math.max(10, localY + yOffset), sH - menuContainer.height - 10)
            
            width: menuContainer.width
            height: menuContainer.height
            
            Item {
                id: menuContainer
                
                property real aspect: {
                    if (rootScope.targetApp && rootScope.targetApp.size && rootScope.targetApp.size.width > 0) {
                        return rootScope.targetApp.size.height / rootScope.targetApp.size.width;
                    }
                    return 0.5625;
                }
                
                property real calcHeight: 280 * aspect
                property real clampedHeight: Math.min(Math.max(calcHeight, 100), 400)
                
                width: clampedHeight / aspect
                height: clampedHeight
                
                readonly property bool shouldShow: rootScope.showPreview && window.isActiveScreen && rootScope.targetApp !== null
                
                scale: shouldShow ? 1.0 : 0.95
                opacity: shouldShow ? 1.0 : 0.0
                
                Behavior on scale   { NumberAnimation { duration: 150; easing.type: Easing.OutBack } }
                Behavior on opacity { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
                Behavior on width   { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
                Behavior on height  { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
                
                Rectangle {
                    anchors.fill: parent
                    color: Colors.color0
                    border.color: Colors.color13
                    border.width: 2
                    radius: 8
                    clip: true
                    
                    Item {
                        anchors.fill: parent
                        anchors.margins: 2 
                        
                        ScreencopyView {
                            anchors.centerIn: parent
                            width: parent.width
                            height: parent.height
                            captureSource: rootScope.targetApp ? rootScope.targetApp.wayland : null
                            live: true
                        }
                    }
                }
            }
        }
    }
}