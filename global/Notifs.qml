// global/Notifs.qml
pragma Singleton

import QtQuick
import Quickshell.Services.Notifications
import qs.global

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