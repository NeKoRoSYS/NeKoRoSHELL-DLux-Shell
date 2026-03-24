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
    
    Behavior on currentPadding { NumberAnimation { duration: Animations.normal; easing.type: Easing.OutQuad } }

    implicitWidth:  isHorizontal ? (pillRow.implicitWidth + currentPadding)  : (hasContent ? moduleSize : 0)
    implicitHeight: isHorizontal ? (hasContent ? moduleSize : 0) : (pillCol.implicitHeight + currentPadding)
    
    Behavior on implicitWidth  { enabled: !isHorizontal; NumberAnimation { duration: Animations.normal; easing.type: Easing.OutQuad } }
    Behavior on implicitHeight { enabled: isHorizontal; NumberAnimation { duration: Animations.normal; easing.type: Easing.OutQuad } }

    Rectangle {
        anchors.fill: parent
        radius:       Style.pillRadius
        color:        Colors.color0
        opacity:      root.hasContent ? Style.pillOpacity : 0
        Behavior on opacity { NumberAnimation { duration: Animations.normal; easing.type: Easing.OutQuad } }
    }

    component PillDelegate: Item {
        required property string modelData
        
        readonly property bool moduleActive: mod.item ? ("isActive" in mod.item ? mod.item.isActive : true) : true
        
        implicitWidth:  moduleActive ? mod.implicitWidth  : 0
        implicitHeight: moduleActive ? mod.implicitHeight : 0
        width: implicitWidth; height: implicitHeight

        opacity: moduleActive ? 1 : 0
        scale:   moduleActive ? 1 : 0.01

        Behavior on implicitWidth  { NumberAnimation { duration: Animations.normal; easing.type: Easing.OutQuad } }
        Behavior on implicitHeight { NumberAnimation { duration: Animations.normal; easing.type: Easing.OutQuad } }
        Behavior on opacity        { NumberAnimation { duration: Animations.normal; easing.type: Easing.OutQuad } }
        Behavior on scale          { NumberAnimation { duration: Animations.normal; easing.type: Easing.OutBack } }

        visible: opacity > 0 || (root.isHorizontal ? implicitWidth > 0 : implicitHeight > 0)
        clip: true

        Loader {
            id: mod
            anchors.centerIn: parent
            sourceComponent: ModuleRegistry.resolve(parent.modelData)

            onLoaded: {
                item.isHorizontal = root.isHorizontal;
                item.barThickness = root.moduleSize;
                if ("inPill" in item) item.inPill = true;
                if ("barScreen" in item) item.barScreen = root.barScreen;
            }
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