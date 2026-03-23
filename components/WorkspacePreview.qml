// components/WorkspacePreview.qml
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Widgets
import qs.global

Rectangle {
    id: root
    visible: true 
    clip: true 
    
    required property int index
    required property Item parentWindow
    
    property var wsp: {
        let w = Hyprland.workspaces.values;
        return w ? w.find(s => s.id === (root.index + 1)) : null;
    }
    
    property var activeMonitor: (wsp && wsp.monitor) ? wsp.monitor : Hyprland.focusedMonitor
    property real scaleFactor: (activeMonitor && width > 0) ? ((activeMonitor.width / activeMonitor.scale) / width) : 1
    
    color: Colors.color0
    radius: 8
    border.width: 2
    border.color: dropArea.containsDrag ? Colors.color5 : Colors.color13

    Connections {
        target: (root.wsp) ? root.wsp.toplevels : null
        function onObjectInsertedPost() { Hyprland.refreshToplevels() }
        function onObjectRemovedPre() { Hyprland.refreshToplevels() }
        function onObjectRemovedPost() { Hyprland.refreshToplevels() }
        function onObjectInsertedPre() { Hyprland.refreshToplevels() }
    }

    Text {
        font.family: "JetBrains Mono"
        font.pixelSize: 64
        font.weight: Font.Bold
        color: Colors.color1
        text: root.index + 1
        anchors.centerIn: parent
    }

    DropArea {
        id: dropArea
        anchors.fill: parent
        onDropped: function(drag) { 
            var address = drag.source.address
            if (address) {
                Hyprland.dispatch("movetoworkspacesilent " + (root.index + 1) + ", address:" + address)
                Hyprland.refreshWorkspaces()
                Hyprland.refreshMonitors()
                Hyprland.refreshToplevels()
            }
        }
    }

    Repeater {
        model: (root.wsp && root.wsp.toplevels) ? root.wsp.toplevels : []
        
        ScreencopyView {
            id: scView
            required property HyprlandToplevel modelData
            
            property var ipcObj: modelData.lastIpcObject || {}
            property var atPos: (ipcObj.at !== undefined) ? ipcObj.at : [0, 0]
            property var wSize: (ipcObj.size !== undefined) ? ipcObj.size : [0, 0]
            property string address: ipcObj.address || ""
            
            captureSource: modelData.wayland
            live: true 
            
            x: (root.activeMonitor && root.scaleFactor > 0) ? ((atPos[0] - root.activeMonitor.x) / root.scaleFactor) : 0
            y: (root.activeMonitor && root.scaleFactor > 0) ? ((atPos[1] - root.activeMonitor.y) / root.scaleFactor) : 0
            width: root.scaleFactor > 0 ? (wSize[0] / root.scaleFactor) : 0
            height: root.scaleFactor > 0 ? (wSize[1] / root.scaleFactor) : 0

            Component.onCompleted: Hyprland.refreshToplevels()

            DragHandler {
                id: dragHandler
                target: scView
                onActiveChanged: {
                    if (!active) { 
                        target.Drag.drop()
                    }
                }
            }

            Drag.active: dragHandler.active
            Drag.source: scView
            Drag.supportedActions: Qt.MoveAction
            Drag.hotSpot.x: width / 2
            Drag.hotSpot.y: height / 2

            states: [
                State {
                    when: dragHandler.active
                    ParentChange {
                        target: scView
                        parent: root.parentWindow 
                    }
                }
            ]
        }
    }
}