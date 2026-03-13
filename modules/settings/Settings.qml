// modules/settings/Settings.qml  — BACKEND + MODULE DESCRIPTOR
// Also absorbs LayoutSwitcher — both opened the same "theming" panel
pragma Singleton

import QtQuick
import qs.globals

QtObject {
    readonly property string moduleType: "static"

    readonly property var item: ({
        icon:      "",
        bgColor:   Colors.color7,
        fgColor:   Colors.background,
        onClicked: function() { SettingsModule.open() }
    })

    function open() { EventBus.togglePanel("settings") }
}
