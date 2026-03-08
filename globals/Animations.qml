// globals/Animations.qml
pragma Singleton

import QtQuick

QtObject {
    readonly property int fast:   125
    readonly property int normal: 275
    readonly property int slow:   1000

    readonly property int easeOut:   Easing.OutCubic
    readonly property int easeInOut: Easing.InOutCubic
    readonly property int easeBack:  Easing.OutBack
}
