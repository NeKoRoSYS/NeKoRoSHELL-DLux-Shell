// modules/power/Power.qml  — BACKEND + MODULE DESCRIPTOR
pragma Singleton

import QtQuick
import Quickshell
import qs.global

QtObject {
    readonly property string moduleType: "static"

    readonly property var item: ({
        icon:      "⏻",
        bgColor:   Colors.color7,
        fgColor:   Colors.background,
        onClicked: function() { Power.open() }
    })

    function open() {
        Quickshell.execDetached({ command: ["sh", "-c",
            "wlogout -C ~/.config/wlogout/style.css"] })
    }
}
