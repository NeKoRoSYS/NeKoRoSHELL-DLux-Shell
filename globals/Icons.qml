// globals/Icons.qml
pragma Singleton

import QtQuick

QtObject {
    id: root

    readonly property var iconMap: {
        "firefox": "󰈹",
        "kitty": "󰄛",
        "alacritty": "󰄛",
        "discord": "󰙯",
        "vesktop": "󰙯",
        "code": "󰨞",
        "code-oss": "󰨞",
        "unity": "󰚯",
        "unityhub": "󰚯",
        "thunar": "󰉋",
        "nautilus": "󰉋",
        "spotify": "󰓇",
        "cider": "󰓇",
        "apple-music": "󰓇",
        "steam": "󰓓",
        "obs": "󰑋",
        "vlc": "󰕼",
        "mpv": "󰕼",
        "org.kde.dolphin": "󰉋"
    }

    function getIcon(appClass) {
        if (!appClass) return "?";
        let lowerClass = appClass.toLowerCase();
        
        if (iconMap[lowerClass]) {
            return iconMap[lowerClass];
        }
        return appClass.substring(0, 1).toUpperCase();
    }
}