// panels/Notifications.qml
import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Notifications
import qs.global
import qs.engine
import qs.components

Panel {
    id: ncPanel

    property int maxPanelHeight: 700
    property int notifCount: NotificationsEngine.trackedNotifications.values.length
    
    property int trackedContentHeight: 58

    panelWidth:  420
    panelHeight: 600
    animationPreset: "slide"
    edgePadding: 15

    Behavior on panelHeight {
        NumberAnimation {
            duration: Animations.normal
            easing.type: Animations.easeOut
        }
    }

    onShowPanelChanged: {
        if (showPanel) {
            NotificationsEngine.activePopups.clear();
        }
    }

    Rectangle {
        id: ncRoot
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
                        onButtonClicked: ncRoot.clearAllNotifications()
                    }
                }
            }

            Rectangle { width: parent.width; height: 2; color: Colors.color13 }

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
                            ncPanel.trackedContentHeight = realHeight;
                        }
                    }

                    move: Transition {
                        NumberAnimation { properties: "y"; duration: 250; easing.type: Easing.OutCubic }
                    }
                    add: Transition {
                        NumberAnimation { properties: "y"; duration: 250; easing.type: Easing.OutCubic }
                    }

                    Repeater {
                        id: rep
                        model: ncRoot.groupedNotifications
                        
                        delegate: Item {
                            id: groupRoot
                            width: notifCol.width
                            
                            property var groupData: modelData
                            property var notifs: groupData.notifs
                            property bool expanded: ncRoot.expandedStates[groupData.appName] || false
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
                                        onClicked: if (notifs.length > 1) ncRoot.toggleGroup(groupData.appName)
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
                                    onClicked: ncRoot.toggleGroup(groupData.appName)
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
            visible: ncPanel.notifCount === 0
        }
    }
}