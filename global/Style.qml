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
    property real   barSize:    50
    property real   moduleSize: 28
    property string barFont:    "JetBrainsMono Nerd Font"
    property real   barPadding: 12

    // ── Slots ─────────────────────────────────────────────────────────────
    property real slotSpacing: 8

    // ── Pills ─────────────────────────────────────────────────────────────
    property real pillPadding: 16
    property real pillSpacing: 6
    property real pillOpacity: 0.6
    property real pillRadius:  999  // 999 = fully round (clamped by Rectangle)

    // ── Chips ─────────────────────────────────────────────────────────────
    property real chipSpacing:      6
    property real chipInnerSpacing: 5

    // ── Panels ────────────────────────────────────────────────────────────
    property real panelWidth:   400
    property real panelHeight:  500
    property real panelRadius:  20
    property real panelPadding: 25

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
            property real   pillRadius:        999
            property real   chipSpacing:       6
            property real   chipInnerSpacing:  5
            property real   panelWidth:        400
            property real   panelHeight:       500
            property real   panelRadius:       20
            property real   panelPadding:      25
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
            onPillRadiusChanged:       root.pillRadius       = pillRadius
            onChipSpacingChanged:      root.chipSpacing      = chipSpacing
            onChipInnerSpacingChanged: root.chipInnerSpacing = chipInnerSpacing
            onPanelWidthChanged:       root.panelWidth       = panelWidth
            onPanelHeightChanged:      root.panelHeight      = panelHeight
            onPanelRadiusChanged:      root.panelRadius      = panelRadius
            onPanelPaddingChanged:     root.panelPadding     = panelPadding
            onBorderWidthChanged:      root.borderWidth      = borderWidth
            onCornerRadiusChanged:     root.cornerRadius     = cornerRadius
        }
    }

    readonly property var styleKeys: [
        "barSize", "moduleSize", "barFont", "barPadding",
        "slotSpacing", "pillPadding", "pillSpacing", "pillOpacity", "pillRadius",
        "chipSpacing", "chipInnerSpacing",
        "panelWidth", "panelHeight", "panelRadius", "panelPadding",
        "borderWidth", "cornerRadius"
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
