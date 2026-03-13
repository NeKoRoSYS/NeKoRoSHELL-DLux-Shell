// panels/Overview.qml
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.global
import qs.components

Panel {
    id: overviewPanel

    property var liveMonitor: Hyprland.focusedMonitor
    
    property real lockedMonitorWidth: 1920
    property var lockedScreen: Quickshell.primaryScreen

    screen: lockedScreen

    property real spacingAmount: 10
    property real cols: 5
    property real rows: 2
    
    property real contentW: lockedMonitorWidth / 1.5
    property real tileW: (contentW - spacingAmount * (cols + 1)) / cols - 10
    property real tileH: tileW * 9 / 16

    panelWidth: contentW
    panelHeight: (tileH * rows) + (spacingAmount * (rows + 1)) + 100
    animationPreset: "slide"
    anchorAlignment: "center"
    
    onShowPanelChanged: {
        if (showPanel) {
            Hyprland.refreshWorkspaces();
            Hyprland.refreshToplevels();
            if (liveMonitor) {
                lockedMonitorWidth = liveMonitor.width / liveMonitor.scale;
                let foundScreen = Quickshell.screens.find(s => s.name === liveMonitor.name);
                if (foundScreen) {
                    lockedScreen = foundScreen;
                }
            }
            forceActiveFocus();
        }
    }

    Keys.onEscapePressed: EventBus.togglePanel("overview")

    Rectangle {
        id: overviewRoot
        anchors.fill: parent
        color: Colors.background
        border.color: Colors.color13
        border.width: 2
        radius: 10
        clip: true

        Item {
            id: header
            width: parent.width
            height: 40
            anchors.top: parent.top

            Text {
                text: "󰕮  Workspace Overview"
                color: Colors.foreground
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 16
                font.weight: Font.Bold
                anchors.centerIn: parent
            }

            Rectangle {
                width: 24; height: 24
                radius: 12
                color: "transparent"
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.margins: 10
                
                Text {
                    anchors.centerIn: parent
                    text: ""
                    font.family: "JetBrainsMono Nerd Font"
                    color: Colors.color8
                }
                
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    onEntered: parent.color = Colors.color1
                    onExited: parent.color = "transparent"
                    onClicked: EventBus.togglePanel("overview")
                }
            }
        }

        Rectangle { 
            id: sep
            width: parent.width; height: 2; color: Colors.color13
            anchors.top: header.bottom 
        }

        GridLayout {
            id: overviewLayout
            anchors.top: sep.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: spacingAmount

            columns: overviewPanel.cols
            rows: overviewPanel.rows
            rowSpacing: spacingAmount
            columnSpacing: spacingAmount

            Repeater {
                model: overviewPanel.rows * overviewPanel.cols
                
                WorkspaceView {
                    parentWindow: overviewRoot
                    
                    Layout.preferredWidth: overviewPanel.tileW 
                    Layout.preferredHeight: overviewPanel.tileH
                    width: overviewPanel.tileW
                    height: overviewPanel.tileH
                }
            }
        }
    }
}