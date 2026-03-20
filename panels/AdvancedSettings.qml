// panels/AdvancedSettings.qml
import QtQuick
import Quickshell
import QtQuick.Controls
import qs.components
import qs.global

Panel {
    id: advPanel

    // ── Tab state ─────────────────────────────────────────────────────────
    property int activeTab: 0   // 0 = Navbar, 1 = Panels

    Column {
        anchors.fill: parent
        spacing: 0

        // ── Header ────────────────────────────────────────────────────────
        Text {
            id: advHeader
            text:           "󰒓  Advanced Settings"
            color:          Colors.foreground
            font.family:    Style.barFont
            font.pixelSize: 18
            font.weight:    Font.ExtraBold
            anchors.horizontalCenter: parent.horizontalCenter
            bottomPadding:  12
        }

        // ── Tab bar ───────────────────────────────────────────────────────
        Item {
            id: advTabBar
            width:  parent.width
            height: 36

            Row {
                anchors.centerIn: parent
                spacing: 8

                Repeater {
                    model: ["Navbar", "Panels"]
                    delegate: Rectangle {
                        required property string modelData
                        required property int    index

                        width:  100
                        height: 30
                        radius: 15
                        color:  advPanel.activeTab === index ? Colors.color7 : Colors.color0
                        Behavior on color { ColorAnimation { duration: 150 } }

                        Text {
                            anchors.centerIn: parent
                            text:        parent.modelData
                            color:       advPanel.activeTab === parent.index ? Colors.background : Colors.foreground
                            font.family: Style.barFont
                            font.pixelSize: 12
                            font.weight: Font.Bold
                            Behavior on color { ColorAnimation { duration: 150 } }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape:  Qt.PointingHandCursor
                            onClicked:    advPanel.activeTab = index
                        }
                    }
                }
            }
        }

        Rectangle { id: advDivider; width: parent.width; height: 1; color: Colors.color8; opacity: 0.5 }

        // ── Scrollable content ────────────────────────────────────────────
        ScrollView {
            id: scroll
            width:  parent.width
            height: parent.height - advHeader.implicitHeight - advTabBar.height - advDivider.height
            clip:   true

            ScrollBar.vertical: ScrollBar {
                policy: ScrollBar.AsNeeded
                contentItem: Rectangle {
                    implicitWidth: 4
                    radius:        2
                    color:         Colors.color7
                    opacity:       0.5
                }
            }

            Loader {
                width:           scroll.width
                sourceComponent: advPanel.activeTab === 0 ? advPanel.navbarTabComp : advPanel.panelsTabComp
            }
        }
    }

    // ── Tab content components ────────────────────────────────────────────
    property Component navbarTabComp: Column {
        width:      parent ? parent.width : 0 // FIX: Safely inherit the Loader's width
        spacing:    0
        topPadding: 12

        StyleSection { label: "Bar" }
        // FIX 2: Use the magically exposed 'newValue' variable directly
        StyleField { label: "Bar Size";      value: Style.barSize;      onCommitted: Style.saveSetting("barSize", newValue) }
        StyleField { label: "Module Size";   value: Style.moduleSize;   onCommitted: Style.saveSetting("moduleSize", newValue) }
        StyleField { label: "Bar Padding";   value: Style.barPadding;   onCommitted: Style.saveSetting("barPadding", newValue) }
        StyleField { label: "Bar Font";      value: Style.barFont;      isText: true; onCommitted: Style.saveSetting("barFont", newValue) }

        StyleSection { label: "Slots" }
        StyleField { label: "Slot Spacing";  value: Style.slotSpacing;  onCommitted: Style.saveSetting("slotSpacing", newValue) }

        StyleSection { label: "Pills" }
        StyleField { label: "Pill Padding";  value: Style.pillPadding;  onCommitted: Style.saveSetting("pillPadding", newValue) }
        StyleField { label: "Pill Spacing";  value: Style.pillSpacing;  onCommitted: Style.saveSetting("pillSpacing", newValue) }
        StyleField { label: "Pill Opacity";  value: Style.pillOpacity;  isDecimal: true; onCommitted: Style.saveSetting("pillOpacity", newValue) }
        StyleField { label: "Pill Radius";   value: Style.pillRadius;   onCommitted: Style.saveSetting("pillRadius", newValue) }

        StyleSection { label: "Chips" }
        StyleField { label: "Chip Spacing";       value: Style.chipSpacing;      onCommitted: Style.saveSetting("chipSpacing", newValue) }
        StyleField { label: "Chip Inner Spacing"; value: Style.chipInnerSpacing; onCommitted: Style.saveSetting("chipInnerSpacing", newValue) }

        StyleSection { label: "Borders" }
        StyleField { label: "Border Width";  value: Style.borderWidth;  disabled: Config.transparentNavbar; onCommitted: Style.saveSetting("borderWidth", newValue) }
        StyleField { label: "Corner Radius"; value: Style.cornerRadius; disabled: Config.transparentNavbar; onCommitted: Style.saveSetting("cornerRadius", newValue) }

        Item { width: 1; height: 12 }
    }

    property Component panelsTabComp: Column {
        width:      parent ? parent.width : 0 // FIX: Safely inherit the Loader's width
        spacing:    0
        topPadding: 12

        StyleSection { label: "Size" }
        StyleField { label: "Panel Width";   value: Style.panelWidth;   onCommitted: Style.saveSetting("panelWidth", newValue) }
        StyleField { label: "Panel Height";  value: Style.panelHeight;  onCommitted: Style.saveSetting("panelHeight", newValue) }

        StyleSection { label: "Shape" }
        StyleField { label: "Panel Radius";  value: Style.panelRadius;  onCommitted: Style.saveSetting("panelRadius", newValue) }
        StyleField { label: "Panel Padding"; value: Style.panelPadding; onCommitted: Style.saveSetting("panelPadding", newValue) }

        Item { width: 1; height: 12 }
    }

    // ── Section header ────────────────────────────────────────────────────
    component StyleSection: Item {
        property string label: ""
        width:  parent.width
        height: 32

        Text {
            anchors.verticalCenter: parent.verticalCenter
            anchors.left:           parent.left
            anchors.leftMargin:     16
            text:           label.toUpperCase()
            color:          Colors.color8
            font.family:    Style.barFont
            font.pixelSize: 10
            font.weight:    Font.ExtraBold
            font.letterSpacing: 1.5
        }

        Rectangle {
            anchors.bottom:      parent.bottom
            anchors.left:        parent.left
            anchors.right:       parent.right
            anchors.leftMargin:  16
            anchors.rightMargin: 16
            height: 1
            color:  Colors.color8
            opacity: 0.3
        }
    }

    // ── Individual field ──────────────────────────────────────────────────
    component StyleField: Item {
        id: field
        property string label:     ""
        property var    value:     0
        property bool   isText:    false
        property bool   isDecimal: false
        property bool   disabled:  false

        opacity: disabled ? 0.35 : 1.0
        Behavior on opacity { NumberAnimation { duration: Animations.normal; easing.type: Animations.easeInOut } }

        signal committed(var newValue)

        width:  parent.width
        height: 52

        Text {
            anchors.verticalCenter: parent.verticalCenter
            anchors.left:           parent.left
            anchors.leftMargin:     16
            text:           field.label
            color:          Colors.foreground
            font.family:    Style.barFont
            font.pixelSize: 13
            width:          160
            elide:          Text.ElideRight
        }

        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            anchors.right:          parent.right
            anchors.rightMargin:    16
            width:  120
            height: 32
            radius: 8
            color:  Colors.color0

            TextInput {
                id: input
                anchors.fill:         parent
                anchors.leftMargin:   10
                anchors.rightMargin:  10
                anchors.topMargin:    6
                anchors.bottomMargin: 6

                text:              String(field.value)
                color:             Colors.foreground
                font.family:       Style.barFont
                font.pixelSize:    13
                verticalAlignment: TextInput.AlignVCenter
                selectByMouse:     true
                readOnly:          field.disabled
                clip:              true

                validator: field.isText ? null : field.isDecimal ? decimalValidator : intValidator

                DoubleValidator { id: decimalValidator; bottom: 0; top: 1;   decimals: 2 }
                IntValidator    { id: intValidator;     bottom: 0; top: 9999             }

                Keys.onReturnPressed: commit()
                Keys.onEnterPressed:  commit()
                onEditingFinished:    commit()

                function commit() {
                    if (field.isText) {
                        field.committed(text)
                    } else if (field.isDecimal) {
                        let v = parseFloat(text)
                        if (!isNaN(v)) field.committed(v)
                        else text = String(field.value)
                    } else {
                        let v = parseInt(text)
                        if (!isNaN(v)) field.committed(v)
                        else text = String(field.value)
                    }
                }
            }
        }

        Rectangle {
            anchors.bottom: parent.bottom
            anchors.left:   parent.left
            anchors.right:  parent.right
            anchors.leftMargin:  16
            anchors.rightMargin: 16
            height: 1
            color:  Colors.color8
            opacity: 0.15
        }
    }
}