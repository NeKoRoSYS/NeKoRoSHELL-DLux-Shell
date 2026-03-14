// modules/systeminfo/SystemInfo.qml
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.global

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
        command: ["/bin/bash", "-c", `
            while true; do
                cpu=$(head -n 1 /proc/stat)
                mem=$(grep -E '^MemTotal:|^MemFree:|^Buffers:|^Cached:' /proc/meminfo | awk '{print $2}' | tr '\n' ' ')
                temp=$(cat /sys/class/thermal/thermal_zone*/temp 2>/dev/null | head -n 1)
                echo "$cpu | $mem | $temp"
                sleep 1
            done
        `]
        running: true

        stdout: SplitParser { 
            onRead: (line) => {
                let sections = line.trim().split(" | ")
                if (sections.length < 3) return
                
                // 1. CPU Percent
                let cpuParts = sections[0].trim().split(/\s+/).slice(1).map(Number)
                if (cpuParts.length >= 5) {
                    let idle  = cpuParts[3] + (cpuParts[4] || 0)
                    let total = cpuParts.reduce((a, b) => a + b, 0)
                    let dI = idle - root._prevIdle, dT = total - root._prevTotal
                    root.cpuPercent = dT > 0 ? Math.round((1 - dI / dT) * 100) : 0
                    root._prevIdle = idle
                    root._prevTotal = total
                }
                
                // 2. Memory
                let memParts = sections[1].trim().split(/\s+/).map(Number)
                if (memParts.length >= 4) {
                    let tot = memParts[0], free = memParts[1], buf = memParts[2] || 0, cac = memParts[3] || 0
                    root.memPercent = tot > 0 ? Math.round((tot - free - buf - cac) / tot * 100) : 0
                }
                
                // 3. CPU Temperature
                let t = parseInt(sections[2].trim())
                if (!isNaN(t)) {
                    root.tempC = Math.round(t / 1000)
                }
            } 
        }
    }
    
    property var _gpuProc: Process {
        id: gpuProc
        command: ["/bin/bash", "-c", "while true; do gpu-temp.sh 2>/dev/null; sleep 2; done"]
        running: true
        stdout: SplitParser { onRead: (l) => { root.gpuText = l.trim() } }
    }
    
    property var _sysTimer: Timer { interval: 1000; running: true; repeat: true; onTriggered: sysProc.running = true }
    property var _gpuTimer: Timer { interval: 1000; running: true; repeat: true; onTriggered: gpuProc.running = true }
    
    Component.onCompleted: { sysProc.running = true; gpuProc.running = true }
}