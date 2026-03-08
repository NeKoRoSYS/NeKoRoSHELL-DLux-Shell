// modules/media/Media.qml
import QtQuick
import Quickshell
import Quickshell.Services.Mpris
import qs.globals

Item {
    id: root

    property bool   isHorizontal: true
    property real   barThickness: 40
    property string barFont:      "JetBrainsMono Nerd Font"

    readonly property var player: {
        let players = Mpris.players.values
        for (let i = 0; i < players.length; i++) {
            if (players[i].playbackState === MprisPlaybackState.Playing)
                return players[i]
        }
        return players.length > 0 ? players[0] : null
    }

    readonly property bool hasPlayer:      player !== null
    readonly property bool isPlaying:      player && player.playbackState === MprisPlaybackState.Playing
    readonly property real buttonSize:     barThickness / 1.65

    implicitWidth:  hasPlayer ? (isHorizontal ? titlePill.implicitWidth : barThickness) : 0
    implicitHeight: hasPlayer ? (isHorizontal ? barThickness : verticalControls.implicitHeight) : 0
    visible:        hasPlayer
    clip:           true

    // ── Horizontal: title pill, click to play/pause, side buttons for skip ──
    Rectangle {
        id: titlePill
        visible:          root.isHorizontal
        anchors.centerIn: parent

        readonly property real length: titleText.implicitWidth + root.buttonSize + 20
        implicitWidth: length
        width:   length
        height:  root.buttonSize
        radius:  height / 2
        color:   Colors.color3

        Text {
            id: titleText
            anchors.centerIn: parent
            text:             root.player ? (root.player.trackTitle || root.player.identity || "") : ""
            color:            "white"
            font.family:      root.barFont
            font.pixelSize:   root.buttonSize * 0.52
            font.weight:      Font.Bold
            elide:            Text.ElideRight
            maximumLineCount: 1
        }

        MouseArea {
            anchors.fill:    parent
            cursorShape:     Qt.PointingHandCursor
            acceptedButtons: Qt.LeftButton | Qt.BackButton | Qt.ForwardButton

            onClicked: (event) => {
                if (!root.player) return
                if      (event.button === Qt.BackButton)    root.player.previous()
                else if (event.button === Qt.ForwardButton) root.player.next()
                else                                        root.player.togglePlaying()
            }

            onWheel: (event) => {
                if (!root.player) return
                if (event.angleDelta.y > 0) root.player.previous()
                else                        root.player.next()
            }
        }
    }

    // ── Vertical: three stacked icon buttons ─────────────────────────────
    Column {
        id: verticalControls
        visible:          !root.isHorizontal
        anchors.centerIn: parent
        spacing:          6

        // Previous
        Rectangle {
            width: root.buttonSize; height: width; radius: width / 2
            color: prevArea.containsMouse ? "white" : Colors.color3
            Behavior on color { ColorAnimation { duration: 150 } }
            anchors.horizontalCenter: parent.horizontalCenter
            Text {
                anchors.centerIn: parent
                text:           "󰒮"
                color:          prevArea.containsMouse ? "black" : "white"
                font.family:    root.barFont
                font.pixelSize: parent.width * 0.55
            }
            MouseArea {
                id: prevArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape:  Qt.PointingHandCursor
                onClicked:    if (root.player) root.player.previous()
            }
        }

        // Play / Pause
        Rectangle {
            width: root.buttonSize; height: width; radius: width / 2
            color: playArea.containsMouse ? "white" : Colors.color3
            Behavior on color { ColorAnimation { duration: 150 } }
            anchors.horizontalCenter: parent.horizontalCenter
            Text {
                anchors.centerIn: parent
                text:           root.isPlaying ? "󰏤" : "󰐊"
                color:          playArea.containsMouse ? "black" : "white"
                font.family:    root.barFont
                font.pixelSize: parent.width * 0.65
            }
            MouseArea {
                id: playArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape:  Qt.PointingHandCursor
                onClicked:    if (root.player) root.player.togglePlaying()
                acceptedButtons: Qt.LeftButton | Qt.BackButton | Qt.ForwardButton
                onPressed: (event) => {
                    if      (event.button === Qt.BackButton)    root.player && root.player.previous()
                    else if (event.button === Qt.ForwardButton) root.player && root.player.next()
                }
            }
        }

        // Next
        Rectangle {
            width: root.buttonSize; height: width; radius: width / 2
            color: nextArea.containsMouse ? "white" : Colors.color3
            Behavior on color { ColorAnimation { duration: 150 } }
            anchors.horizontalCenter: parent.horizontalCenter
            Text {
                anchors.centerIn: parent
                text:           "󰒭"
                color:          nextArea.containsMouse ? "black" : "white"
                font.family:    root.barFont
                font.pixelSize: parent.width * 0.55
            }
            MouseArea {
                id: nextArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape:  Qt.PointingHandCursor
                onClicked:    if (root.player) root.player.next()
            }
        }
    }
}
