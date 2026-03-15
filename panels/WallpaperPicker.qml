// panels/WallpaperPicker.qml
import QtQuick
import Quickshell.Wayland
import qs.global
import qs.components

Panel {
    id: wpPanel

    edgePadding: 15
    panelWidth:  800
    panelHeight: 550
    animationPreset: "slide"
    keyboardFocus: WlrKeyboardFocus.Exclusive

    Connections {
        target: WallpaperManager
        function onWallhavenResultsChanged() { 
            if (wpRoot.wallhavenMode) wpRoot.updateSearch(); 
        }

        function onWallpapersChanged() {
            if (!wpRoot.wallhavenMode) wpRoot.updateSearch();
        }
    }

    Rectangle {
        id: wpRoot
        anchors.fill: parent
        color: "transparent"
        border.color: Colors.color13
        border.width: 2
        radius: 10
        clip: true

        property string searchQuery: ""
        property var filteredWallpapers: WallpaperManager.wallpapers
        property bool wallhavenMode: false

        Component.onCompleted: focusTimer.restart()

        Connections {
            target: wpPanel
            function onShowPanelChanged() {
                if (!wpPanel.showPanel) {
                    wpRoot.searchQuery = ""
                    searchInput.focus = false
                } else {
                    focusTimer.restart()
                }
            }
        }

        Timer {
            id: focusTimer
            interval: 15
            onTriggered: searchInput.forceActiveFocus()
        }

        Shortcut {
            sequence: "Escape"
            onActivated: EventBus.togglePanel("wallpaper")
        }

        Timer {
            id: searchDebounce
            interval: 500
            onTriggered: {
                if (wpRoot.wallhavenMode) {
                    WallpaperManager.searchWallhaven(wpRoot.searchQuery);
                }
            }
        }

        function fuzzyMatch(str, pattern) {
            pattern = pattern.toLowerCase().replace(/\s+/g, "");
            str = str.toLowerCase();
            let patternIdx = 0;
            for (let i = 0; i < str.length && patternIdx < pattern.length; i++) {
                if (str[i] === pattern[patternIdx]) {
                    patternIdx++;
                }
            }
            return patternIdx === pattern.length;
        }

        function updateSearch() {
            let query = wpRoot.searchQuery.trim();
            
            if (query.startsWith("http")) {
                wpRoot.filteredWallpapers = [{
                    name: "󰇚  Download Link...",
                    path: query,
                    thumb: "",
                    isDownloadAction: true
                }];
            } 
            else if (wpRoot.wallhavenMode) {
                wpRoot.filteredWallpapers = WallpaperManager.wallhavenResults;
            } 
            else {
                wpRoot.filteredWallpapers = WallpaperManager.wallpapers.filter(
                    wp => wpRoot.fuzzyMatch(wp.name, query)
                );
            }
        }

        onSearchQueryChanged: {
            if (wallhavenMode) {
                searchDebounce.restart();
            }
            updateSearch();
        }

        Connections {
            target: WallpaperManager
            function onWallhavenFetched() { 
                if (wpRoot.wallhavenMode) wpRoot.updateSearch(); 
            }
        }

        Column {
            anchors.fill: parent
            anchors.margins: 15
            spacing: 15

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 20
                 
                Text {
                    text: "   Wallpapers"
                    color: Colors.foreground
                    font.family: "JetBrains Mono"
                    font.pixelSize: 18
                    font.weight: Font.ExtraBold
                    anchors.verticalCenter: parent.verticalCenter
                }

                Button {
                    labelText: ""
                    labelFont: "JetBrainsMono Nerd Font"
                    buttonSize: 30
                    buttonColor: Colors.color3
                    onButtonClicked: WallpaperManager.setRandom()
                    anchors.verticalCenter: parent.verticalCenter
                }

                Button {
                    labelText: wpRoot.wallhavenMode ? "󰈹" : "󰉉"
                    labelFont: "JetBrainsMono Nerd Font"
                    buttonSize: 30
                    buttonColor: Colors.color3
                    onButtonClicked: {
                        wpRoot.wallhavenMode = !wpRoot.wallhavenMode;
                        wpRoot.updateSearch();
                    }
                }
            }

            // ── Search Bar ────────────────────────────────────────────────────
            Rectangle {
                width: parent.width
                height: 36
                color: Colors.color0
                border.color: Colors.color8
                border.width: 1
                radius: 5

                TextInput {
                    id: searchInput
                    focus: true
                    anchors.fill: parent
                    anchors.margins: 8
                    verticalAlignment: TextInput.AlignVCenter
                    color: Colors.foreground
                    font.family: "JetBrains Mono"
                    font.pixelSize: 14
                    clip: true
                    text: wpRoot.searchQuery
                    onTextEdited: {
                        wpRoot.searchQuery = text
                    }

                    Text {
                        text: "  Search wallpapers..."
                        color: Colors.color8
                        font.family: "JetBrains Mono"
                        font.pixelSize: 14
                        visible: !parent.text && !parent.activeFocus
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }

            Rectangle { width: parent.width; height: 1; color: Colors.color8; opacity: 0.5 }

            GridView {
                id: wpGrid
                width: parent.width
                height: parent.height - 115
                cellWidth:  parent.width / 4
                cellHeight: 140
                clip: true
                
                model: wpRoot.filteredWallpapers

                delegate: Item {
                    width: wpGrid.cellWidth
                    height: wpGrid.cellHeight

                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: 8
                        radius: 5
                        color: Colors.color0
                        
                        border.color: Config.wallpaperPath === modelData.path ? Colors.color5 : Colors.color13
                        border.width: 2
                        clip: true

                        Image {
                            anchors.fill: parent
                            source: {
                                if (!modelData.thumb) return "";
                                if (modelData.thumb.startsWith("http")) return modelData.thumb;
                                return "file://" + modelData.thumb;
                            }
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                            
                            onStatusChanged: {
                                if (status === Image.Error && !modelData.path.startsWith("http")) {
                                    source = "file://" + modelData.path;
                                }
                            }
                        }

                        Rectangle {
                            anchors.bottom: parent.bottom
                            width: parent.width
                            height: 24
                            color: Config.wallpaperPath === modelData.path ? Colors.color5 : "#B3000000"

                            Text {
                                anchors.centerIn: parent
                                text: modelData.name
                                color: "white"
                                font.family: "JetBrains Mono"
                                font.pixelSize: 12
                                elide: Text.ElideRight
                                width: parent.width - 10
                                horizontalAlignment: Text.AlignHCenter
                                font.weight: Config.wallpaperPath === modelData.path ? Font.Bold : Font.Normal
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                console.log("Clicked: " + modelData.path); // Debug check
                                if (modelData.isDownloadAction === true || modelData.isRemote === true) {
                                    WallpaperManager.downloadWallpaper(modelData.path);
                                    wpRoot.searchQuery = ""; 
                                } else {
                                    WallpaperManager.setWallpaper(modelData.path);
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}