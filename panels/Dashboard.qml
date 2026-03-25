// panels/Dashboard.qml
import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Mpris
import Quickshell.Services.Notifications
import qs.components
import qs.engine
import qs.global
import qs.modules.media
import qs.modules.music
import qs.modules.notifications

Panel {
    id: dashboardPanel

    edgePadding: 15
    panelWidth:      Style.panelWidth + 455
    panelHeight:     Math.max(Style.panelHeight, 500)
    animationPreset: "slide"

    property var engine: DashboardEngine {}

    property int maxPanelHeight: 700
    property int notifCount: NotificationsEngine.trackedNotifications.values.length
    property int trackedContentHeight: 58

    onShowPanelChanged: {
        if (showPanel) {
            NotificationsEngine.activePopups.clear();
        }
    }

    Rectangle {
        id: dashRoot
        anchors.fill: parent
        color: "transparent"
        border.color: Colors.color13
        border.width: 2
        radius: 10
        clip: true

        property var expandedStates: ({})

        function toggleGroup(app) {
            let states = expandedStates;
            states[app] = !states[app];
            expandedStates = Object.assign({}, states);
        }

        property var groupedNotifications: {
            let vals = NotificationsEngine.trackedNotifications.values || [];
            let map = {};
            let arr = [];
            
            for (let i = vals.length - 1; i >= 0; i--) {
                let n = vals[i];
                if (!n) continue;
                
                let app = n.appName || "Notification";
                if (!map[app]) {
                    map[app] = { appName: app, notifs: [] };
                    arr.push(map[app]);
                }
                map[app].notifs.push(n);
            }
            return arr;
        }

        function clearAllNotifications() {
            let vals = NotificationsEngine.trackedNotifications.values;
            for (let i = vals.length - 1; i >= 0; i--) {
                if (vals[i]) vals[i].dismiss();
            }
        }

        Row {
            anchors.fill: parent

            Item {
                width: Style.panelWidth
                height: parent.height

                ScrollView {
                    id: scroll
                    anchors.fill: parent
                    anchors.margins: dashboardPanel.edgePadding
                    clip: true
                    
                    ScrollBar.vertical: ScrollBar {
                        policy: ScrollBar.AsNeeded
                        contentItem: Rectangle { implicitWidth: 4; radius: 2; color: Colors.color7; opacity: 0.4 }
                    }
                    ScrollBar.horizontal: ScrollBar { policy: ScrollBar.AlwaysOff }
                    
                    contentWidth: width
                    contentHeight: mainCol.height

                    Column {
                        id: mainCol
                        width:      scroll.width
                        spacing:    14
                        topPadding: 0
                        
                        Item {
                            width:  parent.width
                            height: 30

                            Text {
                                anchors.left:           parent.left
                                anchors.verticalCenter: parent.verticalCenter
                                text:           Time.date
                                color:          Colors.foreground
                                font.family:    Style.barFont
                                font.pixelSize: 18
                                font.weight:    Font.ExtraBold
                            }

                            Rectangle {
                                anchors.right:          parent.right
                                anchors.verticalCenter: parent.verticalCenter
                                width: 70; height: 28; radius: 14
                                color: engine.editMode ? Colors.color7 : Qt.alpha(Colors.color0, 0.4)
                                Behavior on color { ColorAnimation { duration: 150 } }
                                Text {
                                    anchors.centerIn: parent
                                    text:        engine.editMode ? "Done" : "Edit"
                                    color:       engine.editMode ? Colors.background : Colors.foreground
                                    font.family: Style.barFont; font.pixelSize: 12; font.weight: Font.Bold
                                    Behavior on color { ColorAnimation { duration: 150 } }
                                }
                                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: engine.editMode = !engine.editMode }
                            }
                        }

                        Rectangle { width: parent.width; height: 1; color: Colors.color8; opacity: 0.3 }

                        // ── Control center grid ───────────────────────────────────────
                        Item {
                            width:  parent.width
                            height: gridLayout.height + (engine.editMode ? addSheet.height + 10 : 0)
                            Behavior on height { NumberAnimation { duration: Animations.normal; easing.type: Animations.easeInOut } }

                            Item {
                                id: gridLayout
                                width: parent.width
                                readonly property real cellW: Math.floor((width - (engine.cellGap * 3)) / 4)
                                readonly property real cellH: cellW
                                height: engine.gridHeight
                                onCellWChanged: engine.cellW = cellW

                                Repeater {
                                    model: engine.placements

                                    delegate: Item {
                                        required property var modelData

                                        x:      modelData.col  * (gridLayout.cellW + engine.cellGap)
                                        y:      modelData.row  * (gridLayout.cellH + engine.cellGap)
                                        width:  modelData.cols * gridLayout.cellW + (modelData.cols - 1) * engine.cellGap
                                        height: modelData.rows * gridLayout.cellH + (modelData.rows - 1) * engine.cellGap

                                        Rectangle {
                                            id:            widgetCard
                                            anchors.fill:  parent
                                            radius:        12
                                            color:         Qt.alpha(Colors.color0, 0.4)
                                            clip:          true
                                            layer.enabled: true

                                            readonly property bool isCustom: modelData.id.startsWith("custom:")
                                            readonly property string parsedName: isCustom ? modelData.id.split(":")[1] : modelData.id

                                            Loader {
                                                anchors.fill:    parent
                                                source: widgetCard.isCustom 
                                                    ? `file://${Config.userModulesPath}${widgetCard.parsedName}/${widgetCard.parsedName}Widget.qml`
                                                    : ""
                                                sourceComponent: !widgetCard.isCustom 
                                                    ? ModuleRegistry.resolveWidget(modelData.id) 
                                                    : undefined
                                            }

                                            MouseArea { anchors.fill: parent; enabled: engine.editMode; hoverEnabled: false }
                                            Rectangle {
                                                anchors.fill: parent; radius: parent.radius; color: "transparent"
                                                border.width: engine.editMode ? 2 : 0; border.color: Colors.color7
                                                opacity: engine.editMode ? 1 : 0
                                                Behavior on opacity      { NumberAnimation { duration: 150 } }
                                                Behavior on border.width { NumberAnimation { duration: 150 } }
                                            }
                                            Rectangle {
                                                visible: engine.editMode; opacity: engine.editMode ? 1 : 0
                                                Behavior on opacity { NumberAnimation { duration: 150 } }
                                                anchors.top:     parent.top
                                                anchors.right:   parent.right
                                                anchors.margins: -6
                                                width: 20; height: 20; radius: 10; color: Colors.color1
                                                Text { anchors.centerIn: parent; text: "󰅖"; color: Colors.foreground; font.family: Style.barFont; font.pixelSize: 11 }
                                                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: engine.removeWidget(modelData.id) }
                                            }
                                            Row {
                                                visible: engine.editMode && engine.placements.length > 1
                                                opacity: engine.editMode ? 1 : 0
                                                Behavior on opacity { NumberAnimation { duration: 150 } }
                                                anchors.bottom:         parent.bottom
                                                anchors.horizontalCenter:    parent.horizontalCenter
                                                anchors.bottomMargin:        4
                                                spacing: 4
                                                Rectangle {
                                                    visible: modelData.idx > 0
                                                    width: 20; height: 20; radius: 10; color: Colors.color8; opacity: 0.7
                                                    Text { anchors.centerIn: parent; text: "󰁍"; color: Colors.foreground; font.family: Style.barFont; font.pixelSize: 11 }
                                                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: engine.moveWidget(modelData.idx, modelData.idx - 1) }
                                                }
                                                Rectangle {
                                                    visible: modelData.idx < engine.activeWidgets.length - 1
                                                    width: 20; height: 20; radius: 10; color: Colors.color8; opacity: 0.7
                                                    Text { anchors.centerIn: parent; text: "󰁔"; color: Colors.foreground; font.family: Style.barFont; font.pixelSize: 11 }
                                                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: engine.moveWidget(modelData.idx, modelData.idx + 1) }
                                                }
                                            }
                                        }
                                    }
                                }
                            }

                            Rectangle {
                                id:      addSheet
                                visible: engine.editMode
                                opacity: engine.editMode ? 1 : 0
                                Behavior on opacity { NumberAnimation { duration: 200 } }
                                anchors.top:        gridLayout.bottom
                                anchors.topMargin:  10
                                anchors.left:       parent.left
                                anchors.right:      parent.right
                                height: addGrid.height + 20; radius: 12; color: Colors.color0

                                Column {
                                    id: addGrid
                                    anchors.left:    parent.left
                                    anchors.right:   parent.right
                                    anchors.top:     parent.top
                                    anchors.margins: 12
                                    spacing: 8

                                    Text { text: "Add Widget"; color: Colors.color8; font.family: Style.barFont; font.pixelSize: 11; font.weight: Font.ExtraBold; font.letterSpacing: 1.2 }

                                    Flow {
                                        width: parent.width; spacing: 6
                                        Repeater {
                                            model: engine.widgetDefs
                                            delegate: Rectangle {
                                                required property var modelData
                                                readonly property bool alreadyAdded: engine.activeWidgets.indexOf(modelData.id) !== -1
                                                width: 80; height: 32; radius: 16
                                                color:   alreadyAdded ? Colors.color8 : Colors.color7
                                                opacity: alreadyAdded ? 0.4 : 1.0
                                                Behavior on opacity { NumberAnimation { duration: 150 } }
                                                Behavior on color   { ColorAnimation  { duration: 150 } }
                                                Row {
                                                    anchors.centerIn: parent; spacing: 4
                                                    Text { text: parent.parent.modelData.icon; color: alreadyAdded ? Colors.foreground : Colors.background; font.family: Style.barFont; font.pixelSize: 12 }
                                                    Text { text: parent.parent.modelData.label; color: alreadyAdded ? Colors.foreground : Colors.background; font.family: Style.barFont; font.pixelSize: 11; font.weight: Font.Bold }
                                                }
                                                MouseArea {
                                                    anchors.fill: parent
                                                    cursorShape:  alreadyAdded ? Qt.ArrowCursor : Qt.PointingHandCursor
                                                    enabled:      !alreadyAdded
                                                    onClicked:    engine.addWidget(modelData.id)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        Rectangle { width: parent.width; height: 1; color: Colors.color8; opacity: 0.3 }
                    }
                }
            }

            Rectangle {
                width: 2
                height: parent.height - 30
                anchors.verticalCenter: parent.verticalCenter
                color: Colors.color8
                opacity: 0.3
            }

            Item {
                id: notificationsArea
                width: 420
                height: parent.height

                Column {
                    anchors.fill: parent
                    anchors.margins: 15
                    spacing: 15

                    Item {
                        width: parent.width
                        height: 30

                        Text {
                            text: "  Notifications"
                            color: Colors.foreground
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 18
                            font.weight: Font.ExtraBold
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Row {
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 15

                            Toggle {
                                labelText: "DND"
                                toggleStyle: "checkbox"
                                checked: Config.dndEnabled
                                onToggled: (state) => Config.saveSetting("dndEnabled", state)
                                width: 70 
                            }

                            Button {
                                labelText: ""
                                labelFont: "JetBrainsMono Nerd Font"
                                buttonColor: Colors.color1
                                width: height
                                height: 30
                                onButtonClicked: dashRoot.clearAllNotifications()
                            }
                        }
                    }

                    Rectangle { width: parent.width; height: 1; color: Colors.color8; opacity: 0.3 }

                    Flickable {
                        width: parent.width
                        height: parent.height - 62 
                        contentHeight: notifCol.childrenRect.height 
                        clip: true
                        interactive: contentHeight > height

                        Column {
                            id: notifCol
                            width: parent.width
                            spacing: 15
                            
                            property int realHeight: childrenRect.height
                            
                            onRealHeightChanged: {
                                if (realHeight > 50) { 
                                    dashboardPanel.trackedContentHeight = realHeight;
                                }
                            }

                            move: Transition {
                                NumberAnimation { properties: "y"; duration: 250; easing.type: Easing.OutCubic }
                            }
                            add: Transition {
                                NumberAnimation { properties: "y"; duration: 250; easing.type: Easing.OutCubic }
                            }

                            Music { }

                            Repeater {
                                id: rep
                                model: dashRoot.groupedNotifications
                                
                                delegate: Item {
                                    id: groupRoot
                                    width: notifCol.width
                                    
                                    property var groupData: modelData
                                    property var notifs: groupData.notifs
                                    property bool expanded: dashRoot.expandedStates[groupData.appName] || false
                                    property int maxStacked: 3
                                    
                                    height: headerWrapper.height + cardsContainer.height
                                    Behavior on height { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }

                                    x: 0
                                    Behavior on x { 
                                        enabled: !groupDrag.active
                                        NumberAnimation { duration: 200; easing.type: Easing.OutCubic } 
                                    }

                                    DragHandler {
                                        id: groupDrag
                                        target: groupRoot
                                        xAxis.enabled: true
                                        yAxis.enabled: false
                                        
                                        onActiveChanged: {
                                            if (!active) {
                                                if (Math.abs(groupRoot.x) > groupRoot.width / 3) {
                                                    groupRoot.x = groupRoot.x > 0 ? groupRoot.width : -groupRoot.width;
                                                    groupDismissTimer.start();
                                                } else {
                                                    groupRoot.x = 0;
                                                }
                                            }
                                        }
                                    }

                                    Timer {
                                        id: groupDismissTimer
                                        interval: 200
                                        onTriggered: {
                                            let notifsToDismiss = groupRoot.notifs.slice();
                                            for (let i = notifsToDismiss.length - 1; i >= 0; i--) {
                                                if (notifsToDismiss[i]) notifsToDismiss[i].dismiss();
                                            }
                                        }
                                    }

                                    Item {
                                        id: headerWrapper
                                        width: parent.width
                                        height: 30

                                        Item {
                                            id: header
                                            width: parent.width
                                            height: 30
                                            
                                            Text {
                                                anchors.bottom: parent.bottom
                                                anchors.bottomMargin: 5
                                                text: groupData.appName + (notifs.length > 1 ? " (" + notifs.length + ")" : "")
                                                color: Colors.color5
                                                font.family: "JetBrains Mono"
                                                font.weight: Font.Bold
                                                font.pixelSize: 13
                                                font.capitalization: Font.AllUppercase
                                            }
                                            
                                            Rectangle {
                                                anchors.right: parent.right
                                                anchors.verticalCenter: parent.verticalCenter
                                                width: 24
                                                height: 24
                                                radius: 12
                                                color: Qt.alpha(Colors.color1, 0.2)
                                                visible: notifs.length > 1
                                                
                                                Text {
                                                    anchors.centerIn: parent
                                                    text: groupRoot.expanded ? "" : "" 
                                                    font.family: "JetBrainsMono Nerd Font"
                                                    color: Colors.color5
                                                    font.pixelSize: 12
                                                }
                                            }
                                            
                                            MouseArea {
                                                anchors.fill: parent
                                                onClicked: if (notifs.length > 1) dashRoot.toggleGroup(groupData.appName)
                                            }
                                        }
                                    }

                                    Item {
                                        id: cardsContainer
                                        width: parent.width
                                        anchors.top: headerWrapper.bottom
                                        
                                        property var lastItem: cardsRep.count > 0 ? cardsRep.itemAt(cardsRep.count - 1) : null
                                        property int expandedHeight: lastItem ? (lastItem.expandedY + lastItem.height) : 0
                                        
                                        property var firstItem: cardsRep.count > 0 ? cardsRep.itemAt(0) : null
                                        property int collapsedHeight: firstItem ? (firstItem.height + (Math.min(cardsRep.count - 1, groupRoot.maxStacked - 1) * 12)) : 0
                                        
                                        height: groupRoot.expanded ? expandedHeight : collapsedHeight

                                        MouseArea {
                                            anchors.fill: parent
                                            acceptedButtons: Qt.LeftButton
                                            visible: !groupRoot.expanded && groupRoot.notifs.length > 1
                                            z: 999
                                            onClicked: dashRoot.toggleGroup(groupData.appName)
                                        }

                                        Repeater {
                                            id: cardsRep
                                            model: groupRoot.notifs
                                            
                                            delegate: NotificationCard {
                                                id: cardItem
                                                notification: modelData
                                                width: parent.width
                                                
                                                z: 100 - index 
                                                
                                                swipeEnabled: groupRoot.expanded || groupRoot.notifs.length === 1
                                                
                                                contentOpacity: (groupRoot.expanded || index === 0) ? 1.0 : 0.0
                                                
                                                property var prevItem: index > 0 ? cardsRep.itemAt(index - 1) : null
                                                property int expandedY: prevItem ? (prevItem.expandedY + prevItem.height + 15) : 0 
                                                
                                                y: groupRoot.expanded ? expandedY : (index < groupRoot.maxStacked ? index * 12 : 0)
                                                scale: groupRoot.expanded ? 1 : Math.max(0.85, 1 - (index * 0.05))
                                                transformOrigin: Item.Top
                                                opacity: groupRoot.expanded ? 1 : (index === 0 ? 1 : (index < groupRoot.maxStacked ? 1 - (index * 0.25) : 0))
                                                visible: opacity > 0
                                                
                                                Behavior on y { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
                                                Behavior on scale { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
                                                Behavior on opacity { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
                Text {
                    anchors.centerIn: parent
                    anchors.verticalCenterOffset: 30 
                    text: "No new notifications\nYou're all caught up!"
                    color: Colors.color8
                    font.family: "JetBrains Mono"
                    font.pixelSize: 14
                    horizontalAlignment: Text.AlignHCenter
                    visible: dashboardPanel.notifCount === 0
                }
            }
        }
    }
}