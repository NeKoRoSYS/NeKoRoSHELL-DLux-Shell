// components/Panel.qml
import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Shapes
import qs.globals

Scope {
    id: rootScope

    property bool   showPanel:       false
    property real   panelWidth:      400
    property real   panelHeight:     400
    property real   navbarOffset:    0
    property real   visualGap:       0
    property int    keyboardFocus:   WlrKeyboardFocus.OnDemand
    property string animationPreset: "slide"

    readonly property real tensionRadius: 20
    readonly property real panelRadius:   20
    readonly property bool isHorizontal:  Config.isHorizontal

    default property Component panelContent

    property real animProgress: rootScope.showPanel ? 1.0 : 0.0
    Behavior on animProgress { NumberAnimation { duration: 500; easing.type: Easing.OutCubic } }

    readonly property real maxSlidePx: isHorizontal ? rootScope.panelHeight : rootScope.panelWidth
    readonly property real exposedPx:  maxSlidePx * animProgress
    readonly property real filletOffset: rootScope.animationPreset === "slide"
        ? Math.max(0, rootScope.panelRadius - rootScope.exposedPx + 8)
        : 0

    PanelWindow {

        visible: rootScope.animProgress > 0.01
        color:   "transparent"

        WlrLayershell.layer:         WlrLayer.Top
        exclusionMode:               ExclusionMode.Ignore
        WlrLayershell.keyboardFocus: rootScope.keyboardFocus
        WlrLayershell.namespace:     "quickshell-panel"

        anchors {
            top:    Config.navbarLocation === "top"
            bottom: Config.navbarLocation === "bottom"
            left:   Config.navbarLocation === "left"
            right:  Config.navbarLocation === "right"
        }

        margins {
            top:    Config.navbarLocation === "top"    ? (rootScope.navbarOffset + rootScope.visualGap) : 0
            bottom: Config.navbarLocation === "bottom" ? (rootScope.navbarOffset + rootScope.visualGap) : 0
            left:   Config.navbarLocation === "left"   ? (rootScope.navbarOffset + rootScope.visualGap) : 0
            right:  Config.navbarLocation === "right"  ? (rootScope.navbarOffset + rootScope.visualGap) : 0
        }

        implicitWidth:  rootScope.isHorizontal
            ? (rootScope.panelWidth  + (rootScope.tensionRadius * 2))
            : rootScope.panelWidth
        implicitHeight: !rootScope.isHorizontal
            ? (rootScope.panelHeight + (rootScope.tensionRadius * 2))
            : rootScope.panelHeight

        Item {
            anchors.fill: parent
            clip: true

            Item {
                id: movingPanel
                width:  rootScope.panelWidth
                height: rootScope.panelHeight
                anchors.centerIn: parent

                opacity: rootScope.animationPreset === "fade"  ? rootScope.animProgress : 1.0
                scale:   rootScope.animationPreset === "scale" ? 0.9 + (0.1 * rootScope.animProgress) : 1.0

                transform: Translate {
                    property real offset: rootScope.animationPreset === "slide"
                        ? (rootScope.maxSlidePx * (1.0 - rootScope.animProgress))
                        : 0
                    x: Config.navbarLocation === "left"  ? -offset
                        : Config.navbarLocation === "right" ?  offset : 0
                    y: Config.navbarLocation === "top"   ? -offset
                        : Config.navbarLocation === "bottom"?  offset : 0
                }

                Rectangle {
                    id: bg
                    color:  Colors.background
                    radius: rootScope.panelRadius
                    border.width: 0

                    anchors {
                        fill:         parent
                        topMargin:    Config.navbarLocation === "top"    ? -radius : 0
                        bottomMargin: Config.navbarLocation === "bottom" ? -radius : 0
                        leftMargin:   Config.navbarLocation === "left"   ? -radius : 0
                        rightMargin:  Config.navbarLocation === "right"  ? -radius : 0
                    }
                }

                Item {
                    anchors.fill:    parent
                    anchors.margins: 25
                    clip: true

                    Loader {
                        anchors.fill:    parent
                        sourceComponent: rootScope.panelContent
                    }
                }
            }

            // Tension fillets — keep corners looking seamless when panel slides in
            Item {
                anchors.fill: parent
                visible: rootScope.animationPreset === "slide" && rootScope.animProgress > 0

                transform: Translate {
                    x: Config.navbarLocation === "left"  ? -rootScope.filletOffset
                        : Config.navbarLocation === "right" ?  rootScope.filletOffset : 0
                    y: Config.navbarLocation === "top"   ? -rootScope.filletOffset
                        : Config.navbarLocation === "bottom"?  rootScope.filletOffset : 0
                }

                // ── top ──────────────────────────────────────────────────
                Item {
                    visible: Config.navbarLocation === "top"
                    anchors.fill: parent
                    Shape {
                        anchors { left: parent.left; top: parent.top }
                        width: rootScope.tensionRadius; height: rootScope.tensionRadius
                        ShapePath {
                            fillColor: Colors.background; strokeWidth: 0
                            startX: rootScope.tensionRadius; startY: rootScope.tensionRadius
                            PathLine { x: rootScope.tensionRadius; y: 0 }
                            PathLine { x: 0; y: 0 }
                            PathArc  { x: rootScope.tensionRadius; y: rootScope.tensionRadius
                                        radiusX: rootScope.tensionRadius; radiusY: rootScope.tensionRadius
                                        direction: PathArc.Clockwise }
                        }
                    }
                    Shape {
                        anchors { right: parent.right; top: parent.top }
                        width: rootScope.tensionRadius; height: rootScope.tensionRadius
                        ShapePath {
                            fillColor: Colors.background; strokeWidth: 0
                            startX: rootScope.tensionRadius; startY: 0
                            PathLine { x: 0; y: 0 }
                            PathLine { x: 0; y: rootScope.tensionRadius }
                            PathArc  { x: rootScope.tensionRadius; y: 0
                                        radiusX: rootScope.tensionRadius; radiusY: rootScope.tensionRadius
                                        direction: PathArc.Clockwise }
                        }
                    }
                }

                // ── bottom ───────────────────────────────────────────────
                Item {
                    visible: Config.navbarLocation === "bottom"
                    anchors.fill: parent
                    Shape {
                        anchors { left: parent.left; bottom: parent.bottom }
                        width: rootScope.tensionRadius; height: rootScope.tensionRadius
                        ShapePath {
                            fillColor: Colors.background; strokeWidth: 0
                            startX: 0; startY: rootScope.tensionRadius
                            PathLine { x: rootScope.tensionRadius; y: rootScope.tensionRadius }
                            PathLine { x: rootScope.tensionRadius; y: 0 }
                            PathArc  { x: 0; y: rootScope.tensionRadius
                                        radiusX: rootScope.tensionRadius; radiusY: rootScope.tensionRadius
                                        direction: PathArc.Clockwise }
                        }
                    }
                    Shape {
                        anchors { right: parent.right; bottom: parent.bottom }
                        width: rootScope.tensionRadius; height: rootScope.tensionRadius
                        ShapePath {
                            fillColor: Colors.background; strokeWidth: 0
                            startX: 0; startY: 0
                            PathLine { x: 0; y: rootScope.tensionRadius }
                            PathLine { x: rootScope.tensionRadius; y: rootScope.tensionRadius }
                            PathArc  { x: 0; y: 0
                                        radiusX: rootScope.tensionRadius; radiusY: rootScope.tensionRadius
                                        direction: PathArc.Clockwise }
                        }
                    }
                }

                // ── left ─────────────────────────────────────────────────
                Item {
                    visible: Config.navbarLocation === "left"
                    anchors.fill: parent
                    Shape {
                        anchors { left: parent.left; top: parent.top }
                        width: rootScope.tensionRadius; height: rootScope.tensionRadius
                        ShapePath {
                            fillColor: Colors.background; strokeWidth: 0
                            startX: 0; startY: 0
                            PathLine { x: 0; y: rootScope.tensionRadius }
                            PathLine { x: rootScope.tensionRadius; y: rootScope.tensionRadius }
                            PathArc  { x: 0; y: 0
                                        radiusX: rootScope.tensionRadius; radiusY: rootScope.tensionRadius
                                        direction: PathArc.Clockwise }
                        }
                    }
                    Shape {
                        anchors { left: parent.left; bottom: parent.bottom }
                        width: rootScope.tensionRadius; height: rootScope.tensionRadius
                        ShapePath {
                            fillColor: Colors.background; strokeWidth: 0
                            startX: rootScope.tensionRadius; startY: 0
                            PathLine { x: 0; y: 0 }
                            PathLine { x: 0; y: rootScope.tensionRadius }
                            PathArc  { x: rootScope.tensionRadius; y: 0
                                        radiusX: rootScope.tensionRadius; radiusY: rootScope.tensionRadius
                                        direction: PathArc.Clockwise }
                        }
                    }
                }

                // ── right ────────────────────────────────────────────────
                Item {
                    visible: Config.navbarLocation === "right"
                    anchors.fill: parent
                    Shape {
                        anchors { right: parent.right; top: parent.top }
                        width: rootScope.tensionRadius; height: rootScope.tensionRadius
                        ShapePath {
                            fillColor: Colors.background; strokeWidth: 0
                            startX: 0; startY: rootScope.tensionRadius
                            PathLine { x: rootScope.tensionRadius; y: rootScope.tensionRadius }
                            PathLine { x: rootScope.tensionRadius; y: 0 }
                            PathArc  { x: 0; y: rootScope.tensionRadius
                                        radiusX: rootScope.tensionRadius; radiusY: rootScope.tensionRadius
                                        direction: PathArc.Clockwise }
                        }
                    }
                    Shape {
                        anchors { right: parent.right; bottom: parent.bottom }
                        width: rootScope.tensionRadius; height: rootScope.tensionRadius
                        ShapePath {
                            fillColor: Colors.background; strokeWidth: 0
                            startX: rootScope.tensionRadius; startY: rootScope.tensionRadius
                            PathLine { x: rootScope.tensionRadius; y: 0 }
                            PathLine { x: 0; y: 0 }
                            PathArc  { x: rootScope.tensionRadius; y: rootScope.tensionRadius
                                        radiusX: rootScope.tensionRadius; radiusY: rootScope.tensionRadius
                                        direction: PathArc.Clockwise }
                        }
                    }
                }
            }
        }
    }
}