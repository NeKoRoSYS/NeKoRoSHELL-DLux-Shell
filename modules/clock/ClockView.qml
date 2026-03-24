// modules/clock/ClockView.qml
import QtQuick
import qs.global
import qs.modules.clock

Item {
    id: root
    
    property bool   isHorizontal: Config.isHorizontal
    property real   barThickness: Style.moduleSize
    property string barFont:      Style.barFont

    readonly property string timeHour: Clock.time.split(":")[0] ?? ""
    readonly property string timeMin:  Clock.time.split(":")[1] ?? ""
    
    readonly property real pillThickness: barThickness

    Text {
        id: timeMetrics
        text:           Clock.time
        font.family:    root.barFont
        font.pixelSize: 12
        font.weight:    Font.ExtraBold
        visible:        false
    }

    implicitWidth:  isHorizontal ? hPill.implicitWidth : barThickness
    implicitHeight: isHorizontal ? barThickness        : vPill.height

    // ── Horizontal ────────────────────────────────────────────────────────
    Rectangle {
        id: hPill
        visible:          root.isHorizontal
        anchors.centerIn: parent
        
        implicitWidth:    timeMetrics.implicitWidth + 30
        height:           root.pillThickness
        radius:           height / 2

        color: hMouseArea.containsMouse ? "white" : Config.transparentNavbar ? Colors.background : Colors.color3
        Behavior on color { ColorAnimation { duration: 150 } }

        Text {
            id: hTimeText
            anchors.centerIn: parent
            
            text: hMouseArea.containsMouse ? "󰣇" : Clock.time
            
            font.family:    root.barFont
            font.pixelSize: 12
            font.weight:    Font.ExtraBold
            
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment:   Text.AlignVCenter
            
            color: hMouseArea.containsMouse ? Colors.color3 : Config.lightMode && Config.transparentNavbar ? "black" : "white"
            Behavior on color { ColorAnimation { duration: 150 } }
        }
        
        MouseArea {
            id: hMouseArea
            hoverEnabled: true
            anchors.fill: parent
            cursorShape:  Qt.PointingHandCursor
            onClicked:    EventBus.togglePanel("dashboard", null)
        }
    }

    // ── Vertical ──────────────────────────────────────────────────────────
    Rectangle {
        id: vPill
        visible:          !root.isHorizontal
        anchors.centerIn: parent
        
        width:  root.pillThickness
        height: timeMetrics.implicitHeight + 30
        radius: width / 2
        
        color: vMouseArea.containsMouse ? "white" : Config.transparentNavbar ? Colors.background : Colors.color3
        Behavior on color { ColorAnimation { duration: 150 } }

        Column {
            id: vInner
            anchors.centerIn: parent
            spacing: 0
            
            Text {
                visible: vMouseArea.containsMouse
                anchors.horizontalCenter: parent.horizontalCenter
                
                text:           "󰣇"
                font.family:    root.barFont
                font.pixelSize: 12
                font.weight:    Font.ExtraBold
                
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment:   Text.AlignVCenter
                
                color: Colors.color3
            }

            Text {
                visible: !vMouseArea.containsMouse
                anchors.horizontalCenter: parent.horizontalCenter
                
                text:           root.timeHour
                font.family:    root.barFont
                font.pixelSize: 12
                font.weight:    Font.ExtraBold
                
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment:   Text.AlignVCenter
                
                color: Config.lightMode && Config.transparentNavbar ? "black" : "white"
            }
            Text {
                visible: !vMouseArea.containsMouse
                anchors.horizontalCenter: parent.horizontalCenter
                
                text:           root.timeMin
                font.family:    root.barFont
                font.pixelSize: 12
                font.weight:    Font.ExtraBold
                
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment:   Text.AlignVCenter
                
                color: Config.lightMode && Config.transparentNavbar ? "black" : "white"
            }
        }
        
        MouseArea {
            id: vMouseArea
            hoverEnabled: true
            anchors.fill: parent
            cursorShape:  Qt.PointingHandCursor
            onClicked:    EventBus.togglePanel("dashboard")
        }
    }
}