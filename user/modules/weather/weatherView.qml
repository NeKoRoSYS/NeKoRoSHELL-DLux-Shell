// user/modules/weather/weatherView.qml
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

    implicitWidth:  isHorizontal ? hPill.width : barThickness
    implicitHeight: isHorizontal ? barThickness : vPill.height
    
    width: implicitWidth
    height: implicitHeight

    // ── Horizontal Pill ───────────────────────────────────────────────────
    Rectangle {
        id: hPill
        visible:          root.isHorizontal
        anchors.centerIn: parent
        
        width:            metricText.implicitWidth + 30
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

    // ── Vertical Pill ─────────────────────────────────────────────────────
    Rectangle {
        id: vPill
        visible:          !root.isHorizontal
        anchors.centerIn: parent
        
        width:            root.barThickness
        height:           vCol.implicitHeight + 24
        radius:           width / 2

        color: vMouseArea.containsMouse 
            ? "white" 
            : (Config.transparentNavbar ? Colors.background : Colors.color3)
            
        Behavior on color { ColorAnimation { duration: 150 } }

        Column {
            id: vCol
            anchors.centerIn: parent
            spacing: 2
            
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: currentIcon
                font.family: root.barFont
                font.pixelSize: 13
                
                color: vMouseArea.containsMouse 
                    ? Colors.color3 
                    : (Config.lightMode && Config.transparentNavbar ? "black" : "white")
                Behavior on color { ColorAnimation { duration: 150 } }
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: currentTemp.replace("°C", "")
                font.family: root.barFont
                font.pixelSize: 11
                font.weight: Font.Bold
                
                color: vMouseArea.containsMouse 
                    ? Colors.color3 
                    : (Config.lightMode && Config.transparentNavbar ? "black" : "white")
                Behavior on color { ColorAnimation { duration: 150 } }
            }

            // The unit stacked underneath
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "°C"
                font.family: root.barFont
                font.pixelSize: 9
                font.weight: Font.Bold
                
                color: vMouseArea.containsMouse 
                    ? Colors.color3 
                    : (Config.lightMode && Config.transparentNavbar ? "black" : "white")
                Behavior on color { ColorAnimation { duration: 150 } }
            }
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