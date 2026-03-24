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

            // --- Header: Current Month/Year ---
            Text {
                text: Qt.formatDateTime(new Date(), "MMMM yyyy")
                color: Colors.primary
                font.pixelSize: 22
                font.family: "JetBrainsMono Nerd Font"
                font.bold: true
                anchors.horizontalCenter: parent.horizontalCenter
            }

            // --- Day Names Row ---
            DayOfWeekRow {
                width: parent.width
                locale: grid.locale
                delegate: Text {
                    text: model.shortName
                    color: Colors.fg_dim
                    font.pixelSize: 12
                    horizontalAlignment: Text.AlignHCenter
                }
            }

            // --- The Calendar Grid ---
            MonthGrid {
                id: grid
                width: parent.width
                height: 300
                
                delegate: Rectangle {
                    implicitWidth: 42
                    implicitHeight: 42
                    radius: 21
                    color: model.today ? Colors.primary : "transparent"
                    border.color: model.selected ? Colors.accent : "transparent"
                    border.width: 2

                    Text {
                        anchors.centerIn: parent
                        text: model.day
                        font.pixelSize: 14
                        color: model.today ? Colors.background : 
                               (model.month === grid.month ? Colors.foreground : Colors.fg_dim)
                    }
                }
            }
        }
    }
}