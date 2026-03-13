// modules/clock/Clock.qml
pragma Singleton

import QtQuick
import qs.global

QtObject {
    readonly property string moduleType: "custom"
    readonly property string time: Config.isHorizontal ? Time.time : Time.timeVertical
    readonly property string date: Time.date
}