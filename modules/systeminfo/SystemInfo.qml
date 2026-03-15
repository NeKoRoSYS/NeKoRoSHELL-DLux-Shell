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
                icon:      "蟀崨",
                label:     root.cpuPercent + "%",
                bgColor:   Colors.color0,
                onClicked: function() { root.openMonitor() }
            },
            {
                icon:      "蟀張",
                label:     root.tempC + "掳C",
                bgColor:   root.tempC >= 80 ? Colors.color1 : Colors.color0,
                onClicked: function() { root.openMonitor() }
            },
            {
                icon:      "蟀締",
                label:     root.memPercent + "%",
                bgColor:   Colors.color0,
                onClicked: function() { root.openMonitor() }
            }
        ]
        if (root.gpuText !== "")
            out.push({
                icon:      "蟀",
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
        command: ["/bin/bash", "-c", "cat /proc/stat /proc/meminfo /sys/class/thermal/thermal_zone*/temp 2>/dev/null"]
        
        property string _buf: ""
        stdout: SplitParser { 
            onRead: (line) => { sysProc._buf += line + "\n" } 
        }
        
        onExited: {
            let lines = _buf.split("\n")
            sysProc._buf = "" 
            if (lines.length < 5) return
            
            // 1. CPU Parsing
            let cpuLine = lines.find(l => l.startsWith("cpu "))
            if (cpuLine) {
                let cpuParts = cpuLine.trim().split(/\s+/).slice(1).map(Number)
                let idle  = cpuParts[3] + (cpuParts[4] || 0)
                let total = cpuParts.reduce((a, b) => a + b, 0)
                let dI = idle - root._prevIdle, dT = total - root._prevTotal
                root.cpuPercent = dT > 0 ? Math.round((1 - dI / dT) * 100) : 0
                root._prevIdle = idle
                root._prevTotal = total
            }
            
            // 2. Memory Parsing
            let memTotal = 0, memFree = 0, memBuf = 0, memCac = 0
            for (let i = 0; i < lines.length; i++) {
                if (lines[i].startsWith("MemTotal:")) memTotal = parseInt(lines[i].split(/\s+/)[1])
                if (lines[i].startsWith("MemFree:"))  memFree  = parseInt(lines[i].split(/\s+/)[1])
                if (lines[i].startsWith("Buffers:"))  memBuf   = parseInt(lines[i].split(/\s+/)[1])
                if (lines[i].startsWith("Cached:"))   memCac   = parseInt(lines[i].split(/\s+/)[1])
            }
            if (memTotal > 0) {
                root.memPercent = Math.round((memTotal - memFree - memBuf - memCac) / memTotal * 100)
            }
            
            let tempLine = lines.find(l => /^\d+$/.test(l))
            if (tempLine) {
                let t = parseInt(tempLine)
                if (!isNaN(t)) root.tempC = Math.round(t / 1000)
            }
        }
    }
    
    property var _gpuProc: Process {
        id: gpuProc
        command: ["/bin/bash", "-c", "gpu-temp.sh 2>/dev/null"]
        stdout: SplitParser { onRead: (l) => { root.gpuText = l.trim() } }
    }
    
    property var _sysTimer: Timer { 
        interval: 1000; running: true; repeat: true; 
        onTriggered: { sysProc.running = false; sysProc.running = true } 
    }
    property var _gpuTimer: Timer { 
        interval: 2000; running: true; repeat: true; 
        onTriggered: { gpuProc.running = false; gpuProc.running = true } 
    }
    
    Component.onCompleted: { sysProc.running = true; gpuProc.running = true }
}