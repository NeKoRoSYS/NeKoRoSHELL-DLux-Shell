// modules/workspaces/WorkspacesView.qml
import QtQuick
import qs.global
import qs.components

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
        
        color: Colors.background
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
                
                width:  !root.isHorizontal ? root.baseSize : Math.max(0, layout.implicitWidth - root.baseSize)
                height: !root.isHorizontal ? Math.max(0, layout.implicitHeight - root.baseSize) : root.baseSize
                
                color: Config.transparentNavbar ? Colors.background : Colors.color3
                radius: 1.5
            }

            Flow {
                id: layout
                anchors.centerIn: parent
                flow:    root.isHorizontal ? Flow.LeftToRight : Flow.TopToBottom
                spacing: 6

                move: Transition { NumberAnimation { properties: "x,y"; duration: Animations.normal; easing.type: Animations.easeOut } }

                property bool ready: false
                Component.onCompleted: ready = true

                WorkspaceDot {
                    baseSize: root.baseSize
                    barFont: root.barFont
                    
                    showDot: layout.ready && appRepeater.count === 0
                    isFocused: wsDelegate.modelData.focused
                    dotText: isFocused ? "󰣇" : wsDelegate.modelData.name
                    labelFont.pixelSize: root.baseSize / 2
                    labelFont.weight: Font.ExtraBold
                    textOffsetX: 1
                    area.onClicked: Workspaces.activate(wsDelegate.modelData)
                }

                Repeater {
                    id: appRepeater
                    model: wsDelegate.modelData.toplevels
                    delegate: WorkspaceDot {
                        baseSize: root.baseSize
                        barFont: root.barFont
                        
                        showDot: layout.ready && index < root.maxIcons
                        isFocused: modelData.activated && wsDelegate.modelData.focused
                        dotText: Workspaces.iconFor(modelData)
                        labelFont.pixelSize: root.baseSize / 1.85
                        textOffsetX: 0.25
                        textOffsetY: 1
                        area.onClicked: Workspaces.focusWindow(modelData.address)
                    }
                }

                WorkspaceDot {
                    baseSize: root.baseSize
                    barFont: root.barFont
                    
                    showDot: layout.ready && appRepeater.count > root.maxIcons
                    dotText: "+" + (appRepeater.count - root.maxIcons)
                    labelFont.pixelSize: root.baseSize / 2
                    labelFont.weight: Font.ExtraBold
                    textOffsetX: -2
                    textOffsetY: 1
                    area.onClicked: Workspaces.activate(wsDelegate.modelData)
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