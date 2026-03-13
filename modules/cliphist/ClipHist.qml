// modules/cliphist/ClipHist.qml  — BACKEND + MODULE DESCRIPTOR
pragma Singleton

import QtQuick
import Quickshell
import qs.globals

QtObject {
    readonly property string moduleType: "static"

    readonly property var item: ({
        icon:      "󱘔",
        bgColor:   Colors.color7,
        fgColor:   Colors.background,
        onClicked: function() { ClipHist.open() }
    })

    function open() {
        Quickshell.execDetached({ command: ["/bin/bash", "-l", "-c", "clipmgr.sh"] })
    }
}
