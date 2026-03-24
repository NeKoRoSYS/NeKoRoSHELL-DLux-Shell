// components/ModuleLoader.qml
import Quickshell
import QtQuick
import qs.global

Item {
    id: root

    property string moduleName: ""
    property bool isHorizontal: true
    property real barThickness: 0

    readonly property bool isCustom: moduleName !== "" && moduleName.startsWith("custom:")
    readonly property string parsedName: isCustom ? moduleName.substring(7) : moduleName

    implicitWidth: viewLoader.active ? viewLoader.width : (dynamicLoader.active ? dynamicLoader.width : 0)
    implicitHeight: viewLoader.active ? viewLoader.height : (dynamicLoader.active ? dynamicLoader.height : 0)

    Loader {
        id: backendLoader
        active: root.parsedName !== ""
        source: active 
            ? (root.isCustom 
                ? "file://" + Quickshell.env("HOME") + "/.config/quickshell/user/modules/" + root.parsedName + "/" + root.parsedName + ".qml"
                : "../modules/" + root.parsedName + "/" + root.parsedName + ".qml")
            : ""
    }

    Loader {
        id: viewLoader
        active: backendLoader.status === Loader.Ready && backendLoader.item.moduleType !== "dynamic"
        
        source: active ? (
            root.isCustom 
                ? "file://" + Quickshell.env("HOME") + "/.config/quickshell/user/modules/" + root.parsedName + "/" + root.parsedName + "View.qml"
                : "../modules/" + root.parsedName + "/" + root.parsedName + "View.qml"
        ) : ""

        onLoaded: {
            item.backend = backendLoader.item
            item.isHorizontal = root.isHorizontal
        }
    }

    Loader {
        id: dynamicLoader
        active: backendLoader.status === Loader.Ready && backendLoader.item.moduleType === "dynamic"
        sourceComponent: Component {
            DynamicChip {
                isHorizontal: root.isHorizontal
                items: backendLoader.item.items
            }
        }
    }
}