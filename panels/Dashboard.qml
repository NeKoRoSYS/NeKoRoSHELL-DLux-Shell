// panels/Dashboard.qml — panel structure only
// Widget components live in engine/DashboardRegistry.qml
// Grid logic lives in engine/DashboardEngine.qml
import QtQuick
import QtQuick.Controls
import Quickshell.Services.Mpris
import qs.components
import qs.engine
import qs.global
import qs.modules.media
import qs.modules.music
import qs.modules.notifications

Panel {
    id: dashboardPanel

    panelWidth:      Style.panelWidth
    panelHeight:     Style.panelHeight
    animationPreset: "slide"

    property var engine: DashboardEngine {}

    ScrollView {
        id: scroll
        anchors.fill: parent
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
            topPadding: 4
            
            // ── Header ────────────────────────────────────────────────────
            Item {
                width:  parent.width
                height: 44

                Column {
                    anchors.left:           parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 2
                    Text {
                        text:           Time.date
                        color:          Colors.foreground
                        font.family:    Style.barFont
                        font.pixelSize: 18
                        font.weight:    Font.ExtraBold
                    }
                }

                Rectangle {
                    anchors.right:          parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    width: 70; height: 28; radius: 14
                    color: engine.editMode ? Colors.color7 : Colors.color0
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
                                color:         Colors.color0
                                clip:          true
                                layer.enabled: true

                                Loader {
                                    anchors.fill:    parent
                                    sourceComponent: ModuleRegistry.resolveWidget(modelData.id)
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
                                    anchors.bottom:              parent.bottom
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
                                        Text { text: parent.parent.modelData.icon;  color: alreadyAdded ? Colors.foreground : Colors.background; font.family: Style.barFont; font.pixelSize: 12 }
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

            Music { }
        }
    }

    component MediaButton: Rectangle {
        property string icon:    ""
        property color  bgColor: Colors.color0
        signal clicked()
        width: 36; height: 36; radius: 18; color: bgColor
        Text { anchors.centerIn: parent; text: parent.icon; color: Colors.background; font.family: Style.barFont; font.pixelSize: 16 }
        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: parent.clicked() }
    }
}