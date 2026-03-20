// modules/bluetooth/Bluetooth.qml — BACKEND + MODULE DESCRIPTOR
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.global

QtObject {
    readonly property string moduleType: "dynamic"

    readonly property var items: [
        {
            icon:      Bluetooth.icon,
            label:     Bluetooth.label,
            bgColor:   Bluetooth.connected ? Colors.color0 : Colors.color1,
            onClicked: function() { Bluetooth.openSettings() }
        }
    ]

    property bool   enabled:   false
    property bool   connected: false
    property string device:    ""

    readonly property string icon: {
        if (!enabled)  return "󰂲"
        if (!connected) return "󰂯"
        return "󰂱"
    }
    readonly property string label: connected ? device : ""

    function toggle() {
        let cmd = enabled ? "bluetoothctl power off" : "bluetoothctl power on"
        Quickshell.execDetached({ command: ["/bin/bash", "-c", cmd] })
        enabled = !enabled
        if (!enabled) {
            connected = false
            device = ""
        } else {
            Qt.callLater(() => { pollTimer.restart(); btProc.running = true })
        }
    }

    function openSettings() {
        Quickshell.execDetached({ command: ["/bin/bash", "-l", "-c", "blueman-manager"] })
    }

    property var _proc: Process {
        id: btProc
        command: ["/bin/bash", "-c",
            "power=$(bluetoothctl show 2>/dev/null | grep -i 'powered' | awk '{print $2}'); " +
            "dev=$(bluetoothctl info 2>/dev/null | grep -i 'name' | head -1 | sed 's/.*Name: //'); " +
            "if [ \"$power\" = 'yes' ]; then " +
            "  if [ -n \"$dev\" ]; then echo \"connected $dev\"; " +
            "  else echo 'on'; fi; " +
            "else echo 'off'; fi"]
        property string _buf: ""
        stdout: SplitParser { onRead: (l) => { btProc._buf = l.trim() } }
        onExited: {
            let parts = _buf.split(" ")
            if (parts[0] === "connected") {
                Bluetooth.enabled   = true
                Bluetooth.connected = true
                Bluetooth.device    = parts.slice(1).join(" ")
            } else if (parts[0] === "on") {
                Bluetooth.enabled   = true
                Bluetooth.connected = false
                Bluetooth.device    = ""
            } else {
                Bluetooth.enabled   = false
                Bluetooth.connected = false
                Bluetooth.device    = ""
            }
            _buf = ""
        }
    }
    property var _timer: Timer {
        id: pollTimer
        interval: 10000; running: true; repeat: true
        onTriggered: btProc.running = true
    }
    Component.onCompleted: btProc.running = true
}
