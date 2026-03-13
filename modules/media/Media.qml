// modules/media/Media.qml
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Mpris

QtObject {
    id: root
    readonly property string moduleType: "custom"

    readonly property var player: {
        let _count = Mpris.players.count; 
        let players = Mpris.players.values;
        
        if (_count === 0 || !players || players.length === 0) return null;
        
        for (let i = 0; i < players.length; i++) {
            let state = players[i].playbackState; 
            if (state === MprisPlaybackState.Playing || state === 1) {
                return players[i];
            }
        }
        
        return players.length > 0 ? players[0] : null;
    }

    readonly property bool hasPlayer:      player !== null
    readonly property bool isPlaying:      hasPlayer && (player.playbackState === MprisPlaybackState.Playing || player.playbackState === 1)

    readonly property string title:        hasPlayer ? (player.trackTitle || player.identity || "Unknown") : ""
    readonly property string artist:       hasPlayer ? (player.trackArtist || "") : ""

    function play()   { if (hasPlayer) player.play() }
    function pause()  { if (hasPlayer) player.pause() }
    function toggle() { if (hasPlayer) player.togglePlaying() }
    function next()   { if (hasPlayer) player.next() }
    function prev()   { if (hasPlayer) player.previous() }
}