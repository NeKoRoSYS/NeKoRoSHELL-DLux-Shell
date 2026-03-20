// components/AnimatedElement.qml
//
// A self-contained show/hide animation wrapper.
// Wrap any content in this and toggle `show` to animate it in/out.
//
// Properties:
//   show    — true = animate in, false = animate out
//   preset  — "slide" | "scale" | "fade"
//   edge    — "top" | "bottom" | "left" | "right"
//             The edge the content slides in FROM (usually the bar side).
//             Ignored for "scale" and "fade" presets.
//
// The `isSurfaceVisible` readonly property stays true during the
// exit animation so the parent can keep the window alive until
// the animation completes, then hide it.
//
import QtQuick
import qs.global

Item {
    id: root

    property bool   show:   false
    property string preset: "slide"
    property string edge:   "top"

    readonly property bool isSurfaceVisible: container.opacity > 0.0

    readonly property bool isAnimating: opacityAnim.running || slideXAnim.running || slideYAnim.running || scaleAnim.running

    readonly property real animProgress: show ? 1.0 : 0.0

    default property alias content: container.data

    Item {
        id: container
        anchors.fill: parent

        // ── Opacity ───────────────────────────────────────────────────────
        opacity: root.show ? 1.0 : 0.0
        Behavior on opacity {
            NumberAnimation {
                id: opacityAnim
                duration: root.preset === "slide" ? Animations.slow * 0.5 : Animations.normal
                easing.type: Animations.easeInOut
            }
        }

        // ── Scale ─────────────────────────────────────────────────────────
        scale: root.preset === "scale" ? (root.show ? 1.0 : 0.95) : 1.0
        transformOrigin: {
            if (root.edge === "top")    return Item.Top
            if (root.edge === "bottom") return Item.Bottom
            if (root.edge === "left")   return Item.Left
            if (root.edge === "right")  return Item.Right
            return Item.Center
        }
        Behavior on scale {
            NumberAnimation { id: scaleAnim; duration: Animations.normal; easing.type: Animations.easeBack }
        }

        // ── Slide ─────────────────────────────────────────────────────────
        transform: Translate {
            id: slideTranslate

            readonly property real maxSlide: {
                if (root.preset !== "slide") return 0
                if (root.edge === "left" || root.edge === "right")
                    return root.width  > 0 ? root.width  : 400
                return root.height > 0 ? root.height : 400
            }
            readonly property real offset: root.show ? 0 : maxSlide

            x: root.preset !== "slide" ? 0
             : root.edge === "left"    ? -offset
             : root.edge === "right"   ?  offset : 0

            y: root.preset !== "slide" ? 0
             : root.edge === "top"     ? -offset
             : root.edge === "bottom"  ?  offset : 0

            Behavior on x { NumberAnimation { id: slideXAnim; duration: Animations.slow * 0.5; easing.type: Animations.easeOut } }
            Behavior on y { NumberAnimation { id: slideYAnim; duration: Animations.slow * 0.5; easing.type: Animations.easeOut } }
        }
    }
}