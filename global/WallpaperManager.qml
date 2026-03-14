// global/WallpaperManager.qml
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.global

QtObject {
    id: root
    
    property var wallpapers: []
    property bool isLoading: false
    property var wallhavenResults: []
    property bool isSearching: false

    signal wallhavenFetched()
    
    property var jsonLoader: FileView {
        path: Quickshell.env("HOME") + "/.cache/quickshell/wallpapers.json"
        
        watchChanges: true
        onFileChanged: reload()
        
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

    property var downloaderComponent: Component {
        Process {
            property string targetPath: ""
            
            onExited: function(exitCode) { 
                if (exitCode === 0 && targetPath !== "") {
                    root.setWallpaper(targetPath);
                }
                this.destroy();
            }
        }
    }

    function downloadWallpaper(url) {
        if (!url) return;
        
        let fileName = url.split('/').pop().split('?')[0];
        if (!fileName) fileName = "dl_" + Date.now() + ".jpg";
        let fullPath = Quickshell.env("HOME") + "/.config/wallpapers/" + fileName;

        let proc = downloaderComponent.createObject(root, {
            command: ["bash", Quickshell.env("HOME") + "/.config/quickshell/scripts/download-wallpaper.sh", url],
            targetPath: fullPath
        });
        proc.running = true;
    }

    function searchWallhaven(query) {
        if (query.length < 3) return;
        root.isSearching = true;
        let xhr = new XMLHttpRequest();
        xhr.open("GET", "https://wallhaven.cc/api/v1/search?q=" + encodeURIComponent(query));
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) { 
                    let res = JSON.parse(xhr.responseText);
                    root.wallhavenResults = res.data.map(item => ({
                        name: "WH-" + item.id,
                        path: item.path,
                        thumb: item.thumbs.original || item.thumbs.large,
                        isRemote: true
                    }));
                    root.wallhavenFetched(); 
                }
                root.isSearching = false;
            }
        };
        xhr.send();
    }

    function refresh() {
        root.isLoading = true;
        root.scanner.running = false;
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