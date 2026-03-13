// modules/cava/Cava.qml
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.globals

QtObject {
    id: root
    readonly property string moduleType: "custom"

    property string bars:    "▁▁▁▁▁▁▁▁"
    property bool   present: false

    readonly property string dict: "  ▂▃▄▅▆▇█"

    property var _check: Process {
        command: ["bash", "-c", "command -v cava"]
        running: true
        stdout: SplitParser {
            onRead: (l) => { 
                if (l.trim() !== "") {
                    root.present = true;
                    cavaProc.running = true;
                }
            }
        }
    }
    
    property var _proc: Process {
        id: cavaProc
        command: [
            "bash", 
            "-c", 
            `cat <<EOF > /tmp/qs_cava.conf
[general]
framerate=60
bars=10
[output]
method=raw
data_format=ascii
ascii_max_range=8
EOF
exec cava -p /tmp/qs_cava.conf`
        ]
        running: false
        
        stdout: SplitParser {
            onRead: (line) => {
                let parts = line.trim().split(';');
                let newBars = "";
                
                for (let i = 0; i < 10; i++) {
                    let val = parseInt(parts[i]);
                    if (!isNaN(val)) {
                        val = Math.max(0, Math.min(val, 8));
                        newBars += root.dict[val];
                    }
                }
                
                if (newBars.length > 0) {
                    root.bars = newBars;
                }
            }
        }
        
        stderr: SplitParser {
            onRead: (l) => console.log("CAVA ERROR: " + l)
        }
        
        onExited: { if (root.present) restartTimer.start() }
    }

    property var _timer: Timer {
        id: restartTimer
        interval: 2000
        onTriggered: cavaProc.running = true
    }
}