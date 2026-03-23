// components/ContextMenu.qml
pragma ComponentBehavior: Bound
    
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import QtQuick
import QtQuick.Window
import qs.global

Scope {
    id: rootScope

    property string menuId: ""
    property bool   showMenu: false
    
    property real   globalX: 0
    property real   globalY: 0
    
    default property Component menuContent

    Connections {
        target: EventBus
        function onToggleContextMenu(id) {
            if (id === rootScope.menuId) {
                if (rootScope.showMenu) {
                    rootScope.showMenu = false;
                    EventBus.activeContextMenu = "";
                } else {
                    cursorProcess.running = true;
                    EventBus.activeContextMenu = id;
                }
            } else {
                rootScope.showMenu = false;
            }
        }
    }

    Process {
        id: cursorProcess
        command: ["hyprctl", "cursorpos", "-j"]
        running: false
        stdout: SplitParser {
            onRead: data => {
                try {
                    let pos = JSON.parse(data);
                    rootScope.globalX = pos.x;
                    rootScope.globalY = pos.y;
                    rootScope.showMenu = true;
                } catch(e) { }
            }
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: window
            required property var modelData
            screen: modelData
            
            readonly property real sX: Screen.virtualX
            readonly property real sY: Screen.virtualY
            readonly property real sW: Screen.width
            readonly property real sH: Screen.height
            
            readonly property bool isActiveScreen: 
                rootScope.globalX >= sX &&
                rootScope.globalX <= (sX + sW) &&
                rootScope.globalY >= sY &&
                rootScope.globalY <= (sY + sH)

            visible: rootScope.showMenu && isActiveScreen
            color: "transparent"
            
            WlrLayershell.layer: WlrLayer.Overlay
            exclusionMode: ExclusionMode.Ignore
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
            WlrLayershell.namespace: "quickshell-ctx-" + rootScope.menuId
            
            anchors { top: true; bottom: true; left: true; right: true }
            
            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onClicked: {
                    rootScope.showMenu = false;
                    EventBus.activeContextMenu = "";
                }
            }
            
            Item {
                id: menuContainer
                
                property real localX: rootScope.globalX - window.sX
                property real localY: rootScope.globalY - window.sY
                
                x: Math.min(Math.max(10, localX), window.width - width - 10)
                y: Math.min(Math.max(10, localY), window.height - height - 10)
                
                width: contentLoader.width
                height: contentLoader.height
                
                scale: rootScope.showMenu ? 1.0 : 0.95
                opacity: rootScope.showMenu ? 1.0 : 0.0
                
                Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutBack } }
                Behavior on opacity { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
                
                Rectangle {
                    anchors.fill: parent
                    color: Colors.color0
                    border.color: Colors.color13
                    border.width: 1
                    radius: Style.cornerRadius
                    clip: true
                }

                Loader {
                    id: contentLoader
                    sourceComponent: rootScope.menuContent
                }
            }
        }
    }
}