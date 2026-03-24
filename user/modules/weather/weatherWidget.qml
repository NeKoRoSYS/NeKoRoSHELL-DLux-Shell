// ~/.config/quickshell/user/modules/weather/weatherWidget.qml
import QtQuick
import qs.global

Item {
    id: root
    anchors.fill: parent

    Loader {
        id: backendLoader
        source: "weather.qml"
    }

    property var backend: backendLoader.item

    Column {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 8

        Text {
            text: "Weather"
            color: Colors.color8
            font.family: Style.barFont
            font.pixelSize: 11
            font.weight: Font.Bold
            font.letterSpacing: 1.2
        }

        Item {
            width: parent.width
            height: parent.height - 40 

            Row {
                anchors.centerIn: parent
                spacing: 12

                Text {
                    text: backend ? backend.weatherIcon : "󰖐"
                    color: backend ? backend.iconColor : Colors.foreground
                    font.family: Style.barFont
                    font.pixelSize: 42
                    anchors.verticalCenter: parent.verticalCenter
                }

                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    Text {
                        text: backend ? backend.temp : "--"
                        color: Colors.foreground
                        font.family: Style.barFont
                        font.pixelSize: 28
                        font.weight: Font.ExtraBold
                    }
                    Text {
                        text: backend ? backend.conditionText : "Loading..."
                        color: Colors.color8
                        font.family: Style.barFont
                        font.pixelSize: 12
                    }
                }
            }

            Row {
                anchors.bottom: parent.bottom
                anchors.right: parent.right
                spacing: 4
                opacity: 0.6

                Text {
                    text: "󰖝" 
                    color: Colors.foreground
                    font.family: Style.barFont
                    font.pixelSize: 10
                }
                Text {
                    text: backend ? backend.wind : "--"
                    color: Colors.foreground
                    font.family: Style.barFont
                    font.pixelSize: 10
                }
            }
        }
    }
    
    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: { if (backend) backend.fetchWeather() }
    }
}