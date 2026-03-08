// quickshell/components/Bar.qml
pragma ComponentBehavior: Bound

import Quickshell
import QtQuick
import QtQuick.Shapes
import qs.components.widgets.navbar

Scope {
    id: navbar
    property string appearance
    property string behavior: "static"
    property string location: "top"
    property string layout: "edges"
    property color barColor
    property real barSize
    property string font: "JetBrainsMono Nerd Font"
    property real fontSize
    readonly property bool isHorizontal: location === "top" || location === "bottom"

    Variants {
        model: Quickshell.screens

        PanelWindow {
            required property var modelData
            screen: modelData
            color: navbar.barColor

            anchors {
                top:    navbar.location !== "bottom"
                bottom: navbar.location !== "top"
                left:   navbar.location !== "right"
                right:  navbar.location !== "left"
            }

            implicitHeight: navbar.isHorizontal ? navbar.barSize : undefined
            implicitWidth: navbar.isHorizontal ? undefined : navbar.barSize

            readonly property real widgetGap: 15
            readonly property bool isCentered: navbar.layout == "center"

            Workspaces {
                id: workspacesObj
                x: navbar.isHorizontal ?
                    (isCentered ? (parent.width - (width + clockObj.width + buttonsObj.width + (widgetGap * 2))) / 2 : 35) :
                    (parent.width - width) / 2
                y: navbar.isHorizontal ?
                    (parent.height - height) / 2 :
                    (isCentered ? (parent.height - (height + clockObj.height + buttonsObj.height + (widgetGap * 2))) / 2 : 35)
                Behavior on x { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }
                Behavior on y { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }
            }

            Clock {
                id: clockObj
                location: navbar.location
                clockSize: navbar.fontSize
                clockFont: navbar.font
                
                x: navbar.isHorizontal ?
                    (isCentered ? workspacesObj.x + workspacesObj.width + widgetGap : (parent.width - width) / 2) :
                    (parent.width - width) / 2
                y: navbar.isHorizontal ?
                    (parent.height - height) / 2 :
                    (isCentered ? workspacesObj.y + workspacesObj.height + widgetGap : (parent.height - height) / 2)

                Behavior on x { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }
                Behavior on y { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }
            }

            ButtonsRow { 
                id: buttonsObj
                x: navbar.isHorizontal ?
                    (isCentered ? clockObj.x + clockObj.width + widgetGap : parent.width - width - 35) :
                    (parent.width - width) / 2
                y: navbar.isHorizontal ?
                    (parent.height - height) / 2 :
                    (isCentered ? clockObj.y + clockObj.height + widgetGap : parent.height - height - 35)
                
                Behavior on x { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }
                Behavior on y { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }
            }
        }
    }
}
