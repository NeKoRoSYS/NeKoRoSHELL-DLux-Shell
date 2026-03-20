// components/Panel.qml
import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Shapes
import qs.global

Scope {
    id: rootScope

    property alias  screen:          panelWindow.screen
    property string panelId:         ""

    property bool   showPanel:       false
    
    property real   edgePadding:     typeof Style.panelPadding !== "undefined" ? Style.panelPadding : 25
    property real   panelWidth:      typeof Style.panelWidth !== "undefined" ? Style.panelWidth : 400
    property real   panelHeight:     typeof Style.panelHeight !== "undefined" ? Style.panelHeight : 400
    
    property real   navbarOffset:    0
    property real   visualGap:       0
    property int    keyboardFocus:   WlrKeyboardFocus.OnDemand
    property string animationPreset: "slide"

    property string anchorEdge:      Config.navbarLocation // top, left, bottom, right, center, fullscreen
    property string anchorAlignment: "center"              // start, center, end
    property real   borderGap:       Config.enableBorders && !Config.transparentNavbar ? (typeof Style.borderWidth !== "undefined" ? Style.borderWidth : 10) : Config.transparentNavbar ? (typeof Style.borderWidth !== "undefined" ? Style.borderWidth : 10) : 0

    readonly property real panelRadius:   typeof Style.panelRadius !== "undefined" ? Style.panelRadius : 20
    readonly property real filletRadius: panelRadius

    readonly property bool isHorizontal:    anchorEdge === "top"    || anchorEdge === "bottom"
    readonly property bool isVertical:      anchorEdge === "left"   || anchorEdge === "right"
    readonly property bool isCenter:        anchorEdge === "center"
    readonly property bool isFullscreen:    anchorEdge === "fullscreen"

    readonly property real transparentGap: Config.transparentNavbar ? ((typeof Style.barSize !== "undefined" ? Style.barSize : 40) / 2) : 0

    readonly property bool anchoredTop:     isFullscreen || anchorEdge === "top"    || (isVertical   && anchorAlignment === "start")
    readonly property bool anchoredBottom:  isFullscreen || anchorEdge === "bottom" || (isVertical   && anchorAlignment === "end")
    readonly property bool anchoredLeft:    isFullscreen || anchorEdge === "left"   || (isHorizontal && anchorAlignment === "start")
    readonly property bool anchoredRight:   isFullscreen || anchorEdge === "right"  || (isHorizontal && anchorAlignment === "end")

    readonly property bool enableFillets: !Config.transparentNavbar

    readonly property bool f_top_left:     anchoredTop    && !anchoredLeft   && enableFillets
    readonly property bool f_top_right:    anchoredTop    && !anchoredRight  && enableFillets
    readonly property bool f_bottom_left:  anchoredBottom && !anchoredLeft   && enableFillets
    readonly property bool f_bottom_right: anchoredBottom && !anchoredRight  && enableFillets
    readonly property bool f_left_top:     anchoredLeft   && !anchoredTop    && enableFillets
    readonly property bool f_left_bottom:  anchoredLeft   && !anchoredBottom && enableFillets
    readonly property bool f_right_top:    anchoredRight  && !anchoredTop    && enableFillets
    readonly property bool f_right_bottom: anchoredRight  && !anchoredBottom && enableFillets

    readonly property bool hasLeftSpace:   f_top_left || f_bottom_left
    readonly property bool hasRightSpace:  f_top_right || f_bottom_right
    readonly property bool hasTopSpace:    f_left_top || f_right_top
    readonly property bool hasBottomSpace: f_left_bottom || f_right_bottom

    default property Component panelContent

    property bool isMapped: false
    Timer {
        id: mapTimer
        interval: 15
        running: rootScope.showPanel
        onTriggered: rootScope.isMapped = true
    }
    onShowPanelChanged: {
        if (!showPanel) rootScope.isMapped = false;
    }

    property real animProgress: rootScope.showPanel ? 1.0 : 0.0
    Behavior on animProgress { NumberAnimation { duration: 500; easing.type: Easing.OutCubic } }

    readonly property real gapTop:    rootScope.anchoredTop    && !isFullscreen ? (Config.navbarLocation === "top"    ? rootScope.navbarOffset + rootScope.visualGap + transparentGap : rootScope.borderGap + rootScope.visualGap) : 0
    readonly property real gapBottom: rootScope.anchoredBottom && !isFullscreen ? (Config.navbarLocation === "bottom" ? rootScope.navbarOffset + rootScope.visualGap + transparentGap : rootScope.borderGap + rootScope.visualGap) : 0
    readonly property real gapLeft:   rootScope.anchoredLeft   && !isFullscreen ? (Config.navbarLocation === "left"   ? rootScope.navbarOffset + rootScope.visualGap + transparentGap : rootScope.borderGap + rootScope.visualGap) : 0
    readonly property real gapRight:  rootScope.anchoredRight  && !isFullscreen ? (Config.navbarLocation === "right"  ? rootScope.navbarOffset + rootScope.visualGap + transparentGap : rootScope.borderGap + rootScope.visualGap) : 0

    readonly property real maxSlidePx: anchorEdge === "top"    ? rootScope.panelHeight + gapTop :
                                       anchorEdge === "bottom" ? rootScope.panelHeight + gapBottom :
                                       anchorEdge === "left"   ? rootScope.panelWidth  + gapLeft :
                                       anchorEdge === "right"  ? rootScope.panelWidth  + gapRight :
                                       (isHorizontal ? rootScope.panelHeight : rootScope.panelWidth)

    readonly property real slideOffset: rootScope.animationPreset === "slide" ? (rootScope.maxSlidePx * (1.0 - rootScope.animProgress)) : 0
    readonly property real currentVisiblePx: (isHorizontal ? rootScope.panelHeight : rootScope.panelWidth) - slideOffset
    readonly property real filletOffset: rootScope.animationPreset === "slide" ? Math.max(0, rootScope.panelRadius - currentVisiblePx + 8) : 0
    
    readonly property real slideX: anchorEdge === "left" ? -slideOffset : anchorEdge === "right" ? slideOffset : 0
    readonly property real slideY: anchorEdge === "top"  ? -slideOffset : anchorEdge === "bottom" ? slideOffset : 0
    readonly property real filletX: anchorEdge === "left" ? -filletOffset : anchorEdge === "right" ? filletOffset : 0
    readonly property real filletY: anchorEdge === "top"  ? -filletOffset : anchorEdge === "bottom" ? filletOffset : 0

    Variants {
        model: Quickshell.screens

        PanelWindow {
            required property var modelData
            screen: modelData

            visible: rootScope.showPanel && rootScope.panelId !== ""
            color:   "transparent"

            WlrLayershell.layer:         WlrLayer.Top
            exclusionMode:               ExclusionMode.Ignore
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
            WlrLayershell.namespace:     "quickshell-panel-dismiss"

            anchors { top: true; bottom: true; left: true; right: true }

            MouseArea {
                anchors.fill: parent
                onClicked:    EventBus.togglePanel(rootScope.panelId)
                hoverEnabled: false
            }
        }
    }

    PanelWindow {
        id: panelWindow
        visible: rootScope.isMapped || rootScope.animProgress > 0
        color:   "transparent"

        WlrLayershell.layer:         WlrLayer.Top
        exclusionMode:               ExclusionMode.Ignore
        WlrLayershell.keyboardFocus: rootScope.keyboardFocus
        WlrLayershell.namespace:     "quickshell-panel"

        anchors {
            top:    rootScope.anchoredTop
            bottom: rootScope.anchoredBottom
            left:   rootScope.anchoredLeft
            right:  rootScope.anchoredRight
        }

        implicitWidth:  (isFullscreen ? 0 : rootScope.panelWidth)  + (rootScope.hasLeftSpace ? rootScope.filletRadius : 0) + (rootScope.hasRightSpace ? rootScope.filletRadius : 0) + gapLeft + gapRight
        implicitHeight: (isFullscreen ? 0 : rootScope.panelHeight) + (rootScope.hasTopSpace  ? rootScope.filletRadius : 0) + (rootScope.hasBottomSpace ? rootScope.filletRadius : 0) + gapTop + gapBottom

        Item {
            anchors.fill: parent
            clip: true 

            Item {
                id: contentWrapper

                anchors.fill: parent
                anchors.topMargin: gapTop
                anchors.bottomMargin: gapBottom
                anchors.leftMargin: gapLeft
                anchors.rightMargin: gapRight
                
                readonly property color surfaceColor: Config.transparentNavbar ? Qt.rgba(Colors.background.r, Colors.background.g, Colors.background.b, 0.6) : Colors.background

                Item {
                    id: animationWrapper
                    anchors.fill: parent
                    
                    opacity: rootScope.animationPreset === "fade"  ? rootScope.animProgress : 1.0
                    scale:   rootScope.animationPreset === "scale" ? 0.9 + (0.1 * rootScope.animProgress) : 1.0

                    transform: Translate { x: rootScope.slideX; y: rootScope.slideY }

                    Item {
                        id: movingPanel
                        width:  isFullscreen ? parent.width  : rootScope.panelWidth
                        height: isFullscreen ? parent.height : rootScope.panelHeight
                        
                        x: rootScope.hasLeftSpace ? rootScope.filletRadius : 0
                        y: rootScope.hasTopSpace  ? rootScope.filletRadius : 0

                        Rectangle {
                            id: bg
                            color: contentWrapper.surfaceColor
                            radius: isFullscreen ? 0 : rootScope.panelRadius
                            
                            border.width: Config.transparentNavbar ? 1 : 0
                            border.color: Config.transparentNavbar ? Qt.rgba(1, 1, 1, 0.15) : "transparent"

                            Behavior on color        { ColorAnimation  { duration: Animations.normal; easing.type: Animations.easeInOut } }
                            Behavior on border.color { ColorAnimation  { duration: Animations.normal; easing.type: Animations.easeInOut } }
                            Behavior on border.width { NumberAnimation { duration: Animations.normal; easing.type: Animations.easeInOut } }

                            anchors {
                                fill:         parent
                                topMargin:    (rootScope.anchoredTop    && enableFillets) ? -radius : 0
                                bottomMargin: (rootScope.anchoredBottom && enableFillets) ? -radius : 0
                                leftMargin:   (rootScope.anchoredLeft   && enableFillets) ? -radius : 0
                                rightMargin:  (rootScope.anchoredRight  && enableFillets) ? -radius : 0
                            }
                        }

                        Item {
                            anchors.fill:    parent
                            anchors.margins: rootScope.edgePadding
                            clip: true

                            Loader {
                                anchors.fill: parent
                                active: rootScope.showPanel || rootScope.isMapped || rootScope.animProgress > 0
                                sourceComponent: rootScope.panelContent
                            }
                        }
                    }
                }

                Loader {
                    active: rootScope.f_top_left
                    anchors { left: parent.left; top: parent.top }
                    transform: Translate { x: rootScope.anchorEdge === "top" ? 0 : rootScope.slideX; y: rootScope.anchorEdge === "top" ? rootScope.filletY : 0 }
                    sourceComponent: Component {
                        Shape {
                            width: rootScope.filletRadius; height: rootScope.filletRadius
                            antialiasing: true
                            smooth: true
                            layer.enabled: true
                            layer.samples: 8
                            ShapePath {
                                fillColor: contentWrapper.surfaceColor; strokeWidth: 0
                                startX: rootScope.filletRadius; startY: rootScope.filletRadius
                                PathLine { x: rootScope.filletRadius; y: 0 }
                                PathLine { x: 0; y: 0 }
                                PathArc  { x: rootScope.filletRadius; y: rootScope.filletRadius; radiusX: rootScope.filletRadius; radiusY: rootScope.filletRadius; direction: PathArc.Clockwise }
                            }
                        }
                    }
                }

                Loader {
                    active: rootScope.f_top_right
                    anchors { right: parent.right; top: parent.top }
                    transform: Translate { x: rootScope.anchorEdge === "top" ? 0 : rootScope.slideX; y: rootScope.anchorEdge === "top" ? rootScope.filletY : 0 }
                    sourceComponent: Component {
                        Shape {
                            width: rootScope.filletRadius; height: rootScope.filletRadius
                            antialiasing: true
                            smooth: true
                            layer.enabled: true
                            layer.samples: 8
                            ShapePath {
                                fillColor: contentWrapper.surfaceColor; strokeWidth: 0
                                startX: rootScope.filletRadius; startY: 0
                                PathLine { x: 0; y: 0 }
                                PathLine { x: 0; y: rootScope.filletRadius }
                                PathArc  { x: rootScope.filletRadius; y: 0; radiusX: rootScope.filletRadius; radiusY: rootScope.filletRadius; direction: PathArc.Clockwise }
                            }
                        }
                    }
                }

                Loader {
                    active: rootScope.f_bottom_left
                    anchors { left: parent.left; bottom: parent.bottom }
                    transform: Translate { x: rootScope.anchorEdge === "bottom" ? 0 : rootScope.slideX; y: rootScope.anchorEdge === "bottom" ? rootScope.filletY : 0 }
                    sourceComponent: Component {
                        Shape {
                            width: rootScope.filletRadius; height: rootScope.filletRadius
                            antialiasing: true
                            smooth: true
                            layer.enabled: true
                            layer.samples: 8
                            ShapePath {
                                fillColor: contentWrapper.surfaceColor; strokeWidth: 0
                                startX: 0; startY: rootScope.filletRadius
                                PathLine { x: rootScope.filletRadius; y: rootScope.filletRadius }
                                PathLine { x: rootScope.filletRadius; y: 0 }
                                PathArc  { x: 0; y: rootScope.filletRadius; radiusX: rootScope.filletRadius; radiusY: rootScope.filletRadius; direction: PathArc.Clockwise }
                            }
                        }
                    }
                }

                Loader {
                    active: rootScope.f_bottom_right
                    anchors { right: parent.right; bottom: parent.bottom }
                    transform: Translate { x: rootScope.anchorEdge === "bottom" ? 0 : rootScope.slideX; y: rootScope.anchorEdge === "bottom" ? rootScope.filletY : 0 }
                    sourceComponent: Component {
                        Shape {
                            width: rootScope.filletRadius; height: rootScope.filletRadius
                            antialiasing: true
                            smooth: true
                            layer.enabled: true
                            layer.samples: 8
                            ShapePath {
                                fillColor: contentWrapper.surfaceColor; strokeWidth: 0
                                startX: 0; startY: 0
                                PathLine { x: 0; y: rootScope.filletRadius }
                                PathLine { x: rootScope.filletRadius; y: rootScope.filletRadius }
                                PathArc  { x: 0; y: 0; radiusX: rootScope.filletRadius; radiusY: rootScope.filletRadius; direction: PathArc.Clockwise }
                            }
                        }
                    }
                }

                Loader {
                    active: rootScope.f_left_top
                    anchors { left: parent.left; top: parent.top }
                    transform: Translate { x: rootScope.anchorEdge === "left" ? rootScope.filletX : 0; y: rootScope.anchorEdge === "left" ? 0 : rootScope.slideY }
                    sourceComponent: Component {
                        Shape {
                            width: rootScope.filletRadius; height: rootScope.filletRadius
                            antialiasing: true
                            smooth: true
                            layer.enabled: true
                            layer.samples: 8
                            ShapePath {
                                fillColor: contentWrapper.surfaceColor; strokeWidth: 0
                                startX: 0; startY: 0
                                PathLine { x: 0; y: rootScope.filletRadius }
                                PathLine { x: rootScope.filletRadius; y: rootScope.filletRadius }
                                PathArc  { x: 0; y: 0; radiusX: rootScope.filletRadius; radiusY: rootScope.filletRadius; direction: PathArc.Clockwise }
                            }
                        }
                    }
                }

                Loader {
                    active: rootScope.f_left_bottom
                    anchors { left: parent.left; bottom: parent.bottom }
                    transform: Translate { x: rootScope.anchorEdge === "left" ? rootScope.filletX : 0; y: rootScope.anchorEdge === "left" ? 0 : rootScope.slideY }
                    sourceComponent: Component {
                        Shape {
                            width: rootScope.filletRadius; height: rootScope.filletRadius
                            antialiasing: true
                            smooth: true
                            layer.enabled: true
                            layer.samples: 8
                            ShapePath {
                                fillColor: contentWrapper.surfaceColor; strokeWidth: 0
                                startX: rootScope.filletRadius; startY: 0
                                PathLine { x: 0; y: 0 }
                                PathLine { x: 0; y: rootScope.filletRadius }
                                PathArc  { x: rootScope.filletRadius; y: 0; radiusX: rootScope.filletRadius; radiusY: rootScope.filletRadius; direction: PathArc.Clockwise }
                            }
                        }
                    }
                }

                Loader {
                    active: rootScope.f_right_top
                    anchors { right: parent.right; top: parent.top }
                    transform: Translate { x: rootScope.anchorEdge === "right" ? rootScope.filletX : 0; y: rootScope.anchorEdge === "right" ? 0 : rootScope.slideY }
                    sourceComponent: Component {
                        Shape {
                            width: rootScope.filletRadius; height: rootScope.filletRadius
                            antialiasing: true
                            smooth: true
                            layer.enabled: true
                            layer.samples: 8
                            ShapePath {
                                fillColor: contentWrapper.surfaceColor; strokeWidth: 0
                                startX: 0; startY: rootScope.filletRadius
                                PathLine { x: rootScope.filletRadius; y: rootScope.filletRadius }
                                PathLine { x: rootScope.filletRadius; y: 0 }
                                PathArc  { x: 0; y: rootScope.filletRadius; radiusX: rootScope.filletRadius; radiusY: rootScope.filletRadius; direction: PathArc.Clockwise }
                            }
                        }
                    }
                }

                Loader {
                    active: rootScope.f_right_bottom
                    anchors { right: parent.right; bottom: parent.bottom }
                    transform: Translate { x: rootScope.anchorEdge === "right" ? rootScope.filletX : 0; y: rootScope.anchorEdge === "right" ? 0 : rootScope.slideY }
                    sourceComponent: Component {
                        Shape {
                            width: rootScope.filletRadius; height: rootScope.filletRadius
                            antialiasing: true
                            smooth: true
                            layer.enabled: true
                            layer.samples: 8
                            ShapePath {
                                fillColor: contentWrapper.surfaceColor; strokeWidth: 0
                                startX: rootScope.filletRadius; startY: rootScope.filletRadius
                                PathLine { x: rootScope.filletRadius; y: 0 }
                                PathLine { x: 0; y: 0 }
                                PathArc  { x: rootScope.filletRadius; y: rootScope.filletRadius; radiusX: rootScope.filletRadius; radiusY: rootScope.filletRadius; direction: PathArc.Clockwise }
                            }
                        }
                    }
                }
            }
        }
    }
}