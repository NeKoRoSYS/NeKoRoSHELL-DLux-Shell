// engine/LayoutLoader.qml
pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import QtQuick
import qs.globals

Scope {
    id: root

    readonly property real   barSize: 40
    readonly property string barFont: "JetBrainsMono Nerd Font"

    property var layoutLeft:   []
    property var layoutCenter: []
    property var layoutRight:  []

    FileView {
        path: Qt.resolvedUrl("../layouts/" + Config.activeLayout + ".json")
        adapter: JsonAdapter {
            property var left:   []
            property var center: []
            property var right:  []
            onLeftChanged:   root.layoutLeft   = left   || []
            onCenterChanged: root.layoutCenter = center || []
            onRightChanged:  root.layoutRight  = right  || []
        }
    }

    // ── SHARED COMPONENTS & TRANSITIONS ──────────────────────────────
    Component {
        id: moduleDelegate
        Loader {
            id: modLoader
            required property string modelData
            sourceComponent: ModuleRegistry.resolve(modelData)
            
            Binding { when: modLoader.status === Loader.Ready; target: modLoader.item; property: "isHorizontal"; value: Config.isHorizontal }
            Binding { when: modLoader.status === Loader.Ready; target: modLoader.item; property: "barThickness"; value: root.barSize }
            Binding { when: modLoader.status === Loader.Ready; target: modLoader.item; property: "barFont";      value: root.barFont }
        }
    }

    Transition {
        id: animPopulateMove
        ParallelAnimation {
            NumberAnimation { properties: "x,y"; duration: Animations.normal; easing.type: Animations.easeOut }
            NumberAnimation { property: "opacity"; to: 1.0; duration: Animations.normal; easing.type: Animations.easeOut }
            NumberAnimation { property: "scale"; to: 1.0; duration: Animations.normal; easing.type: Animations.easeOut }
        }
    }

    Transition {
        id: animAdd
        ParallelAnimation {
            NumberAnimation { property: "opacity"; from: 0.0; to: 1.0; duration: Animations.normal }
            NumberAnimation { property: "scale"; from: 0.8; to: 1.0; duration: Animations.normal; easing.type: Animations.easeOut }
        }
    }
    // ─────────────────────────────────────────────────────────────────

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: bar
            required property var modelData

            screen: modelData
            color:  Colors.background
            exclusionMode: ExclusionMode.Auto

            anchors {
                top:    Config.navbarLocation !== "bottom"
                bottom: Config.navbarLocation !== "top"
                left:   Config.navbarLocation !== "right"
                right:  Config.navbarLocation !== "left"
            }

            implicitHeight: Config.isHorizontal ? root.barSize : 0
            implicitWidth:  Config.isHorizontal ? 0            : root.barSize

            // ── HORIZONTAL ────────────────────────────────────────────────
            Row {
                visible: Config.isHorizontal; spacing: 8
                anchors { left: parent.left; leftMargin: 12; verticalCenter: parent.verticalCenter }
                populate: animPopulateMove; add: animAdd
                Repeater { model: Config.isHorizontal ? root.layoutLeft : []; delegate: moduleDelegate }
            }

            Row {
                visible: Config.isHorizontal; spacing: 8
                anchors.centerIn: parent
                populate: animPopulateMove; add: animAdd
                Repeater { model: Config.isHorizontal ? root.layoutCenter : []; delegate: moduleDelegate }
            }

            Row {
                visible: Config.isHorizontal; spacing: 8
                anchors { right: parent.right; rightMargin: 12; verticalCenter: parent.verticalCenter }
                populate: animPopulateMove; add: animAdd
                Repeater { model: Config.isHorizontal ? root.layoutRight : []; delegate: moduleDelegate }
            }

            // ── VERTICAL ──────────────────────────────────────────────────
            Column {
                visible: !Config.isHorizontal; spacing: 8
                anchors { top: parent.top; topMargin: 12; horizontalCenter: parent.horizontalCenter }
                populate: animPopulateMove; add: animAdd
                Repeater { model: !Config.isHorizontal ? root.layoutLeft : []; delegate: moduleDelegate }
            }

            Column {
                visible: !Config.isHorizontal; spacing: 8
                anchors.centerIn: parent
                populate: animPopulateMove; add: animAdd
                Repeater { model: !Config.isHorizontal ? root.layoutCenter : []; delegate: moduleDelegate }
            }

            Column {
                visible: !Config.isHorizontal; spacing: 8
                anchors { bottom: parent.bottom; bottomMargin: 12; horizontalCenter: parent.horizontalCenter }
                populate: animPopulateMove; add: animAdd
                Repeater { model: !Config.isHorizontal ? root.layoutRight : []; delegate: moduleDelegate }
            }
        }
    }
}