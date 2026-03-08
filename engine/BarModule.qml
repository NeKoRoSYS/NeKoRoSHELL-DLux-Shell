// engine/BarModule.qml
pragma ComponentBehavior: Bound

import QtQuick

Item {
    id: root

    property bool   isHorizontal: true
    property real   barThickness: 40
    property string barFont: ""

    // module UI is injected here
    default property alias content: contentItem.data

    // ENGINE controls geometry, not modules
    implicitWidth: isHorizontal
        ? contentItem.implicitWidth
        : barThickness

    implicitHeight: isHorizontal
        ? barThickness
        : contentItem.implicitHeight

    Item {
        id: contentItem
        anchors.centerIn: parent
    }
}