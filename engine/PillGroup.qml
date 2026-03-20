// engine/PillGroup.qml
pragma ComponentBehavior: Bound

import QtQuick
import qs.global

Item {
    id: root

    property bool isHorizontal: Config.isHorizontal
    property var  barScreen:    null
    property real moduleSize:   Style.moduleSize
    property var  modules:      []

    implicitWidth:  isHorizontal ? pillRow.implicitWidth + Style.pillPadding : moduleSize
    implicitHeight: isHorizontal ? moduleSize                                : pillCol.implicitHeight + Style.pillPadding

    Rectangle {
        anchors.fill: parent
        radius:       Style.pillRadius
        color:        Colors.color0
        opacity:      Style.pillOpacity
    }

    component PillDelegate: Loader {
        required property string modelData
        sourceComponent: ModuleRegistry.resolve(modelData)
        Binding { when: status === Loader.Ready; target: item; property: "isHorizontal"; value: root.isHorizontal }
        Binding { when: status === Loader.Ready; target: item; property: "barThickness";  value: root.moduleSize }
        Binding { when: status === Loader.Ready && item !== null && item.hasOwnProperty("inPill"); target: item; property: "inPill"; value: true }
        Binding { when: status === Loader.Ready && item !== null && item.hasOwnProperty("barScreen"); target: item; property: "barScreen"; value: root.barScreen }
    }

    Row {
        id: pillRow
        visible:          root.isHorizontal
        anchors.centerIn: parent
        spacing: Style.pillSpacing
        Repeater { model: root.isHorizontal ? root.modules : []; delegate: PillDelegate {} }
    }

    Column {
        id: pillCol
        visible:          !root.isHorizontal
        anchors.centerIn: parent
        spacing: Style.pillSpacing
        Repeater { model: root.isHorizontal ? [] : root.modules; delegate: PillDelegate {} }
    }
}
