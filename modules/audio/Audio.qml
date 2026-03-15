// modules/audio/Audio.qml
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.global

QtObject {
    readonly property string moduleType: "dynamic"

    readonly property var items: [
        {
            icon:      Audio.speakerIcon,
            label:     Audio.sinkMuted ? "muted" : Audio.sinkVolume + "%",
            bgColor:   Audio.sinkMuted ? Colors.color1 : Colors.color0,
            onClicked:  function() { Audio.muteSink() },
            onScrolled: function(d) {
                Audio.setSinkVolume(Math.max(0, Math.min(100, Audio.sinkVolume + d * 5)))
            }
        },
        {
            icon:      Audio.micIcon,
            label:     Audio.srcMuted ? "muted" : Audio.srcVolume + "%",
            bgColor:   Audio.srcMuted ? Colors.color1 : Colors.color0,
            onClicked:  function() { Audio.muteSrc() },
            onScrolled: function(d) {
                Audio.setSrcVolume(Math.max(0, Math.min(100, Audio.srcVolume + d * 5)))
            }
        }
    ]

    property int    sinkVolume: 100
    property bool   sinkMuted:  false
    readonly property string speakerIcon: {
        if (sinkMuted) return "󰝟"
        if (sinkVolume > 69) return ""
        if (sinkVolume > 34) return ""
        return ""
    }

    property int    srcVolume: 100
    property bool   srcMuted:  false
    readonly property string micIcon: srcMuted ? "󰍭" : "󰍬"

    function muteSink()       { Quickshell.execDetached({ command: ["pactl", "set-sink-mute",   "@DEFAULT_SINK@",   "toggle"] }); Qt.callLater(pollSink) }
    function muteSrc()        { Quickshell.execDetached({ command: ["pactl", "set-source-mute", "@DEFAULT_SOURCE@", "toggle"] }); Qt.callLater(pollSrc) }
    function setSinkVolume(v) { Quickshell.execDetached({ command: ["pactl", "set-sink-volume",   "@DEFAULT_SINK@",   v + "%"] }); Qt.callLater(pollSink) }
    function setSrcVolume(v)  { Quickshell.execDetached({ command: ["pactl", "set-source-volume", "@DEFAULT_SOURCE@", v + "%"] }); Qt.callLater(pollSrc) }
    function openMixer()      { Quickshell.execDetached({ command: ["pavucontrol"] }) }
    
    function pollSink() { sinkProc.running = false; sinkProc.running = true }
    function pollSrc()  { srcProc.running  = false; srcProc.running  = true }

    property var _subProc: Process {
        id: subProc
        command: ["pactl", "subscribe"]
        running: true
        stdout: SplitParser {
            onRead: (line) => {
                if (line.includes("Event 'change' on sink ")) {
                    Audio.pollSink()
                } else if (line.includes("Event 'change' on source ")) {
                    Audio.pollSrc()
                }
            }
        }
    }

    property var _sinkProc: Process {
        id: sinkProc
        command: ["/bin/bash", "-c", "pactl get-sink-volume @DEFAULT_SINK@; pactl get-sink-mute @DEFAULT_SINK@"]
        property string _buf: ""
        stdout: SplitParser { onRead: (l) => { sinkProc._buf += l.trim() + "\n" } }
        onExited: {
            let lines = _buf.trim().split("\n")
            if (lines.length >= 2) {
                let volMatch = lines[0].match(/(\d+)%/)
                if (volMatch) Audio.sinkVolume = parseInt(volMatch[1])
                Audio.sinkMuted = lines[1].includes("yes")
            }
            _buf = ""
        }
    }

    property var _srcProc: Process {
        id: srcProc
        command: ["/bin/bash", "-c", "pactl get-source-volume @DEFAULT_SOURCE@; pactl get-source-mute @DEFAULT_SOURCE@"]
        property string _buf: ""
        stdout: SplitParser { onRead: (l) => { srcProc._buf += l.trim() + "\n" } }
        onExited: {
            let lines = _buf.trim().split("\n")
            if (lines.length >= 2) {
                let volMatch = lines[0].match(/(\d+)%/)
                if (volMatch) Audio.srcVolume = parseInt(volMatch[1])
                Audio.srcMuted = lines[1].includes("yes")
            }
            _buf = ""
        }
    }

    Component.onCompleted: {
        sinkProc.running = true;
        srcProc.running = true;
        subProc.running = true;
    }
}