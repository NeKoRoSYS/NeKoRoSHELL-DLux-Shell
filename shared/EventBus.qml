// quickshell/shared/EventBus.qml
pragma Singleton

import QtQuick

QtObject {
    signal togglePanel(string panelId)
    signal changeLocation(string newLocation)
    signal toggleBorders(bool state)
    signal toggleLightMode(bool state)
}