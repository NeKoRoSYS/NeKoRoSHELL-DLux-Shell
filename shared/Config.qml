// quickshell/shared/Config.qml
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property string configDir: Quickshell.env("HOME") + "/.config/quickshell"
    readonly property string configPath: configDir + "/config.json"
    readonly property string tmpPath: configDir + "/config_tmp.json"

    property string navbarLocation: "top"
    property string navbarLayout: "edges"
    property bool enableBorders: true
    property bool lightMode: false
    property string wallpaperPath: "/home/nekorosys/.config/wallpapers/1145396.png"

    FileView {
        id: configFile
        path: root.configPath

        adapter: JsonAdapter {
            id: configAdapter
            
            property string navbarLocation: "top"
            property string navbarLayout: "edges"
            property bool enableBorders: true
            property bool lightMode: false
            property string wallpaperPath: ""

            onNavbarLocationChanged: root.navbarLocation = navbarLocation
            onNavbarLayoutChanged: root.navbarLayout = navbarLayout
            onEnableBordersChanged: root.enableBorders = enableBorders
            onLightModeChanged: root.lightMode = lightMode
            onWallpaperPathChanged: root.wallpaperPath = wallpaperPath
        }
    }

    Timer {
        id: saveTimer
        interval: 100
        repeat: false
        onTriggered: root.executeSave()
    }

    function saveSetting(key, value) {
        if (key === "navbarLocation") root.navbarLocation = value;
        if (key === "navbarLayout") root.navbarLayout = value;
        if (key === "enableBorders") root.enableBorders = value;
        if (key === "lightMode") root.lightMode = value;
        if (key === "wallpaperPath") root.wallpaperPath = value;

        saveTimer.restart();
    }

    function executeSave() {
        let fileData = {
            navbarLocation: root.navbarLocation,
            enableBorders: root.enableBorders,
            navbarLayout: root.navbarLayout,
            lightMode: root.lightMode,
            wallpaperPath: root.wallpaperPath
        };

        let jsonString = JSON.stringify(fileData, null, 2);
        
        let safeJson = jsonString.replace(/'/g, "'\\''");

        Quickshell.execDetached({
            command: [
                "sh", 
                "-c", 
                `mkdir -p "${root.configDir}" && echo '${safeJson}' > "${root.tmpPath}" && mv "${root.tmpPath}" "${root.configPath}"`
            ]
        });
    }
}