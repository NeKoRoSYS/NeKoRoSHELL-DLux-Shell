// engine/ModuleRegistry.qml
pragma Singleton

import QtQuick
import Quickshell
import qs.global
import qs.components
import qs.modules.audio
import qs.modules.bluetooth
import qs.modules.cava
import qs.modules.clock
import qs.modules.cliphist
import qs.modules.idleinhibitor
import qs.modules.media
import qs.modules.network
import qs.modules.power
import qs.modules.notifications
import qs.modules.settings
import qs.modules.tray
import qs.modules.status
import qs.modules.systeminfo
import qs.modules.workspaces
import qs.modules.start

QtObject {
    id: root

    property Component sandboxDelegate: Component {
        ModuleLoader {
        }
    }

    // ── Navbar resolve ────────────────────────────────────────────────────
    readonly property var _map: ({
        // Dynamic
        "audio":         audioDynamic,
        "network":       networkDynamic,
        "status":        statusDynamic,  "battery":  statusDynamic,  "backlight": statusDynamic,
        "systeminfo":    sysinfoDynamic, "cpu":      sysinfoDynamic, "memory":    sysinfoDynamic,
        // Static
        "cliphist":      cliphistStatic,
        "idleinhibitor": idleinhibitorStatic,
        "power":         powerStatic,
        "settings":      settingsStatic,
        "notifications": notificationsStatic,
        "tray":          trayStatic,
        "start":         startStatic,
        // Custom
        "cava":          cavaView,
        "clock":         clockView,
        "media":         mediaView,
        "workspaces":    workspacesView,
    })

    // ── Dashboard resolve ─────────────────────────────────────────────────
    readonly property var _widgetMap: ({
        "stats":         statsWidget,
        "updates":       updatesWidget,
        "speaker":       speakerWidget,
        "mic":           micWidget,
        "brightness":    brightnessWidget,
        "network":       networkWidget,
        "bluetooth":     bluetoothWidget,
        "idleinhibitor": idleWidget,
        "cliphist":      cliphistWidget,
        "power":         powerWidget,
        "settings":      settingsWidget,
    })
    
    property var _customCache: ({})

    function resolve(name) {
        if (name && name.startsWith("custom:")) {
            if (_customCache[name]) return _customCache[name];
            
            let loaderPath = "file://" + Quickshell.env("HOME") + "/.config/quickshell/components/ModuleLoader.qml";
            
            let qmlString = `
                import QtQuick
                Item {
                    property Component comp: Component {
                        Loader {
                            id: wrapper
                            source: "${loaderPath}"
                            
                            // 1. Catch properties from SlotLayout
                            property string moduleName: "${name}"
                            property bool   isHorizontal: true
                            property real   barThickness: 0
                            property var    barScreen: null

                            // 2. Forward dimensions up to SlotLayout
                            width:  item ? item.implicitWidth  : 0
                            height: item ? item.implicitHeight : 0

                            // 3. Forward properties down into your custom widget
                            Binding { target: wrapper.item; property: "moduleName";   value: wrapper.moduleName;   when: wrapper.status === Loader.Ready }
                            Binding { target: wrapper.item; property: "isHorizontal"; value: wrapper.isHorizontal; when: wrapper.status === Loader.Ready }
                            Binding { target: wrapper.item; property: "barThickness"; value: wrapper.barThickness; when: wrapper.status === Loader.Ready }
                            Binding { target: wrapper.item; property: "barScreen";    value: wrapper.barScreen;    when: wrapper.status === Loader.Ready }
                        }
                    }
                }
            `;
            let factory = Qt.createQmlObject(qmlString, root, "dyn_factory_" + name);
            let comp = factory.comp;
            
            _customCache[name] = comp;
            return comp;
        }

        let c = _map[name] || _widgetMap[name];
        if (!c) console.warn("ModuleRegistry: unknown module '" + name + "'");
        return c ?? null;
    }

    function resolveWidget(id) {
        if (id && id.startsWith("custom:")) {
            let parsed = id.substring(7);
            if (_customCache["widget_" + parsed]) return _customCache["widget_" + parsed];
            
            let path = "file://" + Quickshell.env("HOME") + "/.config/quickshell/user/modules/" + parsed + "/" + parsed + "Widget.qml";
            let comp = Qt.createComponent(path);
            
            if (comp.status === Component.Error) {
                console.warn("Error loading widget:", comp.errorString());
            }
            
            _customCache["widget_" + parsed] = comp;
            return comp;
        }
        
        let c = _widgetMap[id] || _map[id];
        if (!c) console.warn("ModuleRegistry: unknown widget '" + id + "'");
        return c ?? null;
    }

    // ── Navbar: Dynamic ───────────────────────────────────────────────────
    property Component audioDynamic:    Component { DynamicChip { items: Audio.items } }
    property Component networkDynamic:  Component { DynamicChip { items: Network.items } }
    property Component statusDynamic:   Component { DynamicChip { items: Status.items } }
    property Component sysinfoDynamic:  Component { DynamicChip { items: SystemInfo.items } }

    // ── Navbar: Static ────────────────────────────────────────────────────
    property Component cliphistStatic:      Component { StaticChip { item: ClipHist.item } }
    property Component idleinhibitorStatic: Component { StaticChip { item: IdleInhibitor.item } }
    property Component powerStatic:         Component { StaticChip { item: Power.item } }
    property Component settingsStatic:      Component { StaticChip { item: Settings.item } }
    property Component notificationsStatic: Component { StaticChip { item: Notifications.item } }
    property Component trayStatic:          Component { StaticChip { item: Tray.item } }
    property Component startStatic:         Component { StaticChip { item: StartMenu.item } }

    // ── Navbar: Custom ────────────────────────────────────────────────────
    property Component cavaView:       Component { CavaView {} }
    property Component clockView:      Component { ClockView {} }
    property Component mediaView:      Component { MediaView {} }
    property Component workspacesView: Component { WorkspacesView {} }

    // ── Dashboard: Stats ──────────────────────────────────────────────────
    property Component statsWidget: Component {
        Column {
            Item {
                width: parent.width; height: parent.height / 2
                Column { anchors.centerIn: parent; spacing: 4
                    Text { anchors.horizontalCenter: parent.horizontalCenter; text: "󰍛"; color: Colors.color7; font.family: Style.barFont; font.pixelSize: 18 }
                    Text { anchors.horizontalCenter: parent.horizontalCenter; text: SystemInfo.cpuPercent + "%"; color: Colors.foreground; font.family: Style.barFont; font.pixelSize: 12; font.weight: Font.Bold }
                    Text { anchors.horizontalCenter: parent.horizontalCenter; text: "CPU"; color: Colors.color8; font.family: Style.barFont; font.pixelSize: 9 }
                }
            }
            Rectangle { width: parent.width; height: 1; color: Colors.color8; opacity: 0.2 }
            Item {
                width: parent.width; height: parent.height / 2 - 1
                Column { anchors.centerIn: parent; spacing: 4
                    Text { anchors.horizontalCenter: parent.horizontalCenter; text: "󰾆"; color: Colors.color7; font.family: Style.barFont; font.pixelSize: 18 }
                    Text { anchors.horizontalCenter: parent.horizontalCenter; text: SystemInfo.memPercent + "%"; color: Colors.foreground; font.family: Style.barFont; font.pixelSize: 12; font.weight: Font.Bold }
                    Text { anchors.horizontalCenter: parent.horizontalCenter; text: "RAM"; color: Colors.color8; font.family: Style.barFont; font.pixelSize: 9 }
                }
            }
        }
    }

    // ── Dashboard: Updates ────────────────────────────────────────────────
    property Component updatesWidget: Component {
        Item {
            Text {
                id: updIcon
                anchors.left:           parent.left
                anchors.leftMargin:     16
                anchors.verticalCenter: parent.verticalCenter
                text: "󰚰"; color: Updates.hasUpdates ? Colors.color3 : Colors.color7; font.family: Style.barFont; font.pixelSize: 32
            }
            Column {
                anchors.left:           updIcon.right
                anchors.leftMargin:     14
                anchors.right:          parent.right
                anchors.rightMargin:    16
                anchors.verticalCenter: parent.verticalCenter
                spacing: 4
                Text { width: parent.width; text: Updates.hasUpdates ? Updates.updateCount + " updates" : "Up to date"; color: Colors.foreground; font.family: Style.barFont; font.pixelSize: 13; font.weight: Font.Bold; elide: Text.ElideRight }
                Text { width: parent.width; text: Updates.hasUpdates ? "Tap to update" : "Packages at Latest"; color: Colors.color8; font.family: Style.barFont; font.pixelSize: 10; elide: Text.ElideRight }
            }
            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; enabled: Updates.hasUpdates; onClicked: Updates.update() }
        }
    }

    // ── Dashboard: Speaker ────────────────────────────────────────────────
    property Component speakerWidget: Component {
        Rectangle {
            color: "transparent"; radius: 12; clip: true
            Rectangle {
                anchors.bottom: parent.bottom; anchors.left: parent.left; anchors.right: parent.right
                height: Math.min(parent.height, parent.height * Math.max(0, Math.min(1, Audio.sinkVolume / 100)) + radius)
                radius: 12; color: Colors.color13; opacity: 0.5
                Behavior on height { NumberAnimation { duration: 80 } }
            }
            Column {
                anchors.bottom: parent.bottom; anchors.horizontalCenter: parent.horizontalCenter; anchors.bottomMargin: 12
                spacing: 4
                Text { anchors.horizontalCenter: parent.horizontalCenter; text: Audio.sinkMuted ? "Muted" : Audio.sinkVolume + "%"; color: Colors.foreground; font.family: Style.barFont; font.pixelSize: 11; font.weight: Font.Bold }
                Text { anchors.horizontalCenter: parent.horizontalCenter; text: Audio.speakerIcon; color: Audio.sinkMuted ? Colors.color1 : Colors.foreground; font.family: Style.barFont; font.pixelSize: 20 }
            }
            MouseArea {
                anchors.fill: parent; acceptedButtons: Qt.LeftButton | Qt.RightButton; cursorShape: Qt.PointingHandCursor; preventStealing: true
                onClicked: (e) => { if (e.button === Qt.RightButton) Audio.muteSink() }
                onMouseYChanged: { if (pressed) Audio.setSinkVolume(Math.round(Math.max(0, Math.min(1, 1 - mouseY / (height - 12))) * 100)) }
            }
        }
    }

    // ── Dashboard: Mic ────────────────────────────────────────────────────
    property Component micWidget: Component {
        Rectangle {
            color: "transparent"; radius: 12; clip: true
            Rectangle {
                anchors.bottom: parent.bottom; anchors.left: parent.left; anchors.right: parent.right
                height: Math.min(parent.height, parent.height * Math.max(0, Math.min(1, Audio.srcVolume / 100)) + radius)
                radius: 12; color: Colors.color13; opacity: 0.5
                Behavior on height { NumberAnimation { duration: 80 } }
            }
            Column {
                anchors.bottom: parent.bottom; anchors.horizontalCenter: parent.horizontalCenter; anchors.bottomMargin: 12
                spacing: 4
                Text { anchors.horizontalCenter: parent.horizontalCenter; text: Audio.srcMuted ? "Muted" : Audio.srcVolume + "%"; color: Colors.foreground; font.family: Style.barFont; font.pixelSize: 11; font.weight: Font.Bold }
                Text { anchors.horizontalCenter: parent.horizontalCenter; text: Audio.micIcon; color: Audio.srcMuted ? Colors.color1 : Colors.foreground; font.family: Style.barFont; font.pixelSize: 20 }
            }
            MouseArea {
                anchors.fill: parent; acceptedButtons: Qt.LeftButton | Qt.RightButton; cursorShape: Qt.PointingHandCursor; preventStealing: true
                onClicked: (e) => { if (e.button === Qt.RightButton) Audio.muteSrc() }
                onMouseYChanged: { if (pressed) Audio.setSrcVolume(Math.round(Math.max(0, Math.min(1, 1 - mouseY / (height - 12))) * 100)) }
            }
        }
    }

    // ── Dashboard: Brightness ─────────────────────────────────────────────
    property Component brightnessWidget: Component {
        Rectangle {
            color: "transparent"; radius: 12; clip: true; visible: Status.hasBacklight
            Rectangle {
                anchors.bottom: parent.bottom; anchors.left: parent.left; anchors.right: parent.right
                height: Math.min(parent.height, parent.height * Math.max(0, Math.min(1, Status.blPercent / 100)) + radius)
                radius: 12; color: Colors.color13; opacity: 0.5
                Behavior on height { NumberAnimation { duration: 80 } }
            }
            Column {
                anchors.bottom: parent.bottom; anchors.horizontalCenter: parent.horizontalCenter; anchors.bottomMargin: 12
                spacing: 4
                Text { anchors.horizontalCenter: parent.horizontalCenter; text: Status.blPercent + "%"; color: Colors.foreground; font.family: Style.barFont; font.pixelSize: 11; font.weight: Font.Bold }
                Text { anchors.horizontalCenter: parent.horizontalCenter; text: Status.blIcon; color: Colors.foreground; font.family: Style.barFont; font.pixelSize: 20 }
            }
            MouseArea {
                anchors.fill: parent; cursorShape: Qt.PointingHandCursor; preventStealing: true
                onMouseYChanged: { if (pressed) Status.setBacklight(Math.round(Math.max(0, Math.min(1, 1 - mouseY / (height - 12))) * Status.blMax)) }
            }
        }
    }

    // ── Dashboard: Toggle widgets ─────────────────────────────────────────
    property Component networkWidget:    Component { CCToggle { icon: Network.wifiEnabled ? (Network.connected ? "󰤨" : "󰤮") : "󰤭"; label: "Wi-Fi";     active: Network.wifiEnabled;  onTap: Network.toggleWifi();  onRightTap: Network.openApplet() } }
    property Component bluetoothWidget:  Component { CCToggle { icon: Bluetooth.icon;                                                 label: "Bluetooth"; active: Bluetooth.enabled;    onTap: Bluetooth.toggle();    onRightTap: Bluetooth.openSettings() } }
    property Component idleWidget:       Component { CCToggle { icon: IdleInhibitor.icon; label: IdleInhibitor.inhibited ? "Awake" : "Sleep"; active: IdleInhibitor.inhibited; onTap: IdleInhibitor.toggle() } }
    property Component cliphistWidget:   Component { CCToggle { icon: "󱘔"; label: "Clipboard"; onTap: EventBus.togglePanel("clipboard", null) } }
    property Component powerWidget:      Component { CCToggle { icon: "⏻";  label: "Power";     onTap: Power.open() } }
    property Component settingsWidget:   Component { CCToggle { icon: "";  label: "Settings";  onTap: EventBus.togglePanel("settings", null) } }
}
