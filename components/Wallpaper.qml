// components/Wallpaper.qml
import Quickshell
import Quickshell.Wayland
import QtQuick
import QtMultimedia
import qs.globals

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

            Image {
                anchors.fill: parent
                source: (!wallpaperWindow.isVideo && wallpaperWindow.resolvedPath !== "") ? "file://" + wallpaperWindow.resolvedPath : ""
                fillMode: Image.PreserveAspectCrop
                visible: !wallpaperWindow.isVideo
                asynchronous: true
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
                visible: wallpaperWindow.isVideo
            }
        }
    }
}