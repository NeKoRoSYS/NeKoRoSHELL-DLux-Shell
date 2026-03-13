// modules/tray/Tray.qml  — BACKEND + MODULE DESCRIPTOR
pragma Singleton

import QtQuick
import qs.globals

QtObject {
    readonly property string moduleType: "static"

    readonly property var item: ({
        icon:      "󱊣",
        bgColor:   Colors.color7,
        fgColor:   Colors.background,
        onClicked: function() { Tray.open() }
    })

    function open() { EventBus.togglePanel("tray") }
}
