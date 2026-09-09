import QtQuick
import Quickshell
import Quickshell.Io

Scope {
    id: root

    property bool active: false
    property int value: 50
    property bool ready: false
    property string error: ""
    property int pendingValue: -1
    property int inFlightValue: -1
    property int completedWrites: 0
    property bool refreshPending: false
    property bool readRequested: false
    property bool readAccepted: false

    readonly property bool busy: writeTimer.running || writer.running || pendingValue >= 0 || inFlightValue >= 0
    readonly property string backend: {
        const configured = Quickshell.env("CONTROL_CENTER_BRIGHTNESS_COMMAND");
        const home = Quickshell.env("HOME") || "";
        return configured ? configured : home + "/.local/bin/control-center-brightness";
    }

    function refresh(): void {
        if (busy || reader.running) {
            refreshPending = true;
            return;
        }

        refreshPending = false;
        readRequested = true;
        readAccepted = false;
        reader.running = true;
        readLaunchGuard.restart();
    }

    function requestValue(requested: int): int {
        const clamped = Math.max(1, Math.min(100, requested));
        value = clamped;
        pendingValue = clamped;
        if (inFlightValue < 0 && !writeTimer.running)
            flushPending();
        return clamped;
    }

    function flushPending(): void {
        if (inFlightValue >= 0 || pendingValue < 0)
            return;

        const nextValue = pendingValue;
        pendingValue = -1;
        inFlightValue = nextValue;
        writer.exec([backend, "set", String(nextValue)]);
        writeLaunchGuard.restart();
    }

    function finishRead(exitCode: int): void {
        if (!readRequested)
            return;

        readLaunchGuard.stop();
        readRequested = false;
        if (exitCode !== 0 || !readAccepted)
            error = "Unable to read brightness";
        if (refreshPending)
            Qt.callLater(refresh);
    }

    function finishWrite(exitCode: int): void {
        if (inFlightValue < 0)
            return;

        writeLaunchGuard.stop();
        if (exitCode === 0) {
            completedWrites++;
            error = "";
        } else {
            error = "Unable to set brightness";
        }

        inFlightValue = -1;
        writeTimer.restart();
    }

    onActiveChanged: {
        if (active)
            refresh();
    }

    Component.onCompleted: refresh()

    Timer {
        id: pollTimer

        interval: 1000
        repeat: true
        running: root.active
        onTriggered: root.refresh()
    }

    Timer {
        id: writeTimer

        interval: 50
        onTriggered: {
            if (root.pendingValue >= 0)
                root.flushPending();
            else
                root.refresh();
        }
    }

    Timer {
        id: readLaunchGuard

        interval: 100
        onTriggered: {
            if (root.readRequested && !reader.running)
                root.finishRead(-1);
        }
    }

    Timer {
        id: writeLaunchGuard

        interval: 100
        onTriggered: {
            if (root.inFlightValue >= 0 && !writer.running)
                root.finishWrite(-1);
        }
    }

    Process {
        id: reader

        command: [root.backend, "get"]

        stdout: StdioCollector {
            onStreamFinished: {
                const parsed = Number(text.trim());
                if (Number.isInteger(parsed) && parsed >= 0 && parsed <= 100) {
                    if (!root.busy)
                        root.value = Math.max(1, parsed);
                    root.ready = true;
                    root.readAccepted = true;
                    root.error = "";
                }
            }
        }

        onExited: function(exitCode) {
            root.finishRead(exitCode);
        }
    }

    Process {
        id: writer

        onExited: function(exitCode) {
            root.finishWrite(exitCode);
        }
    }
}
