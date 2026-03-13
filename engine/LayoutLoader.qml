// engine/LayoutLoader.qml
pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import QtQuick
import qs.global

Scope {
    id: root

    readonly property real   barSize: Style.barSize
    readonly property string barFont: "JetBrainsMono Nerd Font" 

    property var layoutLeft:   []
    property var layoutCenter: []
    property var layoutRight:  []

    FileView {
        path: Qt.resolvedUrl("../layouts/" + Config.activeLayout + ".json")
        adapter: JsonAdapter {
            property var left:   []
            property var center: []
            property var right:  []
            
            onLeftChanged:   root.layoutLeft   = JSON.parse(JSON.stringify(left   || []))
            onCenterChanged: root.layoutCenter = JSON.parse(JSON.stringify(center || []))
            onRightChanged:  root.layoutRight  = JSON.parse(JSON.stringify(right  || []))
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: bar
            required property var modelData

            screen:        modelData
            color:         Config.enableBorders ? Colors.background : "transparent"
            exclusionMode: ExclusionMode.Auto

            anchors {
                top:    Config.navbarLocation !== "bottom"
                bottom: Config.navbarLocation !== "top"
                left:   Config.navbarLocation !== "right"
                right:  Config.navbarLocation !== "left"
            }

            implicitHeight: Config.isHorizontal ? Style.barSize : 0
            implicitWidth:  Config.isHorizontal ? 0             : Style.barSize

            component BarSlot: SlotLayout {
                isHorizontal: Config.isHorizontal
                moduleSize:   Style.moduleSize
                barFont:      root.barFont
            }

            // ── Horizontal ────────────────────────────────────────────────
            BarSlot {
                visible:    Config.isHorizontal
                modules:    root.layoutLeft
                barScreen:  bar.modelData
                anchors.left:           parent.left
                anchors.leftMargin:     Style.barPadding
                anchors.verticalCenter: parent.verticalCenter
            }
            BarSlot {
                visible:   Config.isHorizontal
                modules:   root.layoutCenter
                barScreen: bar.modelData
                anchors.centerIn: parent
            }
            BarSlot {
                visible:    Config.isHorizontal
                modules:    root.layoutRight
                barScreen:  bar.modelData
                anchors.right:          parent.right
                anchors.rightMargin:    Style.barPadding
                anchors.verticalCenter: parent.verticalCenter
            }

            // ── Vertical ──────────────────────────────────────────────────
            BarSlot {
                visible:   !Config.isHorizontal
                modules:   root.layoutLeft
                barScreen: bar.modelData
                anchors.top:              parent.top
                anchors.topMargin:        Style.barPadding
                anchors.horizontalCenter: parent.horizontalCenter
            }
            BarSlot {
                visible:   !Config.isHorizontal
                modules:   root.layoutCenter
                barScreen: bar.modelData
                anchors.centerIn: parent
            }
            BarSlot {
                visible:   !Config.isHorizontal
                modules:   root.layoutRight
                barScreen: bar.modelData
                anchors.bottom:           parent.bottom
                anchors.bottomMargin:     Style.barPadding
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }
}