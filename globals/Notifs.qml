pragma Singleton
import QtQuick
import Quickshell.Services.Notifications
import qs.globals

NotificationServer {
    id: server
    bodySupported: true
    actionsSupported: true
    actionIconsSupported: true
    imageSupported: true

    property var activePopups: []

    function addPopup(notification) {
        let arr = activePopups;
        arr.push(notification);
        activePopups = arr;
    }

    function removePopup(notification) {
        let arr = activePopups;
        let idx = arr.indexOf(notification);
        if (idx !== -1) {
            arr.splice(idx, 1);
            activePopups = arr;
        }
    }

    onNotification: (notification) => {
        notification.tracked = true;
        
        if (!Config.dndEnabled) {
            addPopup(notification);
        }
    }
}