// engine/ModuleRegistry.qml
pragma Singleton

import QtQuick
import qs.modules.clock
import qs.modules.workspaces
import qs.modules.media
import qs.modules.music
import qs.modules.buttons


QtObject {
    id: root

    function resolve(name) {
        switch (name) {
            case "clock":           return clockComponent
            case "workspaces":      return workspacesComponent
            case "media":           return mediaComponent
            case "music":           return musicComponent
            case "buttons":         return buttonsComponent
            default:
                console.warn("ModuleRegistry: unknown module '" + name + "'")
                return null
        }
    }

    property Component clockComponent:         Clock          {}
    property Component workspacesComponent:    Workspaces     {}
    property Component mediaComponent:         Media          {}
    property Component musicComponent:         Music          {}
    property Component buttonsComponent:       Buttons        {}
}
