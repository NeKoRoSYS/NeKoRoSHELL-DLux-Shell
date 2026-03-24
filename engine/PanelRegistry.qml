pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Scope {
    id: root

    property string configRoot: Qt.resolvedUrl("../")

    readonly property var builtInPanels: [
        { id: "dashboard",     file: root.configRoot + "/panels/Dashboard.qml",        edge: "top",    align: "center", screen: "active" },
        { id: "settings",      file: root.configRoot + "/panels/Settings.qml",         align: "end",    screen: "active" },
        { id: "advanced",      file: root.configRoot + "/panels/AdvancedSettings.qml", align: "end",    screen: "active" },
        { id: "tray",          file: root.configRoot + "/panels/Tray.qml",             align: "end",    screen: "active" },
        { id: "launcher",      file: root.configRoot + "/panels/Launcher.qml",         edge: "bottom", align: "center", screen: "active" },
        { id: "wallpaper",     file: root.configRoot + "/panels/WallpaperPicker.qml",  edge: "bottom", align: "center", screen: "active" },
        { id: "clipboard",     file: root.configRoot + "/panels/Clipboard.qml",        edge: "right",  align: "center", screen: "active" },
        { id: "notifications", file: root.configRoot + "/panels/Notifications.qml",    edge: "right",  align: "center", screen: "active" },
        { id: "overview",      file: root.configRoot + "/panels/Overview.qml",         edge: "center", align: "center", screen: "active" },
        { id: "power",         file: root.configRoot + "/panels/PowerManager.qml",     edge: "center", align: "center", screen: "active" }
    ]

    property var userPanels: []

    Component.onCompleted: {
        console.log("[PanelRegistry] Booted! Core panels ready: " + builtInPanels.length);
    }

    FileView {
        path: Quickshell.shellDir + "/user/panels/panels.json"
        
        adapter: JsonAdapter {
            property var panels: [] 
            
            onPanelsChanged: {
                if (panels !== undefined && panels !== null && typeof panels.length !== "undefined") {
                    let parsed = [];
                    
                    let prefix = root.configRoot.endsWith("/") ? root.configRoot : (root.configRoot + "/");
                    
                    for (let i = 0; i < panels.length; i++) {
                        let p = panels[i];
                        let suffix = p.path.startsWith("/") ? p.path.substring(1) : p.path;
                        
                        parsed.push({
                            id: p.id,
                            file: prefix + suffix, 
                            anchor: p.anchor,
                            align: p.align,
                            screen: p.screen || "active"
                        });
                    }
                    
                    root.userPanels = parsed;
                    console.log("[PanelRegistry] Sandbox loaded! User panels ready: " + root.userPanels.length);
                }
            }
        }
    }
}