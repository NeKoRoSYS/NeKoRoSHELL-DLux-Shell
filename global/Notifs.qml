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

    property var activePopups: []

    function removePopup(notification) {
        let idx = activePopups.indexOf(notification);
        if (idx !== -1) {
            let newArr = activePopups.slice();
            newArr.splice(idx, 1);
            activePopups = newArr;
        }
    }

    onNotification: (notification) => {
        notification.tracked = true;
        if (!Config.dndEnabled) {
            activePopups = activePopups.concat([notification]);
        }
    }
}