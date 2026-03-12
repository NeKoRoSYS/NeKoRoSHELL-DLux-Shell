// globals/Notifs.qml
pragma Singleton
import QtQuick
import Quickshell.Services.Notifications

NotificationServer {
    id: server
    bodySupported: true
    actionsSupported: true
    actionIconsSupported: true
    imageSupported: true
}