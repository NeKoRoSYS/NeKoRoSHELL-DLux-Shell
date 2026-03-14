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

    readonly property bool hasContent: isHorizontal ? (pillRow.implicitWidth > 0.01) : (pillCol.implicitHeight > 0.01)

    property real currentPadding: hasContent ? Style.pillPadding : 0
    Behavior on currentPadding { NumberAnimation { duration: Animations.normal; easing.type: Animations.easeOut } }

    implicitWidth:  isHorizontal ? (pillRow.implicitWidth + currentPadding)  : (hasContent ? moduleSize : 0)
    implicitHeight: isHorizontal ? (hasContent ? moduleSize : 0) : (pillCol.implicitHeight + currentPadding)
    
    Behavior on implicitWidth  { enabled: !isHorizontal; NumberAnimation { duration: Animations.normal; easing.type: Animations.easeOut } }
    Behavior on implicitHeight { enabled: isHorizontal;  NumberAnimation { duration: Animations.normal; easing.type: Animations.easeOut } }

    Rectangle {
        anchors.fill: parent
        radius:       Math.min(width, height) / 2
        color:        Colors.color3
        opacity:      root.hasContent ? Style.pillOpacity : 0
        Behavior on opacity { NumberAnimation { duration: Animations.normal; easing.type: Animations.easeOut } }
    }

    component PillDelegate: Item {
        required property string modelData
        
        readonly property bool moduleActive: mod.item ? ("isActive" in mod.item ? mod.item.isActive : true) : true
        
        implicitWidth:  moduleActive ? mod.implicitWidth  : 0
        implicitHeight: moduleActive ? mod.implicitHeight : 0
        width: implicitWidth
        height: implicitHeight
        opacity: moduleActive ? 1 : 0

        Behavior on implicitWidth  { NumberAnimation { duration: Animations.normal; easing.type: Animations.easeOut } }
        Behavior on implicitHeight { NumberAnimation { duration: Animations.normal; easing.type: Animations.easeOut } }
        Behavior on opacity        { NumberAnimation { duration: Animations.normal; easing.type: Animations.easeOut } }

        visible: opacity > 0 || (root.isHorizontal ? implicitWidth > 0 : implicitHeight > 0)
        clip: true

        Loader {
            id: mod
            sourceComponent: ModuleRegistry.resolve(parent.modelData)
            
            Binding { when: mod.status === Loader.Ready; target: mod.item; property: "isHorizontal"; value: root.isHorizontal }
            Binding { when: mod.status === Loader.Ready; target: mod.item; property: "barThickness"; value: root.moduleSize }
            Binding { when: mod.status === Loader.Ready && mod.item !== null && ("inPill" in mod.item); target: mod.item; property: "inPill"; value: true }
            Binding { when: mod.status === Loader.Ready && mod.item !== null && ("barScreen" in mod.item); target: mod.item; property: "barScreen"; value: root.barScreen }
        }
    }

    Row {
        id: pillRow
        visible:          root.isHorizontal
        anchors.centerIn: parent
        spacing:          Style.pillSpacing
        Repeater { model: root.isHorizontal ? root.modules : []; delegate: PillDelegate {} }
    }

    Column {
        id: pillCol
        visible:          !root.isHorizontal
        anchors.centerIn: parent
        spacing:          Style.pillSpacing
        Repeater { model: root.isHorizontal ? [] : root.modules; delegate: PillDelegate {} }
    }
}