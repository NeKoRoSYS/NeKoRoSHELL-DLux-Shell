// modules/power/Power.qml  — BACKEND + MODULE DESCRIPTOR
pragma Singleton

import QtQuick
import Quickshell
import qs.global

QtObject {
    readonly property string moduleType: "static"

    readonly property var item: ({
        icon:      "⏻",
        onClicked: function() { Power.open() }
    })

    function open() { EventBus.togglePanel("power", null) }
}
