// modules/settings/Settings.qml
pragma Singleton

import QtQuick
import qs.global

QtObject {
    readonly property string moduleType: "static"

    readonly property var item: ({
        icon:      "",
        onClicked: function() { Settings.open() }
    })

    function open() { EventBus.togglePanel("settings", null) }
}
