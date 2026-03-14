// engine/SlotLayout.qml
pragma ComponentBehavior: Bound
import QtQuick
import qs.global

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
        Row { spacing: Style.slotSpacing; Repeater { model: root.modules; delegate: slotDelegate } }
    }
    
    Component {
        id: colComp
        Column { spacing: Style.slotSpacing; Repeater { model: root.modules; delegate: slotDelegate } }
    }

    component SlotEntry: Item {
        required property var modelData
        readonly property bool isGroup: typeof modelData !== "string"
        
        readonly property bool itemActive: mod.item ? ("isActive" in mod.item ? mod.item.isActive : true) : true
        readonly property bool isActive: isGroup ? pill.hasContent : (mod.status === Loader.Ready ? itemActive : true)
        
        readonly property real targetWidth:  isGroup ? pill.implicitWidth  : mod.implicitWidth
        readonly property real targetHeight: isGroup ? pill.implicitHeight : mod.implicitHeight

        implicitWidth:  isActive ? targetWidth  : 0
        implicitHeight: isActive ? targetHeight : 0
        width: implicitWidth
        height: implicitHeight
        opacity: isActive ? 1 : 0

        Behavior on implicitWidth  { enabled: !isGroup; NumberAnimation { duration: Animations.normal; easing.type: Animations.easeOut } }
        Behavior on implicitHeight { enabled: !isGroup; NumberAnimation { duration: Animations.normal; easing.type: Animations.easeOut } }
        Behavior on opacity        { NumberAnimation { duration: Animations.normal; easing.type: Animations.easeOut } }

        visible: opacity > 0 || (root.isHorizontal ? implicitWidth > 0 : implicitHeight > 0)
        clip: true

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