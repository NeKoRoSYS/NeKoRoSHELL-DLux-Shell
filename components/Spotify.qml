import QtQuick
import Quickshell
import Quickshell.Services.Mpris
import qs.globals
import qs.components

Rectangle {
    id: spotifyWidget
    width: parent.width
    height: 120
    radius: 14
    color: Colors.color1
    border.color: Colors.color3
    border.width: 2
    clip: true

    property MprisPlayer player: null

    function updatePlayer() {
        let p = null;
        for (let i = 0; i < Mpris.players.values.length; i++) {
            if (Mpris.players.values[i].dbusName.indexOf("spotify") !== -1 || 
                Mpris.players.values[i].identity.toLowerCase() === "spotify") {
                p = Mpris.players.values[i];
                break;
            }
        }
        spotifyWidget.player = p;
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
                source: spotifyWidget.player && spotifyWidget.player.trackArtUrl ? spotifyWidget.player.trackArtUrl : ""
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
            }

            Text {
                anchors.centerIn: parent
                visible: !parent.children[0].source
                text: "󰓇" 
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 32
                color: Colors.color2 
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
                    text: spotifyWidget.player ? (spotifyWidget.player.trackTitle || "Unknown Title") : "Spotify Not Running"
                    color: Colors.foreground
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 15
                    font.weight: Font.Bold
                    elide: Text.ElideRight
                    width: parent.width
                }

                Text {
                    text: spotifyWidget.player ? (spotifyWidget.player.trackArtist || "Unknown Artist") : "Play some music!"
                    color: Colors.color7
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
                    if (spotifyWidget.player && spotifyWidget.player.length > 0) {
                        value = spotifyWidget.player.position / spotifyWidget.player.length;
                    }
                }
                
                enableWave: spotifyWidget.player && spotifyWidget.player.playbackState === MprisPlaybackState.Playing && !pressed

                Timer {
                    id: seekDebounce
                    interval: 500
                    onTriggered: barSlide.isSeeking = false
                }

                FrameAnimation {
                    running: spotifyWidget.player && spotifyWidget.player.playbackState === MprisPlaybackState.Playing
                    onTriggered: {
                        if (spotifyWidget.player && spotifyWidget.player.length > 0) {
                            if (!barSlide.pressed && !barSlide.isSeeking) {
                                barSlide.value = spotifyWidget.player.position / spotifyWidget.player.length;
                            }
                            spotifyWidget.player.positionChanged();
                        }
                    }
                }

                onPressedChanged: {
                    if (!pressed && spotifyWidget.player && spotifyWidget.player.canSeek) {
                        barSlide.isSeeking = true;
                        spotifyWidget.player.position = value * spotifyWidget.player.length;
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
                    color: Colors.foreground
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: if (spotifyWidget.player) spotifyWidget.player.previous()
                    }
                }

                Text {
                    text: spotifyWidget.player && spotifyWidget.player.playbackState === MprisPlaybackState.Playing ? "󰏤" : "󰐊"
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 24
                    color: Colors.foreground
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: if (spotifyWidget.player) spotifyWidget.player.togglePlaying()
                    }
                }

                Text {
                    text: "󰒭" 
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 22
                    color: Colors.foreground
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: if (spotifyWidget.player) spotifyWidget.player.next()
                    }
                }
            }
        }
    }
}