// modules/workspaces/WorkspacesView.qml
import QtQuick
import qs.global
import qs.modules.workspaces

Item {
    id: root

    property bool   isHorizontal: Config.isHorizontal
    property real   barThickness: Style.moduleSize
    property string barFont:      Style.barFont

    readonly property int  maxIcons: 5
    readonly property real baseSize: barThickness

    implicitWidth:  isHorizontal ? (container.implicitWidth + 15) : barThickness
    implicitHeight: isHorizontal ? barThickness : (container.implicitHeight + 15)
    clip: false

    Rectangle {
        anchors.centerIn: parent
        width:  !root.isHorizontal ? root.baseSize : (container.implicitWidth + 15)
        height: !root.isHorizontal ? (container.implicitHeight + 15) : root.baseSize
        radius: (!root.isHorizontal ? width : height) / 2
        
        color: Colors.color3
        opacity: 0.325

        Behavior on width { NumberAnimation { duration: Animations.normal; easing.type: Animations.easeOut } }
        Behavior on height { NumberAnimation { duration: Animations.normal; easing.type: Animations.easeOut } }
    }

    ListView {
        id: container
        anchors.centerIn: parent
        
        orientation: root.isHorizontal ? ListView.Horizontal : ListView.Vertical
        spacing:     15

        model: Workspaces.workspaces
        interactive: false

        add: Transition { NumberAnimation { properties: "opacity,scale"; from: 0; to: 1; duration: Animations.normal; easing.type: Animations.easeOut } }
        remove: Transition { NumberAnimation { properties: "opacity,scale"; to: 0; duration: Animations.normal; easing.type: Animations.easeOut } }
        displaced: Transition { NumberAnimation { properties: "x,y"; duration: Animations.normal; easing.type: Animations.easeOut } }

        implicitWidth:  root.isHorizontal ? contentWidth  : root.baseSize
        implicitHeight: root.isHorizontal ? root.baseSize : contentHeight

        delegate: Item {
            id: wsDelegate
            required property var modelData
            required property int index

            width:  root.isHorizontal ? layout.implicitWidth : root.baseSize
            height: root.isHorizontal ? root.baseSize    : layout.implicitHeight

            Rectangle {
                anchors.centerIn: layout
                visible: appRepeater.count > 1
                
                width:  !root.isHorizontal ? root.baseSize : (layout.implicitWidth - root.baseSize)
                height: !root.isHorizontal ? (layout.implicitHeight - root.baseSize) : root.baseSize
                
                color: Colors.color3
                radius: 1.5
            }

            Flow {
                id: layout
                anchors.centerIn: parent
                flow:    root.isHorizontal ? Flow.LeftToRight : Flow.TopToBottom
                spacing: 6

                move: Transition { NumberAnimation { properties: "x,y"; duration: Animations.normal; easing.type: Animations.easeOut } }

                // ── Empty workspace dot ───────────────────────────────────────
                Item {
                    property bool ready: false
                    Component.onCompleted: ready = true
                    readonly property bool showEmpty: ready && appRepeater.count === 0

                    implicitWidth:  showEmpty ? root.baseSize : 0
                    implicitHeight: showEmpty ? root.baseSize : 0
                    width: implicitWidth
                    height: implicitHeight
                    opacity: showEmpty ? 1 : 0
                    scale:   showEmpty ? 1 : 0.01

                    Behavior on implicitWidth  { NumberAnimation { duration: Animations.normal; easing.type: Animations.easeOut } }
                    Behavior on implicitHeight { NumberAnimation { duration: Animations.normal; easing.type: Animations.easeOut } }
                    Behavior on opacity        { NumberAnimation { duration: Animations.normal; easing.type: Animations.easeOut } }
                    Behavior on scale          { NumberAnimation { duration: Animations.normal; easing.type: Animations.easeOut } }
                    visible: opacity > 0 || implicitWidth > 0

                    Rectangle {
                        anchors.centerIn: parent
                        height:  root.baseSize; width: height; radius: height / 2
                        color: wsMouseArea.containsMouse ? "white" : (wsDelegate.modelData.focused ? "white" : Colors.color3)
                        Behavior on color { ColorAnimation { duration: 150 } }

                        Text {
                            anchors.centerIn: parent
                            anchors.horizontalCenterOffset: 1
                            text: wsDelegate.modelData.focused ? "󰣇" : wsDelegate.modelData.name
                            color: wsMouseArea.containsMouse ? "black" : (wsDelegate.modelData.focused ? "black" : "white")
                            Behavior on color { ColorAnimation { duration: 150 } }
                            font.family: root.barFont
                            font.pixelSize: parent.height / 2
                            font.weight: Font.ExtraBold
                        }

                        MouseArea {
                            id: wsMouseArea
                            anchors.fill: parent
                            cursorShape:  Qt.PointingHandCursor
                            hoverEnabled: true
                            onClicked:    Workspaces.activate(wsDelegate.modelData)
                        }
                    }
                }

                // ── App dots ──────────────────────────────────────────────────
                Repeater {
                    id: appRepeater
                    model: wsDelegate.modelData.toplevels

                    delegate: Item {
                        id: appContainer
                        required property var modelData
                        required property int index
                        
                        readonly property bool isFocusedApp: modelData.activated && wsDelegate.modelData.focused
                        
                        property bool ready: false
                        Component.onCompleted: ready = true
                        readonly property bool showApp: ready && index < root.maxIcons

                        implicitWidth:  showApp ? root.baseSize : 0
                        implicitHeight: showApp ? root.baseSize : 0
                        width: implicitWidth
                        height: implicitHeight
                        opacity: showApp ? 1 : 0
                        scale:   showApp ? 1 : 0.01

                        Behavior on implicitWidth  { NumberAnimation { duration: Animations.normal; easing.type: Animations.easeOut } }
                        Behavior on implicitHeight { NumberAnimation { duration: Animations.normal; easing.type: Animations.easeOut } }
                        Behavior on opacity        { NumberAnimation { duration: Animations.normal; easing.type: Animations.easeOut } }
                        Behavior on scale          { NumberAnimation { duration: Animations.normal; easing.type: Animations.easeOut } }
                        visible: opacity > 0 || implicitWidth > 0

                        Rectangle {
                            anchors.centerIn: parent
                            height: root.baseSize; width: height; radius: height / 2
                            color: appMouseArea.containsMouse ? "white" : (isFocusedApp ? "white" : Colors.color3)
                            Behavior on color { ColorAnimation { duration: 150 } }

                            Text {
                                anchors.centerIn: parent
                                anchors.horizontalCenterOffset: 0.25; anchors.verticalCenterOffset: 1
                                text: Workspaces.iconFor(modelData)
                                color: appMouseArea.containsMouse ? "black" : (isFocusedApp ? Colors.color3 : "white")
                                Behavior on color { ColorAnimation { duration: 150 } }
                                font.family: root.barFont; font.pixelSize: parent.height / 1.85
                            }

                            MouseArea {
                                id: appMouseArea
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                hoverEnabled: true
                                onClicked: Workspaces.focusWindow(modelData.address)
                            }
                        }
                    }
                }

                // ── Overflow dot ───────────────────────────────────────────────
                Item {
                    property bool ready: false
                    Component.onCompleted: ready = true
                    readonly property bool showOverflow: ready && appRepeater.count > root.maxIcons

                    implicitWidth:  showOverflow ? root.baseSize : 0
                    implicitHeight: showOverflow ? root.baseSize : 0
                    width: implicitWidth
                    height: implicitHeight
                    opacity: showOverflow ? 1 : 0
                    scale:   showOverflow ? 1 : 0.01

                    Behavior on implicitWidth  { NumberAnimation { duration: Animations.normal; easing.type: Animations.easeOut } }
                    Behavior on implicitHeight { NumberAnimation { duration: Animations.normal; easing.type: Animations.easeOut } }
                    Behavior on opacity        { NumberAnimation { duration: Animations.normal; easing.type: Animations.easeOut } }
                    Behavior on scale          { NumberAnimation { duration: Animations.normal; easing.type: Animations.easeOut } }
                    visible: opacity > 0 || implicitWidth > 0

                    Rectangle {
                        anchors.centerIn: parent
                        height: root.baseSize; width: height; radius: height / 2
                        color: overflowMouseArea.containsMouse ? "white" : Colors.color3
                        Behavior on color { ColorAnimation { duration: 150 } }
                        
                        Text {
                            anchors.centerIn: parent
                            anchors.horizontalCenterOffset: -2; anchors.verticalCenterOffset: 1
                            text: "+" + (appRepeater.count - root.maxIcons)
                            color: overflowMouseArea.containsMouse ? "black" : "white"
                            Behavior on color { ColorAnimation { duration: 150 } }
                            font.family: root.barFont; font.pixelSize: parent.height / 2; font.weight: Font.ExtraBold
                        }
                        
                        MouseArea {
                            id: overflowMouseArea
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            hoverEnabled: true
                            onClicked: Workspaces.activate(wsDelegate.modelData)
                        }
                    }
                }
            }

            Rectangle {
                visible: wsDelegate.index < (container.count - 1)
                
                width:  !root.isHorizontal ? root.baseSize * 0.5 : 2
                height: !root.isHorizontal ? 2 : root.baseSize * 0.5
                radius: 1

                color: Colors.foreground
                opacity: 0.5

                x: !root.isHorizontal ? (layout.width - width) / 2 : layout.width + (15 - width) / 2
                y: !root.isHorizontal ? layout.height + (15 - height) / 2 : (layout.height - height) / 2
            }
        }
    }
}