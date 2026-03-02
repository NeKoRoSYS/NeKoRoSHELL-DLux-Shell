import QtQuick
import ".."
import "../../shared"

Grid {
    id: root
    spacing: 13
    
    readonly property bool isSide: navbar.isVertical

    signal toggleSettingsPanel()

    columns: isSide ? 1 : 0
    rows: isSide ? 0 : 1

    Button {
        id: notif
        labelText: "󰂚"
        labelFont: navbar.font
        buttonSize: (isSide ? parent.parent.width : parent.parent.height) / 1.65
        buttonColor: Colors.color7
        onButtonClicked: {
            console.log("Test")
        }
    }

    Button {
        id: settings
        labelText: ""
        labelFont: navbar.font
        buttonSize: (isSide ? parent.parent.width : parent.parent.height) / 1.65
        buttonColor: Colors.color7
        onButtonClicked: root.toggleSettingsPanel()
    }

    Button {
        id: power
        labelText: "⏻"
        labelFont: navbar.font
        buttonSize: (isSide ? parent.parent.width : parent.parent.height) / 1.65
        buttonColor: Colors.color7
        onButtonClicked: {
            console.log("Test")
        }
    }
}
