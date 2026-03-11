// globals/WallpaperManager.qml
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.globals

QtObject {
    id: root
    
    property var wallpapers: []
    property bool isLoading: false

    property var jsonLoader: FileView {
        path: Quickshell.env("HOME") + "/.cache/quickshell/wallpapers.json"
        
        adapter: JsonAdapter {
            id: wpAdapter
            
            property var wallpapers: []
            
            onWallpapersChanged: {
                if (wallpapers) {
                    root.wallpapers = wallpapers;
                    root.isLoading = false;
                }
            }
        }
    }

    property var scanner: Process {
        command: ["bash", Quickshell.env("HOME") + "/.config/quickshell/scripts/wallpaper-utils.sh"]
        running: true
    }

    function refresh() {
        root.isLoading = true;
        root.scanner.running = true;
    }

    function setWallpaper(path) {
        Config.saveSetting("wallpaperPath", path);
        Colors.reloadColors();
    }

    function setRandom() {
        if (root.wallpapers.length === 0) return;
        let index = Math.floor(Math.random() * root.wallpapers.length);
        root.setWallpaper(root.wallpapers[index].path);
    }
}