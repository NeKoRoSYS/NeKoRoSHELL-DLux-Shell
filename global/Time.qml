// global/Time.qml
pragma Singleton

import Quickshell
import QtQuick

Singleton {
    id: root

    readonly property string time: Qt.formatDateTime(clock.date, "h:mm AP")
    readonly property string timeVertical: Qt.formatDateTime(clock.date, "h\nmm\nAP")
    readonly property string date: Qt.formatDateTime(clock.date, "dddd, MMMM d")

    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }
}
