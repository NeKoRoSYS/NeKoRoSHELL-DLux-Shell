// user/modules/weather/weather.qml
import QtQuick
import qs.global

Item {
    id: root

    property string moduleType: "static"

    property string temp: "--"
    property string conditionText: "..."
    property string weatherIcon: "󰖐"
    property string wind: "--"
    property color iconColor: Colors.foreground

    readonly property real lat: 14.6042
    readonly property real lon: 120.9822

    function fetchWeather() {
        var xhr = new XMLHttpRequest();
        xhr.open("GET", "https://api.open-meteo.com/v1/forecast?latitude=" + lat + "&longitude=" + lon + "&current=temperature_2m,weather_code,wind_speed_10m&timezone=auto");
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE && xhr.status === 200) {
                var data = JSON.parse(xhr.responseText);
                var current = data.current;
                
                root.temp = Math.round(current.temperature_2m) + "°C";
                root.wind = current.wind_speed_10m + " km/h";
                parseWeatherCode(current.weather_code);
            }
        }
        xhr.send();
    }

    function parseWeatherCode(code) {
        if (code === 0) {
            weatherIcon = "󰖙"; conditionText = "Clear Sky"; iconColor = Colors.color3;
        } else if (code >= 1 && code <= 3) {
            weatherIcon = "󰖐"; conditionText = "Cloudy"; iconColor = Colors.color7;
        } else if (code === 45 || code === 48) {
            weatherIcon = "󰖑"; conditionText = "Foggy"; iconColor = Colors.color8;
        } else if ((code >= 51 && code <= 55) || (code >= 61 && code <= 65)) {
            weatherIcon = "󰖖"; conditionText = "Rain"; iconColor = Colors.color4;
        } else if (code >= 71 && code <= 77) {
            weatherIcon = "󰖘"; conditionText = "Snow"; iconColor = Colors.color7;
        } else if (code >= 95 && code <= 99) {
            weatherIcon = "󰖓"; conditionText = "Storm"; iconColor = Colors.color5;
        } else {
            weatherIcon = "󰖐"; conditionText = "Unknown"; iconColor = Colors.foreground;
        }
    }

    Component.onCompleted: fetchWeather()
    Timer {
        interval: 900000 
        running: true
        repeat: true
        onTriggered: fetchWeather()
    }
}