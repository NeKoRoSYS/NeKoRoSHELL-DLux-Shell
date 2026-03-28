// panels/Launcher.qml
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.global
import qs.components
import qs.engine 

Panel {
    id: launcherPanel

    edgePadding: 15
    panelWidth:  500
    panelHeight: 520
    animationPreset: "slide"
    anchorAlignment: "center"
    keyboardFocus: WlrKeyboardFocus.Exclusive

    Rectangle {
        id: launcherRoot
        anchors.fill: parent
        color: "transparent"
        border.color: Colors.color13
        border.width: 2
        radius: 10
        clip: true

        property string searchQuery: ""
        property var allAppsRaw: [] 
        property int selectedIndex: 0

        property var builtInCommands: []
        property var userCommands:    []
        property var panelCommands:   []
        property var commandList:     []

        Component.onCompleted: {
            focusTimer.restart();
            updatePanelCommands(); 
        }

        onSearchQueryChanged: updateSearch()

        ListModel {
            id: appsModel
        }

        Process {
            id: appsProcess
            running: true
            command: ["sh", "-c", "python3 ~/.config/quickshell/scripts/get-apps.py"]
        }

        FileView {
            id: appsFile
            path: Quickshell.env("HOME") + "/.cache/nekoroshell/apps.json"
            watchChanges: true
            onFileChanged: reload()
            onLoaded: launcherRoot.parseAppsJson()
        }

        FileView {
            id: builtInCmdFile
            path: Quickshell.shellDir + "/commands.json"
            watchChanges: true
            onFileChanged: reload()
            onLoaded: {
                let content = builtInCmdFile.text();
                if (content) {
                    try {
                        let parsed = JSON.parse(content);
                        let cmds = parsed.commands || [];
                        let arr = [];
                        for(let i = 0; i < cmds.length; i++) arr.push(cmds[i]);
                        launcherRoot.builtInCommands = arr;
                        launcherRoot.updateCommandList();
                    } catch(e) { console.log("Built-in Cmd Parse Error:", e) }
                }
            }
        }

        FileView {
            id: userCmdFile
            path: Quickshell.shellDir + "/user/commands.json"
            watchChanges: true
            onFileChanged: reload()
            onLoaded: {
                let content = userCmdFile.text();
                if (content) {
                    try {
                        let parsed = JSON.parse(content);
                        let cmds = parsed.commands || [];
                        let arr = [];
                        for(let i = 0; i < cmds.length; i++) arr.push(cmds[i]);
                        launcherRoot.userCommands = arr;
                        launcherRoot.updateCommandList();
                    } catch(e) { console.log("User Cmd Parse Error:", e) }
                }
            }
        }

        Connections {
            target: PanelRegistry
            function onBuiltInPanelsChanged() { launcherRoot.updatePanelCommands(); }
            function onUserPanelsChanged()   { launcherRoot.updatePanelCommands(); }
        }

        Connections {
            target: launcherPanel
            function onShowPanelChanged() {
                if (launcherPanel.showPanel) {
                    searchInput.text = ""
                    launcherRoot.searchQuery = ""
                    launcherRoot.selectedIndex = 0
                    searchInput.forceActiveFocus()

                    focusTimer.restart()
                    
                    if (launcherRoot.allAppsRaw.length === 0) {
                        appsProcess.running = true
                    } else {
                        launcherRoot.updateSearch()
                    }
                } else {
                    searchInput.focus = false
                }
            }
        }

        Timer {
            id: focusTimer
            interval: 15
            onTriggered: searchInput.forceActiveFocus()
        }

        function parseAppsJson() {
            let content = appsFile.text();
            if (!content || content.trim().length === 0) return;
            
            try {
                let parsed = JSON.parse(content);
                if (Array.isArray(parsed)) {
                    launcherRoot.allAppsRaw = parsed;
                    launcherRoot.updateSearch();
                }
            } catch (e) {
                console.log("Launcher JSON Parse Error: ", e);
            }
        }

        function updatePanelCommands() {
            let pCmds = [];
            let builtIn = PanelRegistry.builtInPanels || [];
            for (let i = 0; i < builtIn.length; i++) {
                let pId = builtIn[i].id;
                if (pId) pCmds.push({ trigger: pId, name: "Toggle Panel", icon: "window-new", exec: "toggle:" + pId });
            }
            
            let userP = PanelRegistry.userPanels || [];
            for (let i = 0; i < userP.length; i++) {
                let pId = userP[i].id;
                if (pId) pCmds.push({ trigger: pId, name: "Toggle Panel", icon: "window-new", exec: "toggle:" + pId });
            }
            
            launcherRoot.panelCommands = pCmds;
            launcherRoot.updateCommandList();
        }

        function updateCommandList() {
            launcherRoot.commandList = [].concat(launcherRoot.panelCommands)
                                         .concat(launcherRoot.builtInCommands)
                                         .concat(launcherRoot.userCommands);
            if (launcherRoot.searchQuery.startsWith(">")) launcherRoot.updateSearch();
        }

        function fuzzyMatch(str, pattern) {
            if (!pattern) return true;
            pattern = pattern.toLowerCase().replace(/\s+/g, "")
            str = str.toLowerCase()
            let patternIdx = 0
            for (let i = 0; i < str.length && patternIdx < pattern.length; i++) {
                if (str[i] === pattern[patternIdx]) patternIdx++
            }
            return patternIdx === pattern.length
        }

        function updateSearch() {
            appsModel.clear();
            let batchedApps = [];
            
            if (launcherRoot.searchQuery.startsWith(">")) {
                let pattern = launcherRoot.searchQuery.substring(1).trim();
                let filtered = [];
                
                if (pattern === "") {
                    filtered = launcherRoot.commandList;
                } else {
                    filtered = launcherRoot.commandList.filter(cmd => 
                        launcherRoot.fuzzyMatch(cmd.trigger, pattern) || launcherRoot.fuzzyMatch(cmd.name, pattern)
                    );
                }

                batchedApps = filtered.map(cmd => ({
                    "appName": cmd.name + " (" + cmd.trigger + ")",
                    "appIcon": cmd.icon || "system-run",
                    "appExec": cmd.exec || ""
                }));
            } else {
                let filtered = [];
                if (launcherRoot.searchQuery.trim() === "") {
                    filtered = launcherRoot.allAppsRaw;
                } else {
                    filtered = launcherRoot.allAppsRaw.filter(app => launcherRoot.fuzzyMatch(app.name, launcherRoot.searchQuery));
                }

                batchedApps = filtered.map(app => ({
                    "appName": app.name,
                    "appIcon": app.icon,
                    "appExec": app.exec || ""
                }));
            }

            if (batchedApps.length > 0) {
                appsModel.append(batchedApps);
            }
            
            launcherRoot.selectedIndex = 0;
        }

        function launchSelected() {
            if (appsModel.count > 0 && launcherRoot.selectedIndex >= 0 && launcherRoot.selectedIndex < appsModel.count) {
                let item = appsModel.get(launcherRoot.selectedIndex);
                let cmd = item ? item.appExec : "";
                
                if (!cmd || cmd === "") return;

                EventBus.togglePanel("launcher", null);
                
                if (cmd.startsWith("toggle:")) {
                    let targetPanel = cmd.substring(7);
                    EventBus.togglePanel(targetPanel, null);
                } else {
                    Quickshell.execDetached({ command: ["sh", "-c", cmd] });
                }
            }
        }

        Column {
            anchors.fill: parent
            anchors.margins: 15
            spacing: 10
            
            Rectangle {
                width: parent.width
                height: 36
                color: Colors.color0
                border.color: Colors.color8
                border.width: 1
                radius: 5

                TextInput {
                    id: searchInput
                    anchors.fill: parent
                    anchors.margins: 8
                    verticalAlignment: TextInput.AlignVCenter
                    color: Colors.foreground
                    font.family: "JetBrains Mono"
                    font.pixelSize: 14
                    focus: true
                    
                    onTextEdited: launcherRoot.searchQuery = text
                    
                    Text {
                        text: "  Search apps or type > for commands"
                        color: Colors.color8
                        visible: !parent.text
                        font.family: "JetBrains Mono"
                        font.pixelSize: 14
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: appsModel.count + (launcherRoot.searchQuery.startsWith(">") ? " cmds" : " apps")
                        color: Colors.color8
                        font.family: "JetBrains Mono"
                        font.pixelSize: 12
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        visible: appsModel.count > 0
                    }
                    
                    Keys.onDownPressed: {
                        launcherRoot.selectedIndex = Math.min(launcherRoot.selectedIndex + 1, appsModel.count - 1)
                        appList.positionViewAtIndex(launcherRoot.selectedIndex, ListView.Contain)
                    }
                    Keys.onUpPressed: {
                        launcherRoot.selectedIndex = Math.max(launcherRoot.selectedIndex - 1, 0)
                        appList.positionViewAtIndex(launcherRoot.selectedIndex, ListView.Contain)
                    }
                    Keys.onReturnPressed: launcherRoot.launchSelected()
                    Keys.onEscapePressed: EventBus.togglePanel("launcher", null)
                }
            }

            Rectangle { width: parent.width; height: 1; color: Colors.color8; opacity: 0.5 }

            ListView {
                id: appList
                width: parent.width
                height: parent.height - 50 
                clip: true
                spacing: 2
                model: appsModel

                delegate: Rectangle {
                    width: appList.width
                    height: 45
                    radius: 5
                    
                    property bool isSelected: index === launcherRoot.selectedIndex
                    
                    color: isSelected ? Colors.color5 : (appMouse.containsMouse ? Colors.color13 : "transparent")
                    
                    Rectangle {
                        anchors.bottom: parent.bottom
                        width: parent.width
                        height: 2
                        color: Colors.color13
                        visible: isSelected
                    }

                    Row {
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 10
                        
                        Image {
                            width: 24; height: 24
                            source: model.appIcon ? "image://icon/" + model.appIcon : ""
                            anchors.verticalCenter: parent.verticalCenter
                            smooth: true
                        }

                        Text {
                            text: model.appName
                            color: isSelected ? "white" : appMouse.containsMouse ? "white" : Colors.foreground
                            font.family: "JetBrains Mono"
                            font.weight: isSelected ? Font.Bold : Font.Normal
                            font.pixelSize: 14
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    MouseArea {
                        id: appMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            launcherRoot.selectedIndex = index;
                            launcherRoot.launchSelected();
                        }
                    }
                }
            }
        }
    }
}