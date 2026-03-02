import QtQuick
import ".."
import "../../shared"

Grid {
    id: root
    spacing: 13
    
    readonly property bool isSide: navbar.location === "left" || navbar.location === "right"
    
    columns: isSide ? 1 : 0
    rows: isSide ? 0 : 1

    anchors {
        verticalCenter: isSide ? undefined : parent.verticalCenter
        horizontalCenter: isSide ? parent.horizontalCenter : undefined
        
        right: isSide ? undefined : parent.right
        bottom: isSide ? parent.bottom : undefined
        
        rightMargin: isSide ? 0 : 35
        bottomMargin: isSide ? 35 : 0
    }

    Button {
        id: notif
        labelText: "󰂚"
        labelFont: navbar.font
        buttonSize: (isSide ? parent.parent.width : parent.parent.height) / 1.65
        buttonColor: Colors.color7
    }

    Button {
        id: settings
        labelText: ""
        labelFont: navbar.font
        buttonSize: (isSide ? parent.parent.width : parent.parent.height) / 1.65
        buttonColor: Colors.color7
    }

    Button {
        id: power
        labelText: "⏻"
        labelFont: navbar.font
        buttonSize: (isSide ? parent.parent.width : parent.parent.height) / 1.65
        buttonColor: Colors.color7
    }
}
