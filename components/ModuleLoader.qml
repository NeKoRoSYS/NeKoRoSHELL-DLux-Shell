import QtQuick

Item {
    id: root

    property string moduleName
    property bool isHorizontal: true

    Loader {
        id: backendLoader
        source: `../modules/${moduleName}/${moduleName}.qml`
    }

    Loader {
        id: viewLoader
        anchors.fill: parent
        source: `../modules/${moduleName}/${moduleName}View.qml`

        onLoaded: {
            item.backend = backendLoader.item
            item.isHorizontal = root.isHorizontal
        }
    }
}