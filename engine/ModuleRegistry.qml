// engine/ModuleRegistry.qml
pragma Singleton

import QtQuick
import Quickshell
import qs.components
import qs.modules.audio
import qs.modules.cava
import qs.modules.clock
import qs.modules.cliphist
import qs.modules.idleinhibitor
import qs.modules.media
import qs.modules.network
import qs.modules.notifications
import qs.modules.power
import qs.modules.settings
import qs.modules.status
import qs.modules.systeminfo
import qs.modules.tray
import qs.modules.workspaces

QtObject {
    id: root

    // Adding a module: declare its Component below, add one entry here.
    readonly property var _map: ({
        // ── Dynamic ───────────────────────────────────────────────────────
        "audio":         audioDynamic,
        "network":       networkDynamic,
        "status":        statusDynamic,  "battery":  statusDynamic, "backlight": statusDynamic,
        "systeminfo":    sysinfoDynamic, "cpu":      sysinfoDynamic, "memory": sysinfoDynamic,
        // ── Static ────────────────────────────────────────────────────────
        "cliphist":      cliphistStatic,
        "idleinhibitor": idleinhibitorStatic,
        "notifications": notificationsStatic,
        "power":         powerStatic,
        "settings":      settingsStatic,
        "tray":          trayStatic,
        // ── Custom ────────────────────────────────────────────────────────
        "cava":          cavaView,
        "clock":         clockView,
        "media":         mediaView,
        "workspaces":    workspacesView,
    })

    function resolve(name) {
        let c = _map[name]
        if (!c) console.warn("ModuleRegistry: unknown module '" + name + "'")
        return c ?? null
    }

    // ── Dynamic ───────────────────────────────────────────────────────────
    property Component audioDynamic: Component {
        DynamicChip { items: Audio.items }
    }
    property Component networkDynamic: Component {
        DynamicChip { items: Network.items }
    }
    property Component statusDynamic: Component {
        DynamicChip { items: Status.items }
    }
    property Component sysinfoDynamic: Component {
        DynamicChip { items: SystemInfo.items }
    }

    // ── Static ────────────────────────────────────────────────────────────
    property Component cliphistStatic: Component {
        StaticChip { item: ClipHist.item }
    }
    property Component idleinhibitorStatic: Component {
        StaticChip { item: IdleInhibitor.item }
    }
    property Component notificationsStatic: Component {
        StaticChip { item: Notifications.item }
    }
    property Component powerStatic: Component {
        StaticChip { item: Power.item }
    }
    property Component settingsStatic: Component {
        StaticChip { item: SettingsModule.item }
    }
    property Component trayStatic: Component {
        StaticChip { item: Tray.item }
    }

    // ── Custom ────────────────────────────────────────────────────────────
    property Component cavaView: Component {
        CavaView {}
    }
    property Component clockView: Component {
        ClockView {}
    }
    property Component mediaView: Component {
        MediaView {}
    }
    property Component workspacesView: Component {
        WorkspacesView {}
    }
}