import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io

// Voxtype Status Widget for DankMaterialShell
// Polls voxtype status every 500ms and displays state with icons.
// Uses Quickshell's Process type (Quickshell.Io), not QtQuick's — DMS
// plugins run in a Quickshell context, so the QtQuick-style
// start()/onReadyReadStandardOutput API doesn't exist here.
// Icon codepoints are built with String.fromCharCode to avoid embedding
// raw Private-Use-Area glyphs directly in the source file.

Item {
    id: voxtypeWidget
    implicitWidth: statusText.implicitWidth + 16
    implicitHeight: 32

    property string currentState: "stopped"
    property string statusIcon: String.fromCharCode(0xf131) // mic-slash (stopped)
    property color statusColor: "#6272a4"

    readonly property var stateConfig: ({
        "idle": { icon: String.fromCharCode(0xf130), color: "#50fa7b" },         // mic (green)
        "recording": { icon: String.fromCharCode(0xf111), color: "#ff5555" },    // dot (red)
        "transcribing": { icon: String.fromCharCode(0xf110), color: "#f1fa8c" }, // spinner (yellow)
        "stopped": { icon: String.fromCharCode(0xf131), color: "#6272a4" }       // mic-slash (gray)
    })

    function applyState(state) {
        if (state && state !== currentState) {
            currentState = state;
            var config = stateConfig[state] || stateConfig["stopped"];
            statusIcon = config.icon;
            statusColor = config.color;
        }
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
            onRead: data => voxtypeWidget.applyState(data.trim())
        }
    }

    Process {
        id: toggleProcess
        command: ["voxtype", "record", "toggle"]
    }

    RowLayout {
        anchors.fill: parent
        spacing: 4

        Text {
            id: statusText
            text: statusIcon
            font.family: "Symbols Nerd Font"
            font.pixelSize: 14
            color: statusColor
            // Layout.alignment: Qt.AlignVCenter
            anchors.centerIn: parent
            anchors.verticalCenterOffset: 3

            // Pulse animation for recording state
            SequentialAnimation on opacity {
                running: currentState === "recording"
                loops: Animation.Infinite
                NumberAnimation { to: 0.5; duration: 500; easing.type: Easing.InOutQuad }
                NumberAnimation { to: 1.0; duration: 500; easing.type: Easing.InOutQuad }
            }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        onClicked: if (!toggleProcess.running)
            toggleProcess.running = true

        ToolTip {
            visible: mouseArea.containsMouse
            text: {
                switch (voxtypeWidget.currentState) {
                    case "recording": return "Recording... (click to stop)";
                    case "transcribing": return "Transcribing...";
                    case "idle": return "Voxtype ready (click to record)";
                    default: return "Voxtype not running";
                }
            }
        }
    }

    Component.onCompleted: {
        statusProcess.running = true;
    }
}
