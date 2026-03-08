// quickshell/shared/Config.qml
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property string configPath: Quickshell.env("HOME") + "/.config/quickshell/config.json"
    
    readonly property string tmpPath: Quickshell.env("HOME") + "/.config/quickshell/config_tmp.json"

    property string navbarLocation: "top"
    property bool enableBorders: true
    property bool lightMode: false
    property string wallpaperPath: "/home/nekorosys/.config/wallpapers/1145396.png"

    FileView {
        id: configFile
        path: root.configPath

        adapter: JsonAdapter {
            id: configAdapter
            
            property string navbarLocation: "top"
            property bool enableBorders: true
            property bool lightMode: false
            property string wallpaperPath: ""

            onNavbarLocationChanged: root.navbarLocation = navbarLocation
            onEnableBordersChanged: root.enableBorders = enableBorders
            onLightModeChanged: root.lightMode = lightMode
            onWallpaperPathChanged: root.wallpaperPath = wallpaperPath
        }
    }

    function saveSetting(key, value) {
        if (key === "navbarLocation") root.navbarLocation = value;
        if (key === "enableBorders") root.enableBorders = value;
        if (key === "lightMode") root.lightMode = value;
        if (key === "wallpaperPath") root.wallpaperPath = value;

        let fileData = {
            navbarLocation: root.navbarLocation,
            enableBorders: root.enableBorders,
            lightMode: root.lightMode,
            wallpaperPath: root.wallpaperPath
        };

        let jsonString = JSON.stringify(fileData, null, 2);

        Quickshell.execDetached({
            command: ["sh", "-c", `mkdir -p ~/.config/quickshell && echo '${jsonString}' > ${root.tmpPath} && mv ${root.tmpPath} ${root.configPath}`]
        });
    }
}