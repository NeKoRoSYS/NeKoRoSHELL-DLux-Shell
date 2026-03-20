// engine/LayoutLoader.qml
pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Wayland
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
            color:         "transparent"
            WlrLayershell.layer:         WlrLayer.Overlay
            exclusionMode: ExclusionMode.Auto
            WlrLayershell.namespace:     "quickshell-navbar"

            anchors {
                top:    Config.navbarLocation !== "bottom"
                bottom: Config.navbarLocation !== "top"
                left:   Config.navbarLocation !== "right"
                right:  Config.navbarLocation !== "left"
            }

            property real edgeMargin: Config.transparentNavbar ? Style.borderWidth + 5 : 0
            Behavior on edgeMargin {
                NumberAnimation { duration: 250; easing.type: Easing.OutCubic } //
            }

            margins {
                top:    anchors.top    ? edgeMargin : 0
                bottom: anchors.bottom ? edgeMargin : 0
                left:   anchors.left   ? edgeMargin : 0
                right:  anchors.right  ? edgeMargin : 0
            }

            property real activeSize: Config.transparentNavbar ? Style.moduleSize : Style.barSize
            
            Behavior on activeSize { 
                NumberAnimation { duration: 250; easing.type: Easing.OutCubic } 
            }

            implicitHeight: Config.isHorizontal ? activeSize : 0
            implicitWidth:  Config.isHorizontal ? 0          : activeSize

            Rectangle {
                anchors.fill: parent
                color: Colors.background
                opacity: Config.transparentNavbar ? 0.0 : 1.0
                
                Behavior on opacity { 
                    NumberAnimation { duration: 250; easing.type: Easing.OutCubic } 
                }
            }

            component BarSlot: SlotLayout {
                isHorizontal: Config.isHorizontal
                moduleSize:   Style.moduleSize
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