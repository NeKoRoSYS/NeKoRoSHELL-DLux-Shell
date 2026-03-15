// components/ModuleLoader.qml
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
        active: backendLoader.status === Loader.Ready && backendLoader.item.moduleType !== "dynamic"
        source: active ? `../modules/${moduleName}/${moduleName}View.qml` : ""

        onLoaded: {
            item.backend = backendLoader.item
            item.isHorizontal = root.isHorizontal
        }
    }

    Loader {
        id: dynamicLoader
        anchors.fill: parent
        active: backendLoader.status === Loader.Ready && backendLoader.item.moduleType === "dynamic"
        sourceComponent: Component {
            DynamicChip {
                isHorizontal: root.isHorizontal
                items: backendLoader.item.items
            }
        }
    }
}