// modules/status/Status.qml
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.global

QtObject {
    id: root
    readonly property string moduleType: "dynamic"

    readonly property var items: {
        let out = []
        if (root.hasBattery) {
            out.push({
                icon:    root.battIcon,
                label:   root.battPercent + "%",
                bgColor: root.battLow ? Colors.color1 : Colors.color0
            })
        }
        if (root.hasBacklight) {
            out.push({
                icon:      root.blIcon,
                label:     root.blPercent + "%",
                bgColor:   Colors.color0,
                onScrolled: function(d) { root.stepBacklight(d) }
            })
        }
        return out
    }

    // ── Battery ───────────────────────────────────────────────────────────
    property int    battPercent: 0
    property string battStatus:  "Unknown"
    property bool   hasBattery:  false
    
    readonly property string battIcon: {
        if (root.battStatus === "Charging" || root.battStatus === "Full") return "󰂄"
        let p = root.battPercent
        if (p > 80) return "󰁹"
        if (p > 60) return "󰂀"
        if (p > 40) return "󰁾"
        if (p > 20) return "󰁼"
        return "󰁺"
    }
    
    readonly property bool battLow: root.battPercent <= 15 && root.battStatus !== "Charging"

    // ── Backlight ─────────────────────────────────────────────────────────
    property int  blMax:        100
    property int  blCurrent:    100
    property bool hasBacklight: false
    
    readonly property int blPercent: root.blMax > 0 ? Math.round(root.blCurrent / root.blMax * 100) : 0
    readonly property string blIcon: {
        let p = root.blPercent
        if (p > 87) return "󰛨"
        if (p > 62) return "󰃝"
        if (p > 37) return "󰃟"
        if (p > 12) return "󰃞"
        return "󰃛"
    }
    
    property var _blThrottleTimer: Timer {
        id: blThrottleTimer
        interval: 1
        property int targetVal: 100
        onTriggered: {
            Quickshell.execDetached({ command: ["brightnessctl", "set", targetVal.toString()] })
        }
    }
    
    function setBacklight(v) {
        let next = Math.max(1, Math.min(root.blMax, v))
        root.blCurrent = next
        
        blThrottleTimer.targetVal = next
        blThrottleTimer.restart()
    }
    
    function stepBacklight(d) { root.setBacklight(root.blCurrent + Math.round(root.blMax * 0.05) * d) }

    property var _batProc: Process {
        id: batProc
        command: ["/bin/bash", "-c", "cat /sys/class/power_supply/BAT*/capacity /sys/class/power_supply/BAT*/status 2>/dev/null"]
            
        property string buf: ""
        stdout: SplitParser { onRead: (l) => { batProc.buf += l.trim() + " " } }
        onExited: {
            let parts = batProc.buf.trim().split(" ")
            if (parts.length >= 2 && parts[0] !== "") {
                root.battPercent = parseInt(parts[0]) || 0
                root.battStatus  = parts[1] || "Unknown"
                root.hasBattery  = true
            }
            batProc.buf = ""
        }
    }
    
    property var _blProc: Process {
        id: blProc
        command: ["/bin/bash", "-c", "echo $(brightnessctl max 2>/dev/null) $(brightnessctl get 2>/dev/null)"]
            
        property string buf: ""
        stdout: SplitParser { onRead: (l) => { blProc.buf = l.trim() } }
        onExited: {
            let parts = blProc.buf.split(" ")
            if (parts.length >= 2 && parts[0] !== "") {
                root.blMax        = parseInt(parts[0]) || 100
                root.blCurrent    = parseInt(parts[1]) || 100
                root.hasBacklight = true
            }
            blProc.buf = ""
        }
    }

    property var _batListener: Process {
        command: ["udevadm", "monitor", "--subsystem-match=power_supply"]
        running: true
        stdout: SplitParser {
            onRead: () => {
                batProc.running = false
                batProc.running = true
            }
        }
    }

    property var _blListener: Process {
        command: ["inotifywait", "-m", "-e", "modify", "/sys/class/backlight/intel_backlight/brightness"]
        running: true
        stdout: SplitParser {
            onRead: () => {
                blProc.running = false
                blProc.running = true
            }
        }
    }
    
    Component.onCompleted: { 
        batProc.running = true
        blProc.running = true 
    }
}