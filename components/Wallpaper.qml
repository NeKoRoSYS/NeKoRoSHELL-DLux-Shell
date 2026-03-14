// components/Wallpaper.qml
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick
import QtMultimedia
import qs.global

Scope {
    id: rootScope
    
    Variants {
        model: Quickshell.screens
        
        PanelWindow {
            id: wallpaperWindow
            required property var modelData
            screen: modelData

            anchors { top: true; bottom: true; left: true; right: true }
            
            WlrLayershell.layer: WlrLayer.Background
            exclusionMode: ExclusionMode.Ignore
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
            
            color: Colors.background

            property string rawPath: Config.wallpaperPath
            property string resolvedPath: rawPath.startsWith("~") ? rawPath.replace("~", Quickshell.env("HOME")) : rawPath
            property bool isVideo: rawPath.match(/\.(mp4|webm|mkv|mov|avi)$/i) !== null

            property bool isDesktopFocused: Hyprland.activeToplevel === null
            property bool shouldPlayVideo: isVideo && isDesktopFocused

            onShouldPlayVideoChanged: {
                if (isVideo) {
                    if (shouldPlayVideo) player.play()
                    else player.pause()
                }
            }

            onIsDesktopFocusedChanged: {
                if (!isDesktopFocused) {
                    parallaxContainer.targetX = 0;
                    parallaxContainer.targetY = 0;
                }
            }

            property string path1: ""
            property string path2: ""
            property bool useFirst: true

            Component.onCompleted: {
                if (!isVideo && resolvedPath !== "") {
                    path1 = "file://" + resolvedPath;
                    useFirst = true;
                }
            }

            onResolvedPathChanged: {
                if (!isVideo && resolvedPath !== "") {
                    useFirst = !useFirst;
                    if (useFirst) {
                        path1 = "file://" + resolvedPath;
                    } else {
                        path2 = "file://" + resolvedPath;
                    }
                }
            }

            property bool parallaxEnabledSafe: ("enableParallax" in Config) ? Config.enableParallax : (("parallaxEnabled" in Config) ? Config.parallaxEnabled : true)

            Item {
                id: parallaxContainer
                anchors.fill: parent
                scale: wallpaperWindow.parallaxEnabledSafe ? 1.05 : 1
                
                property real targetX: 0
                property real targetY: 0
                
                transform: Translate {
                    x: parallaxContainer.targetX
                    y: parallaxContainer.targetY
                    
                    Behavior on x { 
                        enabled: wallpaperWindow.isDesktopFocused
                        NumberAnimation { duration: Animations.slow; easing.type: Animations.easeOut } 
                    }
                    Behavior on y { 
                        enabled: wallpaperWindow.isDesktopFocused
                        NumberAnimation { duration: Animations.slow; easing.type: Animations.easeOut } 
                    }
                }

                Image {
                    id: img1
                    anchors.fill: parent
                    source: wallpaperWindow.path1
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: false
                    
                    sourceSize.width: wallpaperWindow.width
                    sourceSize.height: wallpaperWindow.height
                    mipmap: true
                    smooth: true
                    
                    opacity: (!wallpaperWindow.isVideo && wallpaperWindow.useFirst && wallpaperWindow.path1 !== "") ? 1 : 0
                    Behavior on opacity { 
                        NumberAnimation { duration: 800; easing.type: Easing.InOutCubic } 
                    }
                }

                Image {
                    id: img2
                    anchors.fill: parent
                    source: wallpaperWindow.path2
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: false
                    
                    sourceSize.width: wallpaperWindow.width
                    sourceSize.height: wallpaperWindow.height
                    mipmap: true
                    smooth: true
                    
                    opacity: (!wallpaperWindow.isVideo && !wallpaperWindow.useFirst && wallpaperWindow.path2 !== "") ? 1 : 0
                    Behavior on opacity { 
                        NumberAnimation { duration: 800; easing.type: Easing.InOutCubic } 
                    }
                }

                VideoOutput {
                    id: videoOut
                    anchors.fill: parent
                    fillMode: VideoOutput.PreserveAspectCrop
                    
                    opacity: wallpaperWindow.isVideo ? 1 : 0
                    Behavior on opacity { 
                        NumberAnimation { duration: 800; easing.type: Easing.InOutCubic } 
                    }
                }
            }

            MediaPlayer {
                id: player
                source: (wallpaperWindow.isVideo && wallpaperWindow.resolvedPath !== "") ? "file://" + wallpaperWindow.resolvedPath : ""
                audioOutput: AudioOutput { volume: 0.0 }
                videoOutput: videoOut
                loops: MediaPlayer.Infinite
                
                autoPlay: true 
                
                onMediaStatusChanged: {
                    if (mediaStatus === MediaPlayer.BufferedMedia || mediaStatus === MediaPlayer.LoadedMedia) {
                        if (!wallpaperWindow.shouldPlayVideo) {
                            pause();
                        }
                    }
                }
            }

            MouseArea {
                id: parallaxArea
                anchors.fill: parent
                
                hoverEnabled: wallpaperWindow.parallaxEnabledSafe && wallpaperWindow.isDesktopFocused
                acceptedButtons: Qt.NoButton 

                onPositionChanged: (mouse) => {
                    let offsetX = (mouse.x - width / 2) / (width / 2)
                    let offsetY = (mouse.y - height / 2) / (height / 2)
                    
                    let maxOffset = 25 
                    
                    parallaxContainer.targetX = -offsetX * maxOffset
                    parallaxContainer.targetY = -offsetY * maxOffset
                }

                onExited: {
                    parallaxContainer.targetX = 0
                    parallaxContainer.targetY = 0
                }
            }

            Connections {
                target: Config
                ignoreUnknownSignals: true
                function onEnableParallaxChanged() {
                    if (Config.enableParallax === false) {
                        parallaxContainer.targetX = 0
                        parallaxContainer.targetY = 0
                    }
                }
            }
        }
    }
}