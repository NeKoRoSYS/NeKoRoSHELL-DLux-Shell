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

            Workspaces {
                x: navbar.isHorizontal ? 35 : (parent.width - width) / 2
                y: navbar.isHorizontal ? (parent.height - height) / 2 : 35
            }

            Clock {
                location: navbar.location
                clockSize: navbar.fontSize
                clockFont: navbar.font
                anchors.centerIn: parent
            }

            ButtonsRow { 
                x: navbar.isHorizontal ? parent.width - width - 35 : (parent.width - width) / 2
                y: navbar.isHorizontal ? (parent.height - height) / 2 : parent.height - height - 35
            }
        }
    }
}
