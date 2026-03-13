// globals/Style.qml
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property string stylePath: Quickshell.env("HOME") + "/.config/quickshell/style.json"
    readonly property string tmpPath:   Quickshell.env("HOME") + "/.config/quickshell/.style.json.tmp"

    // ── Bar ───────────────────────────────────────────────────────────────
    property real   barSize:    40
    property real   moduleSize: 28
    property string barFont:    "JetBrainsMono Nerd Font"
    property real   barPadding: 12

    // ── Slots ─────────────────────────────────────────────────────────────
    property real slotSpacing: 8

    // ── Pills ─────────────────────────────────────────────────────────────
    property real pillPadding: 16
    property real pillSpacing: 6
    property real pillOpacity: 0.6

    // ── Chips ─────────────────────────────────────────────────────────────
    property real chipSpacing:      6
    property real chipInnerSpacing: 5

    // ── Border ────────────────────────────────────────────────────────────
    property real borderWidth:  10
    property real cornerRadius: 20

    FileView {
        path: root.stylePath
        adapter: JsonAdapter {
            property real   barSize:          50
            property real   moduleSize:        28
            property string barFont:           "JetBrainsMono Nerd Font"
            property real   barPadding:        12
            property real   slotSpacing:       8
            property real   pillPadding:       16
            property real   pillSpacing:       6
            property real   pillOpacity:       0.6
            property real   chipSpacing:       6
            property real   chipInnerSpacing:  5
            property real   borderWidth:       10
            property real   cornerRadius:      20

            onBarSizeChanged:          root.barSize          = barSize
            onModuleSizeChanged:       root.moduleSize       = moduleSize
            onBarFontChanged:          root.barFont          = barFont
            onBarPaddingChanged:       root.barPadding       = barPadding
            onSlotSpacingChanged:      root.slotSpacing      = slotSpacing
            onPillPaddingChanged:      root.pillPadding      = pillPadding
            onPillSpacingChanged:      root.pillSpacing      = pillSpacing
            onPillOpacityChanged:      root.pillOpacity      = pillOpacity
            onChipSpacingChanged:      root.chipSpacing      = chipSpacing
            onChipInnerSpacingChanged: root.chipInnerSpacing = chipInnerSpacing
            onBorderWidthChanged:      root.borderWidth      = borderWidth
            onCornerRadiusChanged:     root.cornerRadius     = cornerRadius
        }
    }

    readonly property var styleKeys: [
        "barSize", "moduleSize", "barFont", "barPadding",
        "slotSpacing", "pillPadding", "pillSpacing", "pillOpacity",
        "chipSpacing", "chipInnerSpacing", "borderWidth", "cornerRadius"
    ]

    function saveSetting(key, value) {
        root[key] = value

        let fileData = {}
        for (let k of root.styleKeys) fileData[k] = root[k]

        let jsonString = JSON.stringify(fileData, null, 2)
        Quickshell.execDetached({
            command: ["sh", "-c",
                `mkdir -p ~/.config/quickshell && echo '${jsonString}' > ${root.tmpPath} && mv ${root.tmpPath} ${root.stylePath}`]
        })
    }
}