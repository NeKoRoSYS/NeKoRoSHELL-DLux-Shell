import QtQuick
import QtQuick.Layouts

Item {
    id: root

    property bool isHorizontal: true
    default property alias modules: layout.data

    implicitWidth: layout.implicitWidth
    implicitHeight: layout.implicitHeight

    Loader {
        anchors.fill: parent
        sourceComponent: isHorizontal ? rowLayout : columnLayout
    }

    Component {
        id: rowLayout

        Row {
            id: layout
            anchors.centerIn: parent
            spacing: 6
        }
    }

    Component {
        id: columnLayout

        Column {
            id: layout
            anchors.centerIn: parent
            spacing: 6
        }
    }
}