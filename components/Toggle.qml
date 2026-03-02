// quickshell/components/Toggle.qml
import QtQuick
import qs.shared

Item {
    id: root
    
    property string labelText: "Setting"
    property bool checked: true
    
    signal toggled(bool newState)

    implicitWidth: parent ? parent.width : 200
    implicitHeight: 30

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
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        width: 44
        height: 24
        radius: height / 2
        
        color: root.checked ? Colors.color2 : Colors.color0 
        Behavior on color { ColorAnimation { duration: 150 } }

        Rectangle {
            id: thumb
            width: 20
            height: 20
            radius: 10
            anchors.verticalCenter: parent.verticalCenter
            
            x: root.checked ? track.width - width - 2 : 2
            color: Colors.background
            
            Behavior on x { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: root.toggled(!root.checked)
        }
    }
}