// engine/SlotLayout.qml
pragma ComponentBehavior: Bound

import QtQuick
import qs.globals

Item {
    id: root

    property bool   isHorizontal: true
    property real   barSize:      40
    property string barFont:      "JetBrainsMono Nerd Font"
    property var    modules:      []

    implicitWidth:  isHorizontal ? row.implicitWidth  : col.implicitWidth
    implicitHeight: isHorizontal ? row.implicitHeight : col.implicitHeight

    Row {
        id: row
        visible: root.isHorizontal
        spacing: 8

        Repeater {
            model: root.isHorizontal ? root.modules : []
            delegate: Loader {
                id: hLoader
                required property string modelData
                sourceComponent: ModuleRegistry.resolve(modelData)
                Binding { when: hLoader.status === Loader.Ready; target: hLoader.item; property: "isHorizontal"; value: true }
                Binding { when: hLoader.status === Loader.Ready; target: hLoader.item; property: "barThickness";  value: root.barSize }
                Binding { when: hLoader.status === Loader.Ready; target: hLoader.item; property: "barFont";       value: root.barFont }
            }
        }
    }

    Column {
        id: col
        visible: !root.isHorizontal
        spacing: 8

        Repeater {
            model: root.isHorizontal ? [] : root.modules
            delegate: Loader {
                id: vLoader
                required property string modelData
                sourceComponent: ModuleRegistry.resolve(modelData)
                Binding { when: vLoader.status === Loader.Ready; target: vLoader.item; property: "isHorizontal"; value: false }
                Binding { when: vLoader.status === Loader.Ready; target: vLoader.item; property: "barThickness";  value: root.barSize }
                Binding { when: vLoader.status === Loader.Ready; target: vLoader.item; property: "barFont";       value: root.barFont }
            }
        }
    }
}
