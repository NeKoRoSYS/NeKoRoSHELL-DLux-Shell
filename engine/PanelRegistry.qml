// engine/PanelRegistry.qml
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Scope {
    id: root

    property string configRoot: Qt.resolvedUrl("../")

    function getBuiltIn() {
        return [
            { id: "dashboard",     file: root.configRoot + "/panels/Dashboard.qml",        anchor: "top",    align: "center", screen: "active" },
            { id: "settings",      file: root.configRoot + "/panels/Settings.qml",         align: "end",    screen: "active" },
            { id: "advanced",      file: root.configRoot + "/panels/AdvancedSettings.qml", align: "end",    screen: "active" },
            { id: "tray",          file: root.configRoot + "/panels/Tray.qml",             anchor: "right",  align: "end",    screen: "active" },
            { id: "launcher",      file: root.configRoot + "/panels/Launcher.qml",         anchor: "bottom", align: "center", screen: "active" },
            { id: "wallpaper",     file: root.configRoot + "/panels/WallpaperPicker.qml",  anchor: "bottom", align: "center", screen: "active" },
            { id: "clipboard",     file: root.configRoot + "/panels/Clipboard.qml",        anchor: "right",  align: "center", screen: "active" },
            { id: "notifications", file: root.configRoot + "/panels/Notifications.qml",    anchor: "right",  align: "center", screen: "active" },
            { id: "overview",      file: root.configRoot + "/panels/Overview.qml",         anchor: "center", align: "center", screen: "active" },
            { id: "power",         file: root.configRoot + "/panels/PowerManager.qml",     anchor: "center", align: "center", screen: "active" }
        ];
    }

    property var userPanels: []
    property var allPanels:  []

    Component.onCompleted: {
        let builtIn = root.getBuiltIn();
        root.allPanels = builtIn.concat(root.userPanels); 
        console.log("[PanelRegistry] Booted! Total panels ready: " + root.allPanels.length);
    }

    FileView {
        path: Quickshell.shellDir + "/user/panels/panels.json"
        
        adapter: JsonAdapter {
            property var panels: ({})
            
            onPanelsChanged: {
                if (panels && typeof panels === 'object') {
                    let parsed = [];
                    for (let key in panels) {
                        if (panels.hasOwnProperty(key)) {
                            let p = panels[key];
                            parsed.push({
                                id: key, 
                                file: root.configRoot + p.path, 
                                anchor: p.anchor,
                                align: p.align,
                                screen: p.screen || "active"
                            });
                        }
                    }
                    root.userPanels = parsed;
                    root.allPanels = root.getBuiltIn().concat(root.userPanels); 
                    console.log("[PanelRegistry] Sandbox updated! Total panels: " + root.allPanels.length);
                }
            }
        }
    }
}