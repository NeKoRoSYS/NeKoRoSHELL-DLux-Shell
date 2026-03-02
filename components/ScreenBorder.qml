// quickshell/components/ScreenBorder.qml
// qmllint disable
import Quickshell
import QtQuick
import QtQuick.Shapes
import "../shared"

Scope {
    id: border
    property string location
    property real borderWidth
    property real cornerRadius
    property color borderColor

    Variants {
        model: Quickshell.screens
        Scope {
            required property var modelData
            property var currentScreen: modelData

            PanelWindow {
                screen: currentScreen
                anchors { top: true; left: true; right: true }
                implicitHeight: border.borderWidth
                color: border.borderColor
                visible: border.location !== "top"
            }

            PanelWindow {
                screen: currentScreen
                anchors { top: true; left: true; bottom: true }
                implicitWidth: border.borderWidth
                color: border.borderColor
                visible: border.location !== "left"
            }

            PanelWindow {
                screen: currentScreen
                anchors { bottom: true; left: true; right: true }
                implicitHeight: border.borderWidth
                color: border.borderColor
                visible: border.location !== "bottom"
            }

            PanelWindow {
                screen: currentScreen
                anchors { top: true; right: true; bottom: true }
                implicitWidth: border.borderWidth
                color: border.borderColor
                visible: border.location !== "right"
            }

            PanelWindow {
                screen: currentScreen
                implicitHeight: border.cornerRadius
                implicitWidth: border.cornerRadius
                color: "transparent"
                anchors { top: true; left: true }
                Rectangle {
                    Shape {
                        anchors.fill: parent
                        preferredRendererType: Shape.CurveRenderer
                        ShapePath {
                            strokeWidth: 0
                            fillColor: border.borderColor
                            startX: 0; startY: border.cornerRadius
                            PathArc { x: border.cornerRadius; y: 0; radiusX: border.cornerRadius; radiusY: border.cornerRadius; direction: PathArc.Clockwise }
                            PathLine { x: 0; y: 0 }
                            PathLine { x: 0; y: border.cornerRadius }
                        }
                    }
                }
            }

            PanelWindow {
                screen: currentScreen
                implicitHeight: border.cornerRadius
                implicitWidth: border.cornerRadius
                color: "transparent"
                anchors { top: true; right: true }
                Rectangle {
                    Shape {
                        anchors.fill: parent
                        preferredRendererType: Shape.CurveRenderer
                        ShapePath {
                            strokeWidth: 0
                            fillColor: border.borderColor
                            startX: 0; startY: 0
                            PathArc { x: border.cornerRadius; y: border.cornerRadius; radiusX: border.cornerRadius; radiusY: border.cornerRadius; direction: PathArc.Clockwise }
                            PathLine { x: border.cornerRadius; y: 0 }
                            PathLine { x: 0; y: 0 }
                        }
                    }
                }
            }

            PanelWindow {
                screen: currentScreen
                implicitHeight: border.cornerRadius
                implicitWidth: border.cornerRadius
                color: "transparent"
                anchors { bottom: true; left: true }
                Rectangle {
                    Shape {
                        anchors.fill: parent
                        preferredRendererType: Shape.CurveRenderer
                        ShapePath {
                            strokeWidth: 0
                            fillColor: border.borderColor
                            startX: border.cornerRadius; startY: border.cornerRadius
                            PathArc { x: 0; y: 0; radiusX: border.cornerRadius; radiusY: border.cornerRadius; direction: PathArc.Clockwise }
                            PathLine { x: 0; y: border.cornerRadius }
                            PathLine { x: border.cornerRadius; y: border.cornerRadius }
                        }
                    }
                }
            }

            PanelWindow {
                screen: currentScreen
                implicitHeight: border.cornerRadius
                implicitWidth: border.cornerRadius
                color: "transparent"
                anchors { bottom: true; right: true }
                Rectangle {
                    Shape {
                        anchors.fill: parent
                        preferredRendererType: Shape.CurveRenderer
                        ShapePath {
                            strokeWidth: 0
                            fillColor: border.borderColor
                            startX: 0; startY: border.cornerRadius
                            PathLine { x: border.cornerRadius; y: border.cornerRadius }
                            PathLine { x: border.cornerRadius; y: 0 }
                            PathArc { x: 0; y: border.cornerRadius; radiusX: border.cornerRadius; radiusY: border.cornerRadius; direction: PathArc.Clockwise }
                        }
                    }
                }
            }
        }
    }
}