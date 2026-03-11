// modules/music/Music.qml
import QtQuick
import Quickshell
import Quickshell.Services.Mpris
import qs.globals
import qs.components

Rectangle {
    id: musicWidget
    visible: player !== null
    width: parent.width
    height: 120
    radius: 14
    color: Colors.color5
    border.color: Colors.foreground
    border.width: 2
    clip: true

    property MprisPlayer player: null

    function isMusicPlayer(player) {
        if (!player) return false;
        
        let id = (player.identity || player.dbusName || "").toLowerCase();
        
        const blockedApps = [
            "firefox", "chromium", "brave", "vivaldi", "edge", "opera",
            "mpv", "vlc", "smplayer", "celluloid",
            "kdeconnect", "gsconnect"
        ];

        for (let i = 0; i < blockedApps.length; i++) {
            if (id.indexOf(blockedApps[i]) !== -1) {
                return false;
            }
        }
        return true;
    }

    function updatePlayer() {
        let players = Mpris.players.values;
        let activePlayer = null;
        let fallbackPlayer = null;

        for (let i = 0; i < players.length; i++) {
            let p = players[i];
            
            if (isMusicPlayer(p)) {
                
                if (!fallbackPlayer) fallbackPlayer = p;
                
                if (p.playbackState === MprisPlaybackState.Playing) {
                    activePlayer = p;
                    break;
                }
            }
        }
        
        musicWidget.player = activePlayer || fallbackPlayer;
    }

    Connections {
        target: Mpris.players
        function onValuesChanged() { updatePlayer(); }
    }
    
    Component.onCompleted: updatePlayer()

    Row {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 15

        Rectangle {
            width: 96
            height: 96
            radius: 8
            color: Colors.background
            clip: true

            Image {
                anchors.fill: parent
                source: musicWidget.player && musicWidget.player.trackArtUrl ? musicWidget.player.trackArtUrl : ""
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
            }

            Text {
                anchors.centerIn: parent
                visible: !parent.children[0].source
                text: "󰓇" 
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 32
                color: "white"
            }
        }

        Item {
            width: parent.width - 111
            height: 96
            anchors.verticalCenter: parent.verticalCenter
            
            Column {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                spacing: 2
                
                Text {
                    text: musicWidget.player ? (musicWidget.player.trackTitle || "Unknown Title") : "No Music Playing"
                    color: "white"
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 15
                    font.weight: Font.Bold
                    elide: Text.ElideRight
                    width: parent.width
                }

                Text {
                    text: musicWidget.player ? (musicWidget.player.trackArtist || "Unknown Artist") : "Play some music!"
                    color: "white"
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 12
                    elide: Text.ElideRight
                    width: parent.width
                }
            }

            WavySlider {
                id: barSlide
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: playbackControls.top
                anchors.bottomMargin: 4
                height: 20
                
                property bool isSeeking: false
                
                Component.onCompleted: {
                    if (musicWidget.player && musicWidget.player.length > 0) {
                        value = musicWidget.player.position / musicWidget.player.length;
                    }
                }
                
                enableWave: musicWidget.player && musicWidget.player.playbackState === MprisPlaybackState.Playing && !pressed

                Timer {
                    id: seekDebounce
                    interval: 500
                    onTriggered: barSlide.isSeeking = false
                }

                FrameAnimation {
                    running: musicWidget.player && musicWidget.player.playbackState === MprisPlaybackState.Playing
                    onTriggered: {
                        if (musicWidget.player && musicWidget.player.length > 0) {
                            if (!barSlide.pressed && !barSlide.isSeeking) {
                                barSlide.value = musicWidget.player.position / musicWidget.player.length;
                            }
                            musicWidget.player.positionChanged();
                        }
                    }
                }

                onPressedChanged: {
                    if (!pressed && musicWidget.player && musicWidget.player.canSeek) {
                        barSlide.isSeeking = true;
                        musicWidget.player.position = value * musicWidget.player.length;
                        seekDebounce.restart();
                    }
                }
            }

            Row {
                id: playbackControls
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                spacing: 25
                
                Text {
                    text: "󰒮" 
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 22
                    color: "white"
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: if (musicWidget.player) musicWidget.player.previous()
                    }
                }

                Text {
                    text: musicWidget.player && musicWidget.player.playbackState === MprisPlaybackState.Playing ? "󰏤" : "󰐊"
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 24
                    color: "white"
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: if (musicWidget.player) musicWidget.player.togglePlaying()
                    }
                }

                Text {
                    text: "󰒭" 
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 22
                    color: "white"
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: if (musicWidget.player) musicWidget.player.next()
                    }
                }
            }
        }
    }
}