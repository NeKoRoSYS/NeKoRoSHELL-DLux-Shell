// modules/network/Network.qml  — BACKEND + MODULE DESCRIPTOR
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.global

QtObject {
    readonly property string moduleType: "dynamic"

    readonly property var items: [
        {
            icon:      Network.icon,
            label:     Network.label,
            bgColor:   Network.connected ? Colors.color0 : Colors.color1,
            onClicked: function() { Network.openSettings() }
        }
    ]

    property string ssid:       ""
    property bool   connected:  false
    property bool   isEthernet: false
    property bool   wifiEnabled: true

    readonly property string icon: {
        if (isEthernet)   return "󰈀"
        if (!wifiEnabled) return "󰤭"
        if (!connected)   return "󰤮"
        return "󰤨"
    }
    readonly property string label: connected || isEthernet ? ssid : ""

    function toggleWifi() {
        let cmd = wifiEnabled ? "nmcli radio wifi off" : "nmcli radio wifi on"
        Quickshell.execDetached({ command: ["/bin/bash", "-c", cmd] })
        wifiEnabled = !wifiEnabled
        if (!wifiEnabled) {
            connected = false
            ssid = ""
        } else {
            Qt.callLater(() => { pollTimer.restart(); netProc.running = true })
        }
    }

    function openApplet() {
        Quickshell.execDetached({ command: ["/bin/bash", "-l", "-c", "nmgui"] })
    }

    function openSettings() {
        Quickshell.execDetached({ command: ["/bin/bash", "-l", "-c", "nm-connection-editor"] })
    }

    property var _proc: Process {
        id: netProc
        command: ["/bin/bash", "-c",
            "wifi=$(nmcli radio wifi 2>/dev/null); " +
            "ssid=$(iwgetid -r 2>/dev/null); " +
            "eth=$(ip link show | grep -c 'state UP.*eth\\|state UP.*en' 2>/dev/null); " +
            "if [ -n \"$ssid\" ]; then echo \"wifi $ssid\"; " +
            "elif [ \"$eth\" -gt 0 ]; then echo 'eth'; " +
            "elif [ \"$wifi\" = 'disabled' ]; then echo 'disabled'; " +
            "else echo 'none'; fi"]
        property string _buf: ""
        stdout: SplitParser { onRead: (l) => { netProc._buf = l.trim() } }
        onExited: {
            let parts = _buf.split(" ")
            if (parts[0] === "wifi") {
                Network.wifiEnabled = true
                Network.connected   = true
                Network.isEthernet  = false
                Network.ssid        = parts.slice(1).join(" ")
            } else if (parts[0] === "eth") {
                Network.connected   = true
                Network.isEthernet  = true
                Network.ssid        = "eth"
            } else if (parts[0] === "disabled") {
                Network.wifiEnabled = false
                Network.connected   = false
                Network.isEthernet  = false
                Network.ssid        = ""
            } else {
                Network.wifiEnabled = true
                Network.connected   = false
                Network.isEthernet  = false
                Network.ssid        = ""
            }
            _buf = ""
        }
    }
    property var _timer: Timer {
        id: pollTimer
        interval: 10000; running: true; repeat: true
        onTriggered: netProc.running = true
    }
    Component.onCompleted: netProc.running = true
}
