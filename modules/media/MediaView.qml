// modules/media/MediaView.qml
import QtQuick
import qs.global
import qs.modules.media

Item {
    id: root
    
    property bool   isHorizontal: true
    property real   barThickness: 40
    property string barFont:      "JetBrainsMono Nerd Font"
    property var    barScreen:    null // Required to prevent Engine crashes!

    readonly property real buttonSize: barThickness
    readonly property bool isActive: Media.hasPlayer

    visible:        isActive
    implicitWidth:  isActive ? (isHorizontal ? titlePill.width : barThickness) : 0
    implicitHeight: isActive ? (isHorizontal ? barThickness : verticalControls.implicitHeight) : 0
    clip:           true

    Text {
        id: titleMetrics
        text:             Media.title
        font.family:      root.barFont
        font.pixelSize:   root.buttonSize * 0.52
        font.weight:      Font.Bold
        visible:          false
    }

    // ── Horizontal: Title Pill ────────────────────────────────────────
    Rectangle {
        id: titlePill
        visible:          root.isHorizontal
        anchors.centerIn: parent

        width:   Math.min(titleMetrics.implicitWidth + root.buttonSize + 20, 250)
        height:  root.buttonSize
        radius:  height / 2
        color: titleArea.containsMouse ? "white" : Colors.color3
        Behavior on color { ColorAnimation { duration: 150 } }

        Text {
            anchors.centerIn: parent
            width:            parent.width - root.buttonSize
            horizontalAlignment: Text.AlignHCenter

            text:             Media.title
            color:            titleArea.containsMouse ? "black" : "white"
            font.family:      root.barFont
            font.pixelSize:   root.buttonSize * 0.52
            font.weight:      Font.Bold
            elide:            Text.ElideRight
            maximumLineCount: 1
        }

        MouseArea {
            id: titleArea
            hoverEnabled:    true
            anchors.fill:    parent
            cursorShape:     Qt.PointingHandCursor
            acceptedButtons: Qt.LeftButton | Qt.BackButton | Qt.ForwardButton

            onClicked: (event) => {
                if      (event.button === Qt.BackButton)    Media.prev()
                else if (event.button === Qt.ForwardButton) Media.next()
                else                                        Media.toggle()
            }

            onWheel: (event) => {
                if (event.angleDelta.y > 0) Media.prev()
                else                        Media.next()
            }
        }
    }

    // ── Vertical: Media Controls Column ───────────────────────────────
    Column {
        id: verticalControls
        visible:          !root.isHorizontal
        anchors.centerIn: parent
        spacing:          6

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
                onClicked:    Media.prev()
            }
        }

        Rectangle {
            width: root.buttonSize; height: width; radius: width / 2
            color: playArea.containsMouse ? "white" : Colors.color3
            Behavior on color { ColorAnimation { duration: 150 } }
            anchors.horizontalCenter: parent.horizontalCenter
            Text {
                anchors.centerIn: parent
                text:           Media.isPlaying ? "󰏤" : "󰐊"
                color:          playArea.containsMouse ? "black" : "white"
                font.family:    root.barFont
                font.pixelSize: parent.width * 0.65
            }
            MouseArea {
                id: playArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape:  Qt.PointingHandCursor
                onClicked:    Media.toggle()
                acceptedButtons: Qt.LeftButton | Qt.BackButton | Qt.ForwardButton
                onPressed: (event) => {
                    if      (event.button === Qt.BackButton)    Media.prev()
                    else if (event.button === Qt.ForwardButton) Media.next()
                }
            }
        }

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
                onClicked:    Media.next()
            }
        }
    }
}