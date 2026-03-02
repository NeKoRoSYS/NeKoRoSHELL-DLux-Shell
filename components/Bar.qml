// quickshell/components/Bar.qml
pragma ComponentBehavior: Bound

import Quickshell
import QtQuick
import "widgets"

Scope {
    id: navbar
    property color barColor
    property real barSize
    property real fontSize
    property string font: "JetBrainsMono Nerd Font"
    property string appearance
    property string location: "top"
    readonly property bool isHorizontal: location === "top" || location === "bottom"
    readonly property bool isVertical: location === "left" || location === "right"

    signal toggleSettingsPanel()

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
            implicitWidth: navbar.isVertical ? navbar.barSize : undefined

           Workspaces {
                anchors {
                    left: navbar.isHorizontal ? parent.left : undefined
                    leftMargin: navbar.isHorizontal ? 35 : 0
                    top: navbar.isVertical ? parent.top : undefined
                    topMargin: navbar.isVertical ? 35 : 0
                    verticalCenter: navbar.isHorizontal ? parent.verticalCenter : undefined
                    horizontalCenter: navbar.isVertical ? parent.horizontalCenter : undefined
                }
            }

            Clock {
                location: navbar.location
                clockSize: navbar.fontSize
                clockFont: navbar.font
                anchors.centerIn: parent
            }

            ButtonsRow { onToggleSettingsPanel: navbar.toggleSettingsPanel() }
        }
    }
}
