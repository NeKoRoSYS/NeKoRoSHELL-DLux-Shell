// modules/network/Network.qml  — BACKEND + MODULE DESCRIPTOR
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.globals

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
    readonly property string icon: {
        if (!connected)  return "󰤮"
        if (isEthernet)  return "󰈀"
        return " "
    }
    readonly property string label: connected ? ssid : ""

    function openSettings() {
        Quickshell.execDetached({ command: ["/bin/bash", "-l", "-c", "nm-connection-editor"] })
    }

    property var _proc: Process {
        id: netProc
        command: ["/bin/bash", "-c",
            "ssid=$(iwgetid -r 2>/dev/null); " +
            "if [ -n \"$ssid\" ]; then echo \"wifi $ssid\"; " +
            "elif ip link show | grep -q 'state UP.*eth\\|state UP.*en'; then echo 'eth'; " +
            "else echo 'none'; fi"]
        property string _buf: ""
        stdout: SplitParser { onRead: (l) => { netProc._buf = l.trim() } }
        onExited: {
            let parts = _buf.split(" ")
            if (parts[0] === "wifi") {
                Network.connected  = true
                Network.isEthernet = false
                Network.ssid       = parts.slice(1).join(" ")
            } else if (parts[0] === "eth") {
                Network.connected  = true
                Network.isEthernet = true
                Network.ssid       = "eth"
            } else {
                Network.connected  = false
                Network.ssid       = ""
            }
            _buf = ""
        }
    }
    property var _timer: Timer { interval: 10000; running: true; repeat: true; onTriggered: netProc.running = true }
    Component.onCompleted: netProc.running = true
}
