// ~/.config/quickshell/user/modules/weather/weatherView.qml
import QtQuick
import qs.global

Item {
    id: root
    
    // Injected by ModuleLoader asynchronously
    property var backend
    property bool isHorizontal: Config.isHorizontal
    property real barThickness: Style.moduleSize
    property string barFont: Style.barFont

    readonly property string currentIcon: root.backend ? root.backend.weatherIcon : "󰖐"
    readonly property string currentTemp: root.backend ? root.backend.temp : "--"

    Text {
        id: metricText
        text: currentIcon + "  " + currentTemp
        font.family: root.barFont
        font.pixelSize: 12
        font.weight: Font.Bold
        visible: false
    }

    implicitWidth:  isHorizontal ? hPill.implicitWidth : barThickness
    implicitHeight: isHorizontal ? barThickness : barThickness

    // ── Horizontal Pill ───────────────────────────────────────────────────
    Rectangle {
        id: hPill
        visible:          root.isHorizontal
        anchors.centerIn: parent
        
        implicitWidth:    metricText.implicitWidth + 30
        height:           root.barThickness
        radius:           height / 2

        color: hMouseArea.containsMouse 
            ? "white" 
            : (Config.transparentNavbar ? Colors.background : Colors.color3)
            
        Behavior on color { ColorAnimation { duration: 150 } }

        Row {
            anchors.centerIn: parent
            spacing: 8
            
            Text {
                text: currentIcon
                font.family: root.barFont
                font.pixelSize: 13
                anchors.verticalCenter: parent.verticalCenter
                
                color: hMouseArea.containsMouse 
                    ? Colors.color3 
                    : (Config.lightMode && Config.transparentNavbar ? "black" : "white")
                Behavior on color { ColorAnimation { duration: 150 } }
            }
            Text {
                text: currentTemp
                font.family: root.barFont
                font.pixelSize: 12
                font.weight: Font.Bold
                anchors.verticalCenter: parent.verticalCenter
                
                color: hMouseArea.containsMouse 
                    ? Colors.color3 
                    : (Config.lightMode && Config.transparentNavbar ? "black" : "white")
                Behavior on color { ColorAnimation { duration: 150 } }
            }
        }
        
        MouseArea {
            id: hMouseArea
            hoverEnabled: true
            anchors.fill: parent
            cursorShape:  Qt.PointingHandCursor
            onClicked: { if (root.backend) root.backend.fetchWeather() }
        }
    }

    // ── Vertical Pill (Fallback) ──────────────────────────────────────────
    Rectangle {
        id: vPill
        visible:          !root.isHorizontal
        anchors.centerIn: parent
        
        width:            root.barThickness
        height:           root.barThickness
        radius:           width / 2

        color: vMouseArea.containsMouse 
            ? "white" 
            : (Config.transparentNavbar ? Colors.background : Colors.color3)
            
        Behavior on color { ColorAnimation { duration: 150 } }

        Text {
            anchors.centerIn: parent
            text: currentIcon
            font.family: root.barFont
            font.pixelSize: 14
            
            color: vMouseArea.containsMouse 
                ? Colors.color3 
                : (Config.lightMode && Config.transparentNavbar ? "black" : "white")
            Behavior on color { ColorAnimation { duration: 150 } }
        }
        
        MouseArea {
            id: vMouseArea
            hoverEnabled: true
            anchors.fill: parent
            cursorShape:  Qt.PointingHandCursor
            onClicked: { if (root.backend) root.backend.fetchWeather() }
        }
    }
}