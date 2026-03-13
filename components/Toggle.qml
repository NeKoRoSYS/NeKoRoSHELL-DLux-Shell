// components/Toggle.qml
import QtQuick
import qs.global

Item {
    id: root
    
    property string labelText: "Setting"
    property bool checked: true
    
    property string toggleStyle: "slider" // slider || checkbox
    
    signal toggled(bool newState)

    implicitWidth: parent ? parent.width : 200
    implicitHeight: 30

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.toggled(!root.checked)
    }

    Text {
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        text: root.labelText
        color: Colors.foreground
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 14
        font.weight: Font.Bold
    }

    Rectangle {
        id: track
        visible: root.toggleStyle === "slider"
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        width: 44
        height: 24
        radius: height / 2
        
        color: root.checked ? Colors.color3 : Colors.color0 
        Behavior on color { ColorAnimation { duration: 150 } }

        Rectangle {
            id: thumb
            width: 15
            height: 15
            radius: 10
            anchors.verticalCenter: parent.verticalCenter
            
            x: root.checked ? track.width - width - 2 : 2
            color: "white"
            
            Behavior on x { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }

            Text {
                text: root.checked ? "|" : "O"
                anchors.centerIn: parent
            }
        }
    }

    Rectangle {
        id: checkboxTrack
        visible: root.toggleStyle === "checkbox"
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        width: 24
        height: 24
        radius: width / 2
        
        color: root.checked ? Colors.color3 : "transparent"
        border.width: root.checked ? 0 : 2
        border.color: root.checked ? "transparent" : Colors.color8
        
        Behavior on color { ColorAnimation { duration: 150 } }

        Text {
            text: "" 
            color: "white"
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 14
            anchors.centerIn: parent
            
            scale: root.checked ? 1 : 0
            opacity: root.checked ? 1 : 0
            Behavior on scale { NumberAnimation { duration: 200; easing.type: Easing.OutBack } }
            Behavior on opacity { NumberAnimation { duration: 150 } }
        }
    }
}