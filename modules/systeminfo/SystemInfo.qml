// modules/systeminfo/SystemInfo.qml
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.globals

QtObject {
    id: root
    readonly property string moduleType: "dynamic"

    readonly property var items: {
        let out = [
            {
                icon:      "󰍛",
                label:     root.cpuPercent + "%",
                bgColor:   Colors.color0,
                onClicked: function() { root.openMonitor() }
            },
            {
                icon:      "󰏈",
                label:     root.tempC + "°C",
                bgColor:   root.tempC >= 80 ? Colors.color1 : Colors.color0, // Turns red if hot
                onClicked: function() { root.openMonitor() }
            },
            {
                icon:      "󰾆",
                label:     root.memPercent + "%",
                bgColor:   Colors.color0,
                onClicked: function() { root.openMonitor() }
            }
        ]
        if (root.gpuText !== "")
            out.push({
                icon:      "󰢮",
                label:     root.gpuText,
                bgColor:   Colors.color0,
                onClicked: function() { root.openMonitor() }
            })
        return out
    }

    property int    cpuPercent: 0
    property int    tempC:      0
    property int    memPercent: 0
    property string gpuText:    ""
    
    property int _prevIdle:  0
    property int _prevTotal: 0

    function openMonitor() {
        Quickshell.execDetached({ command: ["/bin/bash", "-l", "-c", "kitty -e btop"] })
    }

    property var _sysProc: Process {
        id: sysProc
        command: ["/bin/bash", "-c", "cat /proc/stat | head -1; echo '---'; cat /proc/meminfo; echo '---'; cat /sys/class/thermal/thermal_zone*/temp 2>/dev/null | head -1"]
        
        property string buf: ""
        stdout: SplitParser { onRead: (l) => { sysProc.buf += l + "\n" } }
        
        onExited: {
            let sections = sysProc.buf.split("---\n")
            
            // 1. CPU Percent
            if (sections[0]) {
                let parts = sections[0].trim().split(/\s+/).slice(1).map(Number)
                let idle  = parts[3] + (parts[4] || 0)
                let total = parts.reduce((a, b) => a + b, 0)
                let dI = idle - root._prevIdle, dT = total - root._prevTotal
                root.cpuPercent = dT > 0 ? Math.round((1 - dI / dT) * 100) : 0
                root._prevIdle = idle
                root._prevTotal = total
            }
            
            // 2. Memory
            if (sections[1]) {
                let lines = sections[1].split("\n")
                let val = (k) => { let l = lines.find(l => l.startsWith(k)); return l ? parseInt(l.split(/\s+/)[1]) : 0 }
                let tot = val("MemTotal:"), free = val("MemFree:"), buf = val("Buffers:"), cac = val("Cached:")
                root.memPercent = tot > 0 ? Math.round((tot - free - buf - cac) / tot * 100) : 0
            }
            
            // 3. CPU Temperature
            if (sections[2]) {
                let t = parseInt(sections[2].trim())
                if (!isNaN(t)) {
                    root.tempC = Math.round(t / 1000)
                }
            }
            
            sysProc.buf = ""
        }
    }
    
    property var _gpuProc: Process {
        id: gpuProc
        command: ["/bin/bash", "-l", "-c", "gpu-temp.sh 2>/dev/null"]
        property string buf: ""
        stdout: SplitParser { onRead: (l) => { gpuProc.buf = l.trim() } }
        onExited: { 
            root.gpuText = gpuProc.buf
            gpuProc.buf = "" 
        }
    }
    
    property var _sysTimer: Timer { interval: 1000; running: true; repeat: true; onTriggered: sysProc.running = true }
    property var _gpuTimer: Timer { interval: 1000; running: true; repeat: true; onTriggered: gpuProc.running = true }
    
    Component.onCompleted: { sysProc.running = true; gpuProc.running = true }
}