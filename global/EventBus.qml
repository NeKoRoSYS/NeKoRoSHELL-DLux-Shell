// global/EventBus.qml
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    signal togglePanel(string panelId)
    signal changeLocation(string newLocation)
    signal changeLayout(string newLayout)
    signal toggleBorders(bool state)
    signal toggleLightMode(bool state)
    signal showAppPreview(var appData)
    signal hideAppPreview()

    property var ipc: IpcHandler {
        target: "nekoroshell"
        
        function toggle(panelId: string): void {
            EventBus.togglePanel(panelId)
        }

        function ctx(menuId: string): void {
            EventBus.toggleContextMenu(menuId)
        }
    }
}