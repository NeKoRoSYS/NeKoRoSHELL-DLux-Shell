// modules/notifications/Notifications.qml 
pragma Singleton

import QtQuick
import Quickshell
import qs.global

QtObject {
    readonly property string moduleType: "static"

    readonly property var item: ({
        icon:      "󰂚",
        onClicked: function() { Notifications.open() }
    })

    function open() { EventBus.togglePanel("notifications", null) }
}
