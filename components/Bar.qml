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

            implicitHeight: (navbar.location === "top" || navbar.location === "bottom") ? navbar.barSize : undefined
            implicitWidth: (navbar.location === "left" || navbar.location === "right") ? navbar.barSize : undefined

           Workspaces {
                anchors {
                    left: (navbar.location === "top" || navbar.location === "bottom") ? parent.left : undefined
                    leftMargin: (navbar.location === "top" || navbar.location === "bottom") ? 35 : 0
                    bottom: (navbar.location === "left" || navbar.location === "right") ? parent.bottom : undefined
                    bottomMargin: (navbar.location === "left" || navbar.location === "right") ? 35 : 0
                    verticalCenter: (left !== undefined) ? parent.verticalCenter : undefined
                    horizontalCenter: (bottom !== undefined) ? parent.horizontalCenter : undefined
                }
            }

            Clock {
                location: navbar.location
                clockSize: navbar.fontSize
                clockFont: navbar.font
                anchors.centerIn: parent
            }

            ButtonsRow { }
        }
    }
}
