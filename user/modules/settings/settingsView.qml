// user/modules/settings/settingsView.qml
import QtQuick
import qs.global
import qs.components

Item {
    id: root
    
    property var backend
    property bool isHorizontal: Config.isHorizontal
    property real barThickness: Style.moduleSize
    property string barFont: Style.barFont

    implicitWidth:  root.barThickness
    implicitHeight: root.barThickness
    width:  implicitWidth
    height: implicitHeight

    StaticChip {
        anchors.fill: parent
        isHorizontal: root.isHorizontal
        barThickness: root.barThickness
        barFont: root.barFont
        
        item: {
            "icon": "",
            "active": false, 
            "onClicked": function() { EventBus.togglePanel("settings", null) }
        }
    }
}