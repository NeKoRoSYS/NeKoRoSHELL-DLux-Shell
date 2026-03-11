// panels/WallpaperPicker.qml
import QtQuick
import qs.globals
import qs.components

Panel {
    id: wpPanel

    panelWidth:  800
    panelHeight: 550
    animationPreset: "slide"

    Column {
        anchors.fill: parent
        anchors.margins: 0
        spacing: 15

        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 20
            
            Text {
                text: "   Wallpapers"
                color: Colors.foreground
                font.family: "JetBrainsMono Nerd Font"
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
        }

        Rectangle { width: parent.width; height: 1; color: Colors.color8; opacity: 0.5 }

        GridView {
            width: parent.width
            height: parent.height - 60
            cellWidth:  parent.width / 4
            cellHeight: 140
            clip: true
            model: WallpaperManager.wallpapers

            delegate: Item {
                width: GridView.view.cellWidth
                height: GridView.view.cellHeight

                Rectangle {
                    anchors.fill: parent
                    anchors.margins: 8
                    radius: 8
                    color: Colors.color0
                    border.color: Config.wallpaperPath === modelData.path ? Colors.color2 : "transparent"
                    border.width: 2
                    clip: true

                    Image {
                        anchors.fill: parent
                        source: "file://" + modelData.thumb
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                        
                        onStatusChanged: {
                            if (status === Image.Error) {
                                source = "file://" + modelData.path
                            }
                        }
                    }

                    Rectangle {
                        anchors.bottom: parent.bottom
                        width: parent.width
                        height: 24
                        color: "#99000000"

                        Text {
                            anchors.centerIn: parent
                            text: modelData.name
                            color: "white"
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 10
                            elide: Text.ElideRight
                            width: parent.width - 10
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: WallpaperManager.setWallpaper(modelData.path)
                    }
                }
            }
        }
    }
}