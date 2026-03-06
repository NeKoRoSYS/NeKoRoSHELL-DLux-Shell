// quickshell/components/widgets/navbar/Workspaces.qml
import QtQuick
import Quickshell.Hyprland
import qs.shared
import qs.components

ListView {
    id: root
    
    readonly property bool isSide: !navbar.isHorizontal
    orientation: isSide ? ListView.Vertical : ListView.Horizontal
    spacing: 15
    
    model: Hyprland.workspaces

    readonly property real baseSize: (isSide ? parent.width : parent.height) / 1.65

    implicitWidth: isSide ? parent.width : contentWidth
    implicitHeight: isSide ? contentHeight : parent.height

    clip: false 

    delegate: Item {
        id: workspaceDelegate
        required property var modelData

        width: root.isSide ? ListView.view.width : layout.implicitWidth
        height: root.isSide ? layout.implicitHeight : ListView.view.height

        Flow {
            id: layout
            anchors.centerIn: parent
            flow: root.isSide ? Flow.TopToBottom : Flow.LeftToRight
            spacing: 6

            Rectangle {
                visible: appRepeater.count === 0

                height: root.baseSize
                width: height
                radius: height / 2
                
                color: workspaceDelegate.modelData.focused ? Colors.color7 : Colors.color5
                Behavior on color { ColorAnimation { duration: 150 } }

                Text {
                    anchors.centerIn: parent
                    text: workspaceDelegate.modelData.focused ? "󰣇" : workspaceDelegate.modelData.name
                    color: workspaceDelegate.modelData.focused ? Colors.background : Colors.foreground
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 12
                    font.weight: Font.ExtraBold
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: workspaceDelegate.modelData.activate()
                }
            }

            Repeater {
                id: appRepeater
                model: workspaceDelegate.modelData.toplevels

                delegate: Rectangle {
                    required property var modelData 
                    
                    height: root.baseSize
                    width: height
                    radius: height / 2
                    
                    color: modelData.activated ? Colors.color7 : Colors.color5
                    Behavior on color { ColorAnimation { duration: 150 } }

                    Text {
                        anchors.centerIn: parent
                        text: {
                            let ipc = modelData.lastIpcObject || {};
                            let appClass = ipc["class"] || ipc["initialClass"] || modelData.title || "?";
                            
                            return appClass.substring(0, 1).toUpperCase();
                        }
                        color: modelData.activated ? Colors.background : Colors.foreground
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 12
                        font.weight: Font.Bold
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            let command = "focuswindow address:0x" + modelData.address;
                            console.log("Dispatching to Hyprland:", command);
                            
                            Hyprland.dispatch(command);
                        }
                    }
                }
            }
        }
    }
}