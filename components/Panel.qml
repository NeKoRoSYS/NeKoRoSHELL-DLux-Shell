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

    property string anchorEdge:      Config.navbarLocation // "top", "bottom", "left", "right"
    property string anchorAlignment: "center"              // "start", "center", "end"
    property real   borderGap:       Config.enableBorders ? 10 : 0

    readonly property real tensionRadius: 20
    readonly property real panelRadius:   20

    readonly property bool isHorizontal:    anchorEdge === "top"    || anchorEdge === "bottom"
    
    readonly property bool anchoredTop:     anchorEdge === "top"    || (!isHorizontal && anchorAlignment === "start")
    readonly property bool anchoredBottom:  anchorEdge === "bottom" || (!isHorizontal && anchorAlignment === "end")
    readonly property bool anchoredLeft:    anchorEdge === "left"   || ( isHorizontal && anchorAlignment === "start")
    readonly property bool anchoredRight:   anchorEdge === "right"  || ( isHorizontal && anchorAlignment === "end")

    readonly property bool f_top_left:     anchoredTop    && !anchoredLeft
    readonly property bool f_top_right:    anchoredTop    && !anchoredRight
    readonly property bool f_bottom_left:  anchoredBottom && !anchoredLeft
    readonly property bool f_bottom_right: anchoredBottom && !anchoredRight
    readonly property bool f_left_top:     anchoredLeft   && !anchoredTop
    readonly property bool f_left_bottom:  anchoredLeft   && !anchoredBottom
    readonly property bool f_right_top:    anchoredRight  && !anchoredTop
    readonly property bool f_right_bottom: anchoredRight  && !anchoredBottom

    readonly property bool hasLeftSpace:   f_top_left || f_bottom_left
    readonly property bool hasRightSpace:  f_top_right || f_bottom_right
    readonly property bool hasTopSpace:    f_left_top || f_right_top
    readonly property bool hasBottomSpace: f_left_bottom || f_right_bottom

    default property Component panelContent

    property real animProgress: rootScope.showPanel ? 1.0 : 0.0
    Behavior on animProgress { NumberAnimation { duration: 500; easing.type: Easing.OutCubic } }

    readonly property real maxSlidePx: isHorizontal ? rootScope.panelHeight : rootScope.panelWidth
    readonly property real slideOffset: rootScope.animationPreset === "slide" ? (rootScope.maxSlidePx * (1.0 - rootScope.animProgress)) : 0
    readonly property real filletOffset: rootScope.animationPreset === "slide" ? Math.max(0, rootScope.panelRadius - (maxSlidePx * animProgress) + 8) : 0
    
    readonly property real slideX: anchorEdge === "left" ? -slideOffset : anchorEdge === "right" ? slideOffset : 0
    readonly property real slideY: anchorEdge === "top"  ? -slideOffset : anchorEdge === "bottom" ? slideOffset : 0
    readonly property real tensionX: anchorEdge === "left" ? -filletOffset : anchorEdge === "right" ? filletOffset : 0
    readonly property real tensionY: anchorEdge === "top"  ? -filletOffset : anchorEdge === "bottom" ? filletOffset : 0

    PanelWindow {
        visible: rootScope.showPanel || rootScope.animProgress > 0
        color:   "transparent"

        WlrLayershell.layer:         WlrLayer.Overlay
        exclusionMode:               ExclusionMode.Ignore
        WlrLayershell.keyboardFocus: rootScope.keyboardFocus
        WlrLayershell.namespace:     "quickshell-panel"

        anchors {
            top:    rootScope.anchoredTop
            bottom: rootScope.anchoredBottom
            left:   rootScope.anchoredLeft
            right:  rootScope.anchoredRight
        }

        margins {
            top:    anchors.top    ? (Config.navbarLocation === "top"    ? rootScope.navbarOffset + rootScope.visualGap : rootScope.borderGap + rootScope.visualGap) : 0
            bottom: anchors.bottom ? (Config.navbarLocation === "bottom" ? rootScope.navbarOffset + rootScope.visualGap : rootScope.borderGap + rootScope.visualGap) : 0
            left:   anchors.left   ? (Config.navbarLocation === "left"   ? rootScope.navbarOffset + rootScope.visualGap : rootScope.borderGap + rootScope.visualGap) : 0
            right:  anchors.right  ? (Config.navbarLocation === "right"  ? rootScope.navbarOffset + rootScope.visualGap : rootScope.borderGap + rootScope.visualGap) : 0
        }

        implicitWidth:  rootScope.panelWidth  + (rootScope.hasLeftSpace ? rootScope.tensionRadius : 0) + (rootScope.hasRightSpace ? rootScope.tensionRadius : 0)
        implicitHeight: rootScope.panelHeight + (rootScope.hasTopSpace  ? rootScope.tensionRadius : 0) + (rootScope.hasBottomSpace ? rootScope.tensionRadius : 0)

        Item {
            anchors.fill: parent
            clip: true

            Item {
                id: movingPanel
                width:  rootScope.panelWidth
                height: rootScope.panelHeight
                
                x: rootScope.hasLeftSpace ? rootScope.tensionRadius : 0
                y: rootScope.hasTopSpace  ? rootScope.tensionRadius : 0

                opacity: rootScope.animationPreset === "fade"  ? rootScope.animProgress : 1.0
                scale:   rootScope.animationPreset === "scale" ? 0.9 + (0.1 * rootScope.animProgress) : 1.0

                transform: Translate { x: rootScope.slideX; y: rootScope.slideY }

                Rectangle {
                    id: bg
                    color:  Colors.background
                    radius: rootScope.panelRadius
                    border.width: 0

                    anchors {
                        fill:         parent
                        topMargin:    rootScope.anchoredTop    ? -radius : 0
                        bottomMargin: rootScope.anchoredBottom ? -radius : 0
                        leftMargin:   rootScope.anchoredLeft   ? -radius : 0
                        rightMargin:  rootScope.anchoredRight  ? -radius : 0
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

            Shape {
                visible: rootScope.f_top_left
                anchors { left: parent.left; top: parent.top }
                width: rootScope.tensionRadius; height: rootScope.tensionRadius
                transform: Translate { x: rootScope.anchorEdge === "top" ? 0 : rootScope.slideX; y: rootScope.anchorEdge === "top" ? rootScope.tensionY : 0 }
                ShapePath {
                    fillColor: Colors.background; strokeWidth: 0
                    startX: rootScope.tensionRadius; startY: rootScope.tensionRadius
                    PathLine { x: rootScope.tensionRadius; y: 0 }
                    PathLine { x: 0; y: 0 }
                    PathArc  { x: rootScope.tensionRadius; y: rootScope.tensionRadius; radiusX: rootScope.tensionRadius; radiusY: rootScope.tensionRadius; direction: PathArc.Clockwise }
                }
            }

            Shape {
                visible: rootScope.f_top_right
                anchors { right: parent.right; top: parent.top }
                width: rootScope.tensionRadius; height: rootScope.tensionRadius
                transform: Translate { x: rootScope.anchorEdge === "top" ? 0 : rootScope.slideX; y: rootScope.anchorEdge === "top" ? rootScope.tensionY : 0 }
                ShapePath {
                    fillColor: Colors.background; strokeWidth: 0
                    startX: rootScope.tensionRadius; startY: 0
                    PathLine { x: 0; y: 0 }
                    PathLine { x: 0; y: rootScope.tensionRadius }
                    PathArc  { x: rootScope.tensionRadius; y: 0; radiusX: rootScope.tensionRadius; radiusY: rootScope.tensionRadius; direction: PathArc.Clockwise }
                }
            }

            Shape {
                visible: rootScope.f_bottom_left
                anchors { left: parent.left; bottom: parent.bottom }
                width: rootScope.tensionRadius; height: rootScope.tensionRadius
                transform: Translate { x: rootScope.anchorEdge === "bottom" ? 0 : rootScope.slideX; y: rootScope.anchorEdge === "bottom" ? rootScope.tensionY : 0 }
                ShapePath {
                    fillColor: Colors.background; strokeWidth: 0
                    startX: 0; startY: rootScope.tensionRadius
                    PathLine { x: rootScope.tensionRadius; y: rootScope.tensionRadius }
                    PathLine { x: rootScope.tensionRadius; y: 0 }
                    PathArc  { x: 0; y: rootScope.tensionRadius; radiusX: rootScope.tensionRadius; radiusY: rootScope.tensionRadius; direction: PathArc.Clockwise }
                }
            }

            Shape {
                visible: rootScope.f_bottom_right
                anchors { right: parent.right; bottom: parent.bottom }
                width: rootScope.tensionRadius; height: rootScope.tensionRadius
                transform: Translate { x: rootScope.anchorEdge === "bottom" ? 0 : rootScope.slideX; y: rootScope.anchorEdge === "bottom" ? rootScope.tensionY : 0 }
                ShapePath {
                    fillColor: Colors.background; strokeWidth: 0
                    startX: 0; startY: 0
                    PathLine { x: 0; y: rootScope.tensionRadius }
                    PathLine { x: rootScope.tensionRadius; y: rootScope.tensionRadius }
                    PathArc  { x: 0; y: 0; radiusX: rootScope.tensionRadius; radiusY: rootScope.tensionRadius; direction: PathArc.Clockwise }
                }
            }

            Shape {
                visible: rootScope.f_left_top
                anchors { left: parent.left; top: parent.top }
                width: rootScope.tensionRadius; height: rootScope.tensionRadius
                transform: Translate { x: rootScope.anchorEdge === "left" ? rootScope.tensionX : 0; y: rootScope.anchorEdge === "left" ? 0 : rootScope.slideY }
                ShapePath {
                    fillColor: Colors.background; strokeWidth: 0
                    startX: 0; startY: 0
                    PathLine { x: 0; y: rootScope.tensionRadius }
                    PathLine { x: rootScope.tensionRadius; y: rootScope.tensionRadius }
                    PathArc  { x: 0; y: 0; radiusX: rootScope.tensionRadius; radiusY: rootScope.tensionRadius; direction: PathArc.Clockwise }
                }
            }

            Shape {
                visible: rootScope.f_left_bottom
                anchors { left: parent.left; bottom: parent.bottom }
                width: rootScope.tensionRadius; height: rootScope.tensionRadius
                transform: Translate { x: rootScope.anchorEdge === "left" ? rootScope.tensionX : 0; y: rootScope.anchorEdge === "left" ? 0 : rootScope.slideY }
                ShapePath {
                    fillColor: Colors.background; strokeWidth: 0
                    startX: rootScope.tensionRadius; startY: 0
                    PathLine { x: 0; y: 0 }
                    PathLine { x: 0; y: rootScope.tensionRadius }
                    PathArc  { x: rootScope.tensionRadius; y: 0; radiusX: rootScope.tensionRadius; radiusY: rootScope.tensionRadius; direction: PathArc.Clockwise }
                }
            }

            Shape {
                visible: rootScope.f_right_top
                anchors { right: parent.right; top: parent.top }
                width: rootScope.tensionRadius; height: rootScope.tensionRadius
                transform: Translate { x: rootScope.anchorEdge === "right" ? rootScope.tensionX : 0; y: rootScope.anchorEdge === "right" ? 0 : rootScope.slideY }
                ShapePath {
                    fillColor: Colors.background; strokeWidth: 0
                    startX: 0; startY: rootScope.tensionRadius
                    PathLine { x: rootScope.tensionRadius; y: rootScope.tensionRadius }
                    PathLine { x: rootScope.tensionRadius; y: 0 }
                    PathArc  { x: 0; y: rootScope.tensionRadius; radiusX: rootScope.tensionRadius; radiusY: rootScope.tensionRadius; direction: PathArc.Clockwise }
                }
            }

            Shape {
                visible: rootScope.f_right_bottom
                anchors { right: parent.right; bottom: parent.bottom }
                width: rootScope.tensionRadius; height: rootScope.tensionRadius
                transform: Translate { x: rootScope.anchorEdge === "right" ? rootScope.tensionX : 0; y: rootScope.anchorEdge === "right" ? 0 : rootScope.slideY }
                ShapePath {
                    fillColor: Colors.background; strokeWidth: 0
                    startX: rootScope.tensionRadius; startY: rootScope.tensionRadius
                    PathLine { x: rootScope.tensionRadius; y: 0 }
                    PathLine { x: 0; y: 0 }
                    PathArc  { x: rootScope.tensionRadius; y: rootScope.tensionRadius; radiusX: rootScope.tensionRadius; radiusY: rootScope.tensionRadius; direction: PathArc.Clockwise }
                }
            }
        }
    }
}