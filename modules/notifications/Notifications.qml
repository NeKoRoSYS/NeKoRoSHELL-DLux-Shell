// modules/notifications/Notifications.qml  — BACKEND + MODULE DESCRIPTOR
pragma Singleton

import QtQuick
import Quickshell
import qs.global

QtObject {
    readonly property string moduleType: "static"

    readonly property var item: ({
        icon:      "󰂚",
        bgColor:   Colors.color7,
        fgColor:   Colors.background,
        onClicked: function() { Notifications.open() }
    })

    function open() { EventBus.togglePanel("notifications") }
}
