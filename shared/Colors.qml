// quickshell/shared/Colors.qml
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property alias themeAdapter: themeAdapter

    property var special: [background, foreground, cursor]
    property color background: themeAdapter.special.background
    property color foreground: themeAdapter.special.foreground
    property color cursor: themeAdapter.special.cursor

    property var colors: [color0, color1, color2, color3, color4, color5, color6, color7, color8, color9, color10, color11, color12, color13, color14, color15]
    property color color0: themeAdapter.colors.color0
    property color color1: themeAdapter.colors.color1
    property color color2: themeAdapter.colors.color2
    property color color3: themeAdapter.colors.color3
    property color color4: themeAdapter.colors.color4
    property color color5: themeAdapter.colors.color5
    property color color6: themeAdapter.colors.color6
    property color color7: themeAdapter.colors.color7
    property color color8: themeAdapter.colors.color8
    property color color9: themeAdapter.colors.color9
    property color color10: themeAdapter.colors.color10
    property color color11: themeAdapter.colors.color11
    property color color12: themeAdapter.colors.color12
    property color color13: themeAdapter.colors.color13
    property color color14: themeAdapter.colors.color14
    property color color15: themeAdapter.colors.color15

    Process {
        id: wallustProcess
        onExited: (exitCode) => {
            if (exitCode === 0) {
                themeFile.reload()
            }
        }
    }

    function reloadColors() {
        const wallustConfig = Config.lightMode ? "wallust-light.toml" : "wallust-dark.toml";
        const cmdString = `wallust run "${Config.wallpaperPath}" -q -C ~/.config/wallust/${wallustConfig} || wallust run "${Config.wallpaperPath}" -q -C ~/.config/wallust/${wallustConfig} -b full -t 5`;
        wallustProcess.command = ["sh", "-c", cmdString + "; hyprctl reload"];
        wallustProcess.running = true;
    }

    FileView {
        id: themeFile
        path: Quickshell.env("HOME") + "/.cache/wallust/colors.json"

        adapter: JsonAdapter {
            id: themeAdapter

            property JsonObject special: JsonObject {
                property color background: "#1E1E2E"
                property color foreground: "#CDD6F4"
                property color cursor: "#F5E0DC"
            }

            property JsonObject colors: JsonObject {
                property color color0: "#45475A"
                property color color1: "#F38BA8"
                property color color2: "#A6E3A1"
                property color color3: "#F9E2AF"
                property color color4: "#89B4FA"
                property color color5: "#F5C2E7"
                property color color6: "#94E2D5"
                property color color7: "#BAC2DE"
                property color color8: "#585B70"
                property color color9: "#F38BA8"
                property color color10: "#A6E3A1"
                property color color11: "#F9E2AF"
                property color color12: "#89B4FA"
                property color color13: "#F5C2E7"
                property color color14: "#94E2D5"
                property color color15: "#A6ADC8"
            }
        }
    }
}
