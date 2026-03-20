// engine/DashboardEngine.qml
// Owns the grid packer, placement algorithm, widget registry, edit mode,
// and persisted layout. Dashboard.qml consumes this as a pure data source —
// it reads placements and calls the mutating functions, owns no engine logic.
pragma ComponentBehavior: Bound

import QtQuick
import qs.global

QtObject {
    id: root

    // ── Edit mode ─────────────────────────────────────────────────────────
    property bool editMode: false

    // ── Grid geometry ─────────────────────────────────────────────────────
    readonly property real cellGap: 6
    // cellW is computed by the grid Item in Dashboard since it depends on
    // live rendered width — exposed here as a convenience binding target
    property real cellW: 0

    // ── Widget registry ───────────────────────────────────────────────────
    readonly property var widgetDefs: [
        { id: "stats",         label: "Stats",      icon: "󰍛",  cols: 1, rows: 2 },
        { id: "speaker",       label: "Speaker",    icon: "󰕾",  cols: 1, rows: 2 },
        { id: "mic",           label: "Mic",        icon: "󰍬",  cols: 1, rows: 2 },
        { id: "brightness",    label: "Brightness", icon: "",   cols: 1, rows: 2 },
        { id: "network",       label: "Wi-Fi",      icon: "󰤨",  cols: 1, rows: 1 },
        { id: "bluetooth",     label: "Bluetooth",  icon: "󰂱",  cols: 1, rows: 1 },
        { id: "idleinhibitor", label: "Sleep",      icon: "󰾪",  cols: 1, rows: 1 },
        { id: "cliphist",      label: "Clipboard",  icon: "󱘔",  cols: 1, rows: 1 },
        { id: "power",         label: "Power",      icon: "⏻",  cols: 1, rows: 1 },
        { id: "settings",      label: "Settings",   icon: "",   cols: 1, rows: 1 },
    ]

    // ── Persisted active widget list ──────────────────────────────────────
    property var activeWidgets: {
        try {
            return JSON.parse(Config.dashboardLayout).filter(w => w !== "media")
        } catch(e) {
            return ["stats","speaker","mic","network","idleinhibitor","cliphist","power","settings"]
        }
    }

    function saveLayout()         { Config.saveSetting("dashboardLayout", JSON.stringify(activeWidgets)) }
    function defFor(id)           { for (let d of widgetDefs) if (d.id === id) return d; return null }
    function addWidget(id)        { if (activeWidgets.indexOf(id) === -1) { activeWidgets = activeWidgets.concat([id]); saveLayout() } }
    function removeWidget(id)     { activeWidgets = activeWidgets.filter(w => w !== id); saveLayout() }
    function moveWidget(from, to) {
        let arr  = activeWidgets.slice()
        let item = arr.splice(from, 1)[0]
        arr.splice(to, 0, item)
        activeWidgets = arr
        saveLayout()
    }

    // ── Placement algorithm ───────────────────────────────────────────────
    // Returns an array of { id, col, row, cols, rows, idx } objects.
    // Recomputes whenever activeWidgets changes.
    readonly property var placements: {
        let occupied = []
        let result   = []

        function isFree(col, row, cols, rows) {
            for (let r = row; r < row + rows; r++)
                for (let c = col; c < col + cols; c++) {
                    if (occupied.indexOf(r + "," + c) !== -1) return false
                    if (c + cols > 4) return false
                }
            return true
        }
        function occupy(col, row, cols, rows) {
            for (let r = row; r < row + rows; r++)
                for (let c = col; c < col + cols; c++)
                    occupied.push(r + "," + c)
        }

        for (let i = 0; i < root.activeWidgets.length; i++) {
            let def = root.defFor(root.activeWidgets[i])
            if (!def) continue
            let placed = false
            for (let row = 0; row < 8 && !placed; row++) {
                for (let col = 0; col <= 4 - def.cols && !placed; col++) {
                    if (isFree(col, row, def.cols, def.rows)) {
                        result.push({ id: def.id, col, row, cols: def.cols, rows: def.rows, idx: i })
                        occupy(col, row, def.cols, def.rows)
                        placed = true
                    }
                }
            }
        }
        return result
    }

    // ── Grid height helper ────────────────────────────────────────────────
    // Dashboard binds gridHeight to size its container correctly.
    readonly property real gridHeight: {
        let maxRow = 0
        for (let i = 0; i < placements.length; i++)
            maxRow = Math.max(maxRow, placements[i].row + placements[i].rows)
        return maxRow * (cellW + cellGap)
    }
}