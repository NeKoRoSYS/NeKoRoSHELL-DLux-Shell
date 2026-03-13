// modules/workspaces/Workspaces.qml
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Hyprland
import qs.globals

QtObject {
    readonly property var workspaces: Hyprland.workspaces

    function activate(ws)      { ws.activate() }
    function focusWindow(addr) { Hyprland.dispatch("focuswindow address:0x" + addr) }

    function iconFor(toplevel) {
        let appClass = ""
        if (toplevel.wayland && toplevel.wayland.appId) {
            appClass = toplevel.wayland.appId
        } else {
            let ipc = toplevel.lastIpcObject || {}
            appClass = (ipc["class"] || ipc["initialClass"] || toplevel.title || "?")
        }
        return Icons.getIcon(appClass)
    }
}