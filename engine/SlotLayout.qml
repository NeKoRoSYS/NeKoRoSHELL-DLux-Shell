// engine/SlotLayout.qml
pragma ComponentBehavior: Bound
import QtQuick
import qs.globals

Item {
    id: root

    property bool   isHorizontal: Config.isHorizontal
    property real   moduleSize:   Style.moduleSize
    property string barFont:      "JetBrainsMono Nerd Font" 
    property var    modules:      []
    property var    barScreen:    null

    implicitWidth:  isHorizontal ? layout.implicitWidth   : Style.barSize
    implicitHeight: isHorizontal ? Style.barSize          : layout.implicitHeight

    Loader {
        id: layout
        anchors.centerIn: parent
        sourceComponent: root.isHorizontal ? rowComp : colComp
    }

    Component {
        id: rowComp
        Row { spacing: 8; Repeater { model: root.modules; delegate: slotDelegate } }
    }
    
    Component {
        id: colComp
        Column { spacing: 8; Repeater { model: root.modules; delegate: slotDelegate } }
    }

    component SlotEntry: Item {
        required property var modelData
        readonly property bool isGroup: typeof modelData !== "string"
        
        implicitWidth:  isGroup ? pill.implicitWidth  : mod.implicitWidth
        implicitHeight: isGroup ? pill.implicitHeight : mod.implicitHeight
        width: implicitWidth
        height: implicitHeight

        PillGroup {
            id: pill
            visible: isGroup
            isHorizontal: root.isHorizontal
            moduleSize:   root.moduleSize
            modules:      isGroup ? modelData : []
            barScreen:    root.barScreen
        }
        
        Loader {
            id: mod
            visible: !isGroup
            sourceComponent: !isGroup ? ModuleRegistry.resolve(modelData) : null
            
            Binding { when: mod.status === Loader.Ready; target: mod.item; property: "isHorizontal"; value: root.isHorizontal }
            Binding { when: mod.status === Loader.Ready; target: mod.item; property: "barThickness"; value: root.moduleSize }
            Binding { when: mod.status === Loader.Ready && mod.item !== null && ("barScreen" in mod.item); target: mod.item; property: "barScreen"; value: root.barScreen }
            Binding { when: mod.status === Loader.Ready && mod.item !== null && ("barFont" in mod.item); target: mod.item; property: "barFont"; value: root.barFont }
        }
    }

    property Component slotDelegate: SlotEntry {}
}