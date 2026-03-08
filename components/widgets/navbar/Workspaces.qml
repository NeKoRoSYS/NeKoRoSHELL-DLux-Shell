// quickshell/components/widgets/navbar/Workspaces.qml
import QtQuick
import Quickshell.Hyprland
import qs.shared
import qs.components

Item {
    id: root
    
    readonly property bool isSide: !navbar.isHorizontal
    readonly property real baseSize: (isSide ? parent.width : parent.height) / 1.65

    readonly property int maxIcons: 5

    implicitWidth: isSide ? parent.width : (container.implicitWidth + 15)
    implicitHeight: isSide ? (container.implicitHeight + 15) : parent.height

    Rectangle {
        anchors.centerIn: parent
        width: root.isSide ? (root.baseSize) : (container.implicitWidth + 15)
        height: root.isSide ? (container.implicitHeight + 15) : (root.baseSize)
        radius: (root.isSide ? width : height) / 2
        
        color: Colors.color3
        opacity: 0.325
    }

    Grid {
        id: container
        anchors.centerIn: parent
        
        columns: root.isSide ? 1 : 0
        rows: root.isSide ? 0 : 1
        spacing: 15
        
        Repeater {
            id: workspaceRepeater
            model: Hyprland.workspaces

            delegate: Item {
                id: workspaceDelegate
                required property var modelData
                required property int index

                implicitWidth: layout.implicitWidth
                implicitHeight: layout.implicitHeight

                Rectangle {
                    anchors.centerIn: layout
                    
                    visible: appRepeater.count > 1
                    
                    width: root.isSide ? root.baseSize : (layout.implicitWidth - root.baseSize)
                    height: root.isSide ? (layout.implicitHeight - root.baseSize) : root.baseSize
                    
                    color: Colors.color3
                    radius: 1.5
                }

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
                        
                        color: wsMouseArea.containsMouse ? "white" : (workspaceDelegate.modelData.focused ? "white" : Colors.color3)
                        Behavior on color { ColorAnimation { duration: 150 } }

                        Text {
                            anchors.centerIn: parent
                            anchors.horizontalCenterOffset: 1
                            text: workspaceDelegate.modelData.focused ? "󰣇" : workspaceDelegate.modelData.name
                            color: wsMouseArea.containsMouse ? "black" : (workspaceDelegate.modelData.focused ? "black" : "white")
                            Behavior on color { ColorAnimation { duration: 150 } }
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 12
                            font.weight: Font.ExtraBold
                        }

                        MouseArea {
                            id: wsMouseArea
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            hoverEnabled: true
                            onClicked: workspaceDelegate.modelData.activate()
                        }
                    }

                    Repeater {
                        id: appRepeater
                        model: workspaceDelegate.modelData.toplevels

                        delegate: Rectangle {
                            id: appDelegate
                            required property var modelData
                            required property int index
                            property string cachedClass: ""
                            readonly property bool isFocusedApp: modelData.activated && workspaceDelegate.modelData.focused

                            visible: index < root.maxIcons
                            
                            height: root.baseSize
                            width: height
                            radius: height / 2
                            
                            color: appMouseArea.containsMouse ? "white" : (isFocusedApp ? "white" : Colors.color3)
                            Behavior on color { ColorAnimation { duration: 150 } }

                            Text {
                                anchors.centerIn: parent
                                anchors.horizontalCenterOffset: 0.25
                                anchors.verticalCenterOffset: 1
                                text: {
                                    let appClass = "";

                                    if (modelData.wayland && modelData.wayland.appId) {
                                        appClass = modelData.wayland.appId.toLowerCase();
                                    } else {
                                        let ipc = modelData.lastIpcObject || {};
                                        appClass = (ipc["class"] || ipc["initialClass"] || modelData.title || "?").toLowerCase();
                                    }
                                    
                                    const iconMap = {
                                        "firefox": "󰈹",
                                        "kitty": "󰄛",
                                        "alacritty": "󰄛",
                                        "discord": "󰙯",
                                        "vesktop": "󰙯",
                                        "code": "󰨞",
                                        "code-oss": "󰨞",
                                        "unity": "󰚯",
                                        "unityhub": "󰚯",
                                        "thunar": "󰉋",
                                        "nautilus": "󰉋",
                                        "spotify": "󰓇",
                                        "steam": "󰓓",
                                        "obs": "󰑋",
                                        "vlc": "󰕼",
                                        "mpv": "󰕼",
                                        "org.kde.dolphin": "󰉋"
                                    };

                                    if (iconMap[appClass]) {
                                        return iconMap[appClass];
                                    }
                                    
                                    return appClass.substring(0, 1).toUpperCase();
                                }
                                
                                color: appMouseArea.containsMouse ? "black" : (isFocusedApp ? Colors.color3 : "white")
                                Behavior on color { ColorAnimation { duration: 150 } }
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 14 
                            }

                            MouseArea {
                                id: appMouseArea
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                hoverEnabled: true
                                onClicked: {
                                    let command = "focuswindow address:0x" + modelData.address;
                                    console.log("Dispatching to Hyprland:", command);
                                    
                                    Hyprland.dispatch(command);
                                }
                            }
                        }
                    }

                    Rectangle {
                        visible: appRepeater.count > root.maxIcons
                        
                        height: root.baseSize
                        width: height
                        radius: height / 2
                        
                        color: overflowMouseArea.containsMouse ? "white" : Colors.color3
                        Behavior on color { ColorAnimation { duration: 150 } }
                        
                        Text {
                            anchors.centerIn: parent
                            anchors.horizontalCenterOffset: -2
                            anchors.verticalCenterOffset: 1
                            
                            text: "+" + (appRepeater.count - root.maxIcons)
                            
                            color: overflowMouseArea.containsMouse ? "black" : "white"
                            Behavior on color { ColorAnimation { duration: 150 } }
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 11
                            font.weight: Font.ExtraBold
                        }
                        
                        MouseArea {
                            id: overflowMouseArea
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            hoverEnabled: true
                            onClicked: workspaceDelegate.modelData.activate()
                        }
                    }
                }

                Rectangle {
                    visible: workspaceDelegate.index < (workspaceRepeater.count - 1)
                    
                    width: root.isSide ? root.baseSize * 0.5 : 2
                    height: root.isSide ? 2 : root.baseSize * 0.5
                    radius: 1

                    color: Colors.foreground
                    opacity: 0.15

                    x: root.isSide ? (layout.width - width) / 2 : layout.width + (15 - width) / 2
                    y: root.isSide ? layout.height + (15 - height) / 2 : (layout.height - height) / 2
                }
            }
        }
    }
}