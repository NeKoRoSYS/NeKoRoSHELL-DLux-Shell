import QtQuick
import QtQuick.Controls
import Quickshell
import qs.global
import qs.components

Panel {
    id: calendarPanel
    
    panelWidth:  360
    panelHeight: 420
    animationPreset: "slide"

    panelContent: Component {
        Column {
            anchors.fill: parent
            spacing: 15

            Text {
                text: Qt.formatDateTime(new Date(), "MMMM yyyy")
                color: Colors.foreground
                font.pixelSize: 22
                font.bold: true
                anchors.horizontalCenter: parent.horizontalCenter
            }

            DayOfWeekRow {
                width: parent.width
                locale: grid.locale
                delegate: Text {
                    text: model.shortName
                    color: Colors.foreground
                    font.pixelSize: 12
                    horizontalAlignment: Text.AlignHCenter
                }
            }

            MonthGrid {
                id: grid
                width: parent.width
                height: 300
                
                delegate: Rectangle {
                    implicitWidth: 42
                    implicitHeight: 42
                    radius: 21
                    color: model.today ? Colors.color3 : "transparent"
                    border.color: model.selected ? Colors.color13 : "transparent"
                    border.width: 2

                    Text {
                        anchors.centerIn: parent
                        text: model.day
                        font.pixelSize: 14
                        color: model.today ? Colors.background : (model.month === grid.month ? Colors.color5 : Colors.color13)
                    }
                }
            }
        }
    }
}