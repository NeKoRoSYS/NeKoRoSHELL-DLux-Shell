// components/ModuleLoader.qml
import Quickshell
import QtQuick
import qs.global

Item {
    id: root

    property string moduleName: ""
    property bool isHorizontal: true
    property real barThickness: 0
    property var barScreen: null 

    readonly property bool isCustom: moduleName !== "" && moduleName.startsWith("custom:")
    readonly property string parsedName: isCustom ? moduleName.substring(7) : moduleName

    implicitWidth: viewLoader.active && viewLoader.item ? viewLoader.item.implicitWidth : (dynamicLoader.active && dynamicLoader.item ? dynamicLoader.item.implicitWidth : 0)
    implicitHeight: viewLoader.active && viewLoader.item ? viewLoader.item.implicitHeight : (dynamicLoader.active && dynamicLoader.item ? dynamicLoader.item.implicitHeight : 0)

    width: implicitWidth
    height: implicitHeight

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
            if (item.hasOwnProperty("backend")) item.backend = backendLoader.item
        }

        Binding { 
            target: viewLoader.item
            property: "isHorizontal"
            value: root.isHorizontal
            when: viewLoader.status === Loader.Ready && viewLoader.item !== null && viewLoader.item.hasOwnProperty("isHorizontal") 
        }
        Binding { 
            target: viewLoader.item
            property: "barThickness"
            value: root.barThickness
            when: viewLoader.status === Loader.Ready && viewLoader.item !== null && viewLoader.item.hasOwnProperty("barThickness") 
        }
        Binding { 
            target: viewLoader.item
            property: "barScreen"
            value: root.barScreen
            when: viewLoader.status === Loader.Ready && viewLoader.item !== null && viewLoader.item.hasOwnProperty("barScreen") 
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