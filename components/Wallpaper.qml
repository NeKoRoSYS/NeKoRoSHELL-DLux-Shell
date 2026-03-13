// components/Wallpaper.qml
import Quickshell
import Quickshell.Wayland
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

            Image {
                id: img1
                anchors.fill: parent
                source: wallpaperWindow.path1
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                
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
                asynchronous: true
                
                sourceSize.width: wallpaperWindow.width
                sourceSize.height: wallpaperWindow.height
                mipmap: true
                smooth: true
                
                opacity: (!wallpaperWindow.isVideo && !wallpaperWindow.useFirst && wallpaperWindow.path2 !== "") ? 1 : 0
                Behavior on opacity { 
                    NumberAnimation { duration: 800; easing.type: Easing.InOutCubic } 
                }
            }

            MediaPlayer {
                id: player
                source: (wallpaperWindow.isVideo && wallpaperWindow.resolvedPath !== "") ? "file://" + wallpaperWindow.resolvedPath : ""
                audioOutput: AudioOutput { volume: 0.0 }
                videoOutput: videoOut
                loops: MediaPlayer.Infinite
                autoPlay: true
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
    }
}