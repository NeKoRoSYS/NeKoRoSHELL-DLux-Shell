// quickshell/shared/Colors.qml
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
  id: root

  property alias themeAdapter: themeAdapter

  readonly property color background: themeAdapter.special.background
  readonly property color foreground: themeAdapter.special.foreground
  readonly property color cursor: themeAdapter.special.cursor

  readonly property color color0: themeAdapter.colors.color0
  readonly property color color1: themeAdapter.colors.color1
  readonly property color color2: themeAdapter.colors.color2
  readonly property color color3: themeAdapter.colors.color3
  readonly property color color4: themeAdapter.colors.color4
  readonly property color color5: themeAdapter.colors.color5
  readonly property color color6: themeAdapter.colors.color6
  readonly property color color7: themeAdapter.colors.color7
  readonly property color color8: themeAdapter.colors.color8
  readonly property color color9: themeAdapter.colors.color9
  readonly property color color10: themeAdapter.colors.color10
  readonly property color color11: themeAdapter.colors.color11
  readonly property color color12: themeAdapter.colors.color12
  readonly property color color13: themeAdapter.colors.color13
  readonly property color color14: themeAdapter.colors.color14
  readonly property color color15: themeAdapter.colors.color15

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