// components/WorkspaceDot.qml
import QtQuick
import qs.global

Item {
    id: root
    
    property bool showDot: false
    property bool isFocused: false
    
    property real baseSize: 0     
    property string barFont: ""   
    
    property alias dotText: txt.text
    property alias labelFont: txt.font
    property alias area: ma
    
    property real textOffsetX: 0
    property real textOffsetY: 0

    property var appData: null

    signal switchRequested()

    implicitWidth:  showDot ? baseSize : 0
    implicitHeight: showDot ? baseSize : 0
    width: implicitWidth; height: implicitHeight

    opacity: showDot ? 1 : 0
    scale:   showDot ? 1 : 0.01

    Behavior on opacity { NumberAnimation { duration: Animations.normal; easing.type: Animations.easeOut } }
    Behavior on scale   { NumberAnimation { duration: Animations.normal; easing.type: Animations.easeOut } }
    
    visible: showDot

    Timer {
        id: hoverTimer
        interval: 350
        onTriggered: {
            if (root.showDot && root.appData) {
                EventBus.showAppPreview(root.appData)
            }
        }
    }

    Timer {
        id: dragSwitchTimer
        interval: 200 
        onTriggered: {
            root.switchRequested();
        }
    }

    Rectangle {
        anchors.centerIn: parent
        height: parent.height; width: height; radius: height / 2
        
        color: ma.containsMouse || isFocused ? "white" : (Config.transparentNavbar ? Colors.background : Colors.color3)
        Behavior on color { ColorAnimation { duration: 150 } }

        Text {
            id: txt
            anchors.centerIn: parent
            anchors.horizontalCenterOffset: textOffsetX
            anchors.verticalCenterOffset: textOffsetY
            
            color: ma.containsMouse || isFocused ? "black" : (Config.lightMode && Config.transparentNavbar ? "black" : "white")
            Behavior on color { ColorAnimation { duration: 150 } }
            font.family: root.barFont
        }

        MouseArea {
            id: ma
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            hoverEnabled: true

            onClicked: {
                hoverTimer.stop()
                if (root.appData) EventBus.hideAppPreview()
                
                root.switchRequested() 
            }

            onContainsMouseChanged: {
                if (containsMouse) {
                    hoverTimer.start()
                } else {
                    hoverTimer.stop()
                    if (root.appData) EventBus.hideAppPreview()
                }
            }
        }
    }

    DropArea {
        id: dropArea
        anchors.fill: parent
        z: 999 
        keys: ["*"]
        
        onEntered: function(dragEvent) {
            dragEvent.accept();
            
            hoverTimer.stop();
            if (root.appData) EventBus.hideAppPreview();
            
            dragSwitchTimer.start();
        }
        
        onPositionChanged: function(dragEvent) {
            dragEvent.accept();
        }
        
        onExited: {
            dragSwitchTimer.stop();
        }
        
        onDropped: function(dragEvent) {
            dragEvent.accept();
            dragSwitchTimer.stop();
            root.switchRequested(); 
        }
    }
}