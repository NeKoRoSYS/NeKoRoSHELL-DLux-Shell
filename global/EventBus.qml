// global/EventBus.qml
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    signal togglePanel(string panelId, var screen)
    signal changeLocation(string newLocation)
    signal changeLayout(string newLayout)
    signal toggleBorders(bool state)
    signal toggleLightMode(bool state)
    signal showAppPreview(var appData)
    signal hideAppPreview()

    property var ipc: IpcHandler {
        target: "nekoroshell"
        
        function toggle(panelId: string): void {
            EventBus.togglePanel(panelId, null)
        }

        function toggleOn(panelId: string, monitorName: string): void {
            let targetMonitor = null;
            if (monitorName) {
                for (let i = 0; i < Quickshell.screens.length; i++) {
                    if (Quickshell.screens[i].name === monitorName) {
                        targetMonitor = Quickshell.screens[i];
                        break;
                    }
                }
            }
            EventBus.togglePanel(panelId, targetMonitor)
        }

        function ctx(menuId: string): void {
            EventBus.toggleContextMenu(menuId)
        }
    }
}