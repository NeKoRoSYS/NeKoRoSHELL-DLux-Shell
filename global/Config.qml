// global/Config.qml
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property string configPath: Quickshell.env("HOME") + "/.config/quickshell/config.json"
    readonly property string tmpPath:    Quickshell.env("HOME") + "/.config/quickshell/.config.json.tmp"

    property string navbarLocation: "top"
    property bool   transparentNavbar: false
    property bool   enableBorders:  true
    property string activeLayout:   "default"
    
    property bool enableParallax: false
    property bool lightMode: false
    property string wallpaperPath: "/home/nekorosys/.config/wallpapers/1145396.png"

    property bool dndEnabled:       false

    readonly property bool isHorizontal: navbarLocation === "top" || navbarLocation === "bottom"

    FileView {
        id: configFile
        path: root.configPath

        adapter: JsonAdapter {
            id: configAdapter

            property string navbarLocation: "top"
            property bool   transparentNavbar: false
            property bool   enableBorders:  true
            property string activeLayout:   "default"
            property bool enableParallax: false
            property bool lightMode: false
            property string wallpaperPath: ""
            property bool dndEnabled:       false

            onNavbarLocationChanged: root.navbarLocation = navbarLocation
            onTransparentNavbarChanged: root.transparentNavbar = transparentNavbar
            onEnableBordersChanged:  root.enableBorders  = enableBorders
            onActiveLayoutChanged:   root.activeLayout   = activeLayout
            onEnableParallaxChanged:      root.enableParallax = enableParallax
            onLightModeChanged:      root.lightMode      = lightMode
            onWallpaperPathChanged:  root.wallpaperPath  = wallpaperPath
            onDndEnabledChanged:     root.dndEnabled     = dndEnabled
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
        if (key === "transparentNavbar")  root.transparentNavbar  = value;
        if (key === "enableBorders")  root.enableBorders  = value;
        if (key === "activeLayout")   root.activeLayout   = value;
        if (key === "enableParallax") root.enableParallax = value;
        if (key === "lightMode")      root.lightMode      = value;
        if (key === "wallpaperPath")  root.wallpaperPath  = value;
        if (key === "dndEnabled")  root.dndEnabled  = value;

        saveTimer.restart();
    }

    function executeSave() {
        let fileData = {
            navbarLocation: root.navbarLocation,
            transparentNavbar: root.transparentNavbar,
            enableBorders: root.enableBorders,
            activeLayout: root.activeLayout,
            enableParallax: root.enableParallax,
            lightMode: root.lightMode,
            wallpaperPath: root.wallpaperPath,
            dndEnabled: root.dndEnabled
        };
        
        let jsonString = JSON.stringify(fileData, null, 2);
        
        Quickshell.execDetached({
            command: ["sh", "-c", `echo '${jsonString.replace(/'/g, "'\\''")}' > "${root.configPath}"`]
        });
    }
}
