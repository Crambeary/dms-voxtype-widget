import QtQuick
import Quickshell.Io
import qs.Common
import qs.Widgets
import qs.Modules.Plugins

// Voxtype Status Widget for DankMaterialShell
// Polls voxtype status every 500ms and displays state as a themed bar pill.
// Uses Quickshell's Process type (Quickshell.Io), not QtQuick's — DMS
// plugins run in a Quickshell context, so the QtQuick-style
// start()/onReadyReadStandardOutput API doesn't exist here.
//
// Left click opens the popout menu, right click toggles recording, middle
// click toggles the daemon.
//
// The menu is PluginComponent's own popoutContent/PopoutComponent — the
// same floating, blurred, layer-shell-positioned panel every other DMS
// plugin (e.g. DankPomodoroTimer) uses for its popout — not a hand-rolled
// QtQuick.Controls Menu. Left click gets it for free: PluginComponent
// opens popoutContent automatically on left click whenever pillClickAction
// is unset. Right click has a dedicated hook (pillRightClickAction). Middle
// click has no built-in hook at all — BasePill's own MouseArea only
// accepts Left/Right — so it's caught by a MouseArea layered inside the
// pill content, the same technique DMS's own DankActions plugin uses for
// its middle-click command.
//
// `voxtype status` reports "stopped" precisely when the daemon isn't
// running (confirmed via `voxtype status --format json`, whose "stopped"
// tooltip reads "Voxtype not running"), so that existing state doubles as
// "model unloaded" — no separate systemctl check is needed.

PluginComponent {
    id: root

    property string currentState: "stopped"
    readonly property bool daemonRunning: currentState !== "stopped"

    readonly property var stateConfig: ({
        "idle": { icon: "mic", color: Theme.success, label: "Ready to record" },
        "recording": { icon: "radio_button_checked", color: Theme.error, label: "Recording…" },
        "transcribing": { icon: "sync", color: Theme.warning, label: "Transcribing…" },
        "stopped": { icon: "mic_off", color: Theme.outline, label: "Model unloaded" }
    })

    readonly property var currentConfig: stateConfig[currentState] || stateConfig["stopped"]

    function applyState(state) {
        if (state && stateConfig[state]) {
            currentState = state;
        }
    }

    function toggleRecording() {
        if (!toggleProcess.running)
            toggleProcess.running = true;
    }

    function toggleDaemon() {
        daemonToggleProcess.command = root.daemonRunning ? ["sh", "-c", "systemctl --user stop voxtype && notify-send -a voxtype 'Voxtype' 'Model unloaded (memory freed)' -i microphone-sensitivity-muted-symbolic"] : ["sh", "-c", "systemctl --user start voxtype && notify-send -a voxtype 'Voxtype' 'Model loading…' -i microphone-sensitivity-high-symbolic"];
        daemonToggleProcess.running = true;
    }

    Timer {
        interval: 500
        running: true
        repeat: true
        onTriggered: if (!statusProcess.running)
            statusProcess.running = true
    }

    Process {
        id: statusProcess
        command: ["voxtype", "status"]
        stdout: SplitParser {
            onRead: data => root.applyState(data.trim())
        }
    }

    Process {
        id: toggleProcess
        command: ["voxtype", "record", "toggle"]
    }

    Process {
        id: cancelProcess
        command: ["voxtype", "record", "cancel"]
    }

    Process {
        id: daemonToggleProcess
        command: ["true"]
    }

    pillRightClickAction: function() {
        root.toggleRecording();
    }

    popoutWidth: 240

    popoutContent: Component {
        PopoutComponent {
            id: popout

            headerText: "Voxtype"
            detailsText: root.currentConfig.label
            showCloseButton: true

            Column {
                width: parent.width
                spacing: Theme.spacingS

                DankButton {
                    text: root.currentState === "recording" ? "Stop Recording" : "Start Recording"
                    iconName: root.currentState === "recording" ? "stop" : "mic"
                    width: parent.width
                    visible: root.currentState === "idle" || root.currentState === "recording"
                    backgroundColor: root.currentState === "recording" ? Theme.errorHover : Theme.withAlpha(Theme.success, 0.12)
                    textColor: root.currentState === "recording" ? Theme.error : Theme.success
                    onClicked: {
                        root.toggleRecording();
                        if (popout.closePopout)
                            popout.closePopout();
                    }
                }

                DankButton {
                    text: "Cancel"
                    iconName: "close"
                    width: parent.width
                    visible: root.currentState === "recording" || root.currentState === "transcribing"
                    backgroundColor: Theme.errorHover
                    textColor: Theme.error
                    onClicked: {
                        if (!cancelProcess.running)
                            cancelProcess.running = true;
                        if (popout.closePopout)
                            popout.closePopout();
                    }
                }

                DankButton {
                    text: root.daemonRunning ? "Unload Model" : "Load Model"
                    iconName: "memory"
                    width: parent.width
                    onClicked: {
                        root.toggleDaemon();
                        if (popout.closePopout)
                            popout.closePopout();
                    }
                }
            }
        }
    }

    horizontalBarPill: Component {
        Item {
            implicitWidth: icon.implicitWidth
            implicitHeight: icon.implicitHeight

            DankIcon {
                id: icon
                name: root.currentConfig.icon
                size: root.iconSize
                color: root.currentConfig.color

                SequentialAnimation on opacity {
                    running: root.currentState === "recording"
                    loops: Animation.Infinite
                    NumberAnimation { to: 0.5; duration: 500; easing.type: Easing.InOutQuad }
                    NumberAnimation { to: 1.0; duration: 500; easing.type: Easing.InOutQuad }
                }
            }

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.MiddleButton
                onClicked: function(mouse) {
                    root.toggleDaemon();
                }
            }
        }
    }

    verticalBarPill: Component {
        Item {
            implicitWidth: icon.implicitWidth
            implicitHeight: icon.implicitHeight

            DankIcon {
                id: icon
                name: root.currentConfig.icon
                size: root.iconSize
                color: root.currentConfig.color

                SequentialAnimation on opacity {
                    running: root.currentState === "recording"
                    loops: Animation.Infinite
                    NumberAnimation { to: 0.5; duration: 500; easing.type: Easing.InOutQuad }
                    NumberAnimation { to: 1.0; duration: 500; easing.type: Easing.InOutQuad }
                }
            }

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.MiddleButton
                onClicked: function(mouse) {
                    root.toggleDaemon();
                }
            }
        }
    }

    Component.onCompleted: {
        statusProcess.running = true;
    }
}
