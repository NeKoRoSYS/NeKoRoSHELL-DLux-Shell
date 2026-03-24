// engine/NotificationsEngine.qml
pragma Singleton

import Quickshell
import Quickshell.Wayland
import QtQuick
import Quickshell.Services.Notifications
import qs.global
import qs.components

Scope {
    id: root

    property alias activePopups: server.activePopups
    property alias trackedNotifications: server.trackedNotifications 
    
    function removePopup(notification) {
        server.removePopup(notification)
    }

    NotificationServer {
        id: server
        bodySupported: true
        actionsSupported: true
        actionIconsSupported: true
        imageSupported: true

        property var activePopups: ListModel {}

        function removePopup(notification) {
            for (let i = 0; i < activePopups.count; i++) {
                if (activePopups.get(i).notif === notification) {
                    activePopups.remove(i);
                    break;
                }
            }
        }

        onNotification: (notification) => {
            notification.tracked = true;
            if (!Config.dndEnabled) {
                activePopups.append({ "notif": notification });
            }
        }
    }

    Component.onCompleted: {
        console.log("Notification Daemon Active: " + server.bodySupported)
        let extra = [
            "/usr/share/pixmaps",
            Qt.resolvedUrl("file://" + Quickshell.env("HOME") + "/.local/share/icons"),
            Qt.resolvedUrl("file://" + Quickshell.env("HOME") + "/.icons"),
        ]
        
        let currentPaths = Qt.iconSearchPaths ?? [];
        let newPaths = currentPaths.slice();
        let needsUpdate = false;
        
        for (let p of extra) {
            if (!newPaths.includes(p)) {
                newPaths.push(p);
                needsUpdate = true;
            }
        }
        
        if (needsUpdate) {
            Qt.iconSearchPaths = newPaths;
        }
    }
}