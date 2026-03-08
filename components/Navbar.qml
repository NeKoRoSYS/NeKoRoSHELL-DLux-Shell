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

            readonly property real totalCenterWidth: workspacesObj.width + clockObj.width + buttonsObj.width + (widgetGap * 2)
            readonly property real totalCenterHeight: workspacesObj.height + clockObj.height + buttonsObj.height + (widgetGap * 2)
            
            readonly property real centerStartX: (width - totalCenterWidth) / 2
            readonly property real centerStartY: (height - totalCenterHeight) / 2

            Workspaces {
                id: workspacesObj
                x: navbar.isHorizontal ? 
                    (isCentered ? centerStartX : 35) : 
                    (parent.width - width) / 2
                y: navbar.isHorizontal ? 
                    (parent.height - height) / 2 : 
                    (isCentered ? centerStartY : 35)
                Behavior on x { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }
                Behavior on y { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }
            }

            Clock {
                id: clockObj
                location: navbar.location
                clockSize: navbar.fontSize
                clockFont: navbar.font
                
                x: navbar.isHorizontal ?
                    (isCentered ? (centerStartX + workspacesObj.width + widgetGap) : (parent.width - width) / 2) :
                    (parent.width - width) / 2
                y: navbar.isHorizontal ?
                    (parent.height - height) / 2 :
                    (isCentered ? (centerStartY + workspacesObj.height + widgetGap) : (parent.height - height) / 2)

                Behavior on x { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }
                Behavior on y { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }
            }

            ButtonsRow { 
                id: buttonsObj
                x: navbar.isHorizontal ?
                    (isCentered ? (centerStartX + workspacesObj.width + clockObj.width + (widgetGap * 2)) : parent.width - width - 35) :
                    (parent.width - width) / 2
                y: navbar.isHorizontal ?
                    (parent.height - height) / 2 :
                    (isCentered ? (centerStartY + workspacesObj.height + clockObj.height + (widgetGap * 2)) : parent.height - height - 35)
                Behavior on x { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }
                Behavior on y { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }
            }
        }
    }
}
