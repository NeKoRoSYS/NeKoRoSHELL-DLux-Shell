// components/AnimatedElement.qml
import QtQuick
import qs.globals

Item {
    id: root

    property bool   show:   false
    property string preset: "slide"  // "slide" | "scale" | "fade"
    property string edge:   "top"

    property bool isSurfaceVisible: false

    default property alias content: container.data

    onShowChanged: { if (show) isSurfaceVisible = true }

    Item {
        id: container
        anchors.fill: parent

        opacity: root.show ? 1.0 : 0.0
        scale:   root.preset === "scale" ? (root.show ? 1.0 : 0.95) : 1.0

        transformOrigin: {
            if (root.edge === "top")    return Item.Top
            if (root.edge === "bottom") return Item.Bottom
            if (root.edge === "left")   return Item.Left
            if (root.edge === "right")  return Item.Right
            return Item.Center
        }

        transform: Translate {
            property int slideOffset: 1080
            x: {
                if (root.preset !== "slide") return 0
                if (root.edge === "left")  return root.show ? 0 : -slideOffset
                if (root.edge === "right") return root.show ? 0 :  slideOffset
                return 0
            }
            y: {
                if (root.preset !== "slide") return 0
                if (root.edge === "top")    return root.show ? 0 : -slideOffset
                if (root.edge === "bottom") return root.show ? 0 :  slideOffset
                return 0
            }
            Behavior on x { NumberAnimation { duration: Animations.slow;   easing.type: Animations.easeOut } }
            Behavior on y { NumberAnimation { duration: Animations.slow;   easing.type: Animations.easeOut } }
        }

        Behavior on scale { NumberAnimation { duration: Animations.normal; easing.type: Animations.easeBack } }

        Behavior on opacity {
            SequentialAnimation {
                NumberAnimation { duration: Animations.normal * 0.8; easing.type: Animations.easeInOut }
                ScriptAction {
                    script: { if (!root.show) root.isSurfaceVisible = false }
                }
            }
        }
    }
}
