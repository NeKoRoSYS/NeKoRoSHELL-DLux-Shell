// modules/cliphist/ClipHist.qml
pragma Singleton

import QtQuick
import Quickshell
import qs.global

QtObject {
    readonly property string moduleType: "static"

    readonly property var item: ({
        icon:      "󱘔",
        onClicked: function() { EventBus.togglePanel("clipboard") }
    })
}