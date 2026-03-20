// modules/tray/Tray.qml
pragma Singleton

import QtQuick
import qs.global

QtObject {
    readonly property string moduleType: "static"

    readonly property var item: ({
        icon:      "󱊣",
        onClicked: function() { Tray.open() }
    })

    function open() { EventBus.togglePanel("tray") }
}
