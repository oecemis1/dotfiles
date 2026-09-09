import QtQuick
import Quickshell
import Quickshell.Io

Scope {
    id: root

    property bool active: false
    property bool ready: false
    property bool actionPending: false
    property var devices: []
    property string error: ""

    readonly property string backend: {
        const configured = Quickshell.env("CONTROL_CENTER_USB_COMMAND");
        const home = Quickshell.env("HOME") || "";
        return configured ? configured : home + "/.local/bin/control-center-usb";
    }
    readonly property bool busy: actionPending || action.running

    function refresh(): void {
        if (!reader.running) {
            reader.running = true;
            readerTimeout.restart();
        }
    }

    function parseDevices(text: string): void {
        try {
            const parsed = JSON.parse(text);
            if (!Array.isArray(parsed))
                throw new Error("not an array");
            const normalized = [];
            for (const item of parsed) {
                if (!item || typeof item.path !== "string" || typeof item.label !== "string"
                        || typeof item.id !== "string" || typeof item.drive !== "string"
                        || typeof item.mounted !== "boolean")
                    throw new Error("invalid device");
                normalized.push({
                    path: item.path,
                    id: item.id,
                    drive: item.drive,
                    label: item.label,
                    size: typeof item.size === "string" ? item.size : "",
                    mounted: item.mounted,
                    mountpoint: typeof item.mountpoint === "string" ? item.mountpoint : "",
                    free: typeof item.free === "string" ? item.free : ""
                });
            }
            devices = normalized;
            ready = true;
            error = "";
        } catch (parseError) {
            ready = false;
            devices = [];
            error = "Unable to read removable media";
        }
    }

    function hasDevice(path: string): bool {
        return devices.some(device => device.path === path);
    }

    function run(actionName: string, path: string): bool {
        if (busy || !ready || reader.running || (actionName !== "manage" && !hasDevice(path)))
            return false;
        if (actionName !== "mount" && actionName !== "unmount" && actionName !== "eject"
                && actionName !== "browse" && actionName !== "manage")
            return false;

        actionPending = true;
        ready = false;
        error = "";
        const device = devices.find(candidate => candidate.path === path);
        action.exec(actionName === "manage" ? [backend, actionName]
            : [backend, actionName, path, device.id]);
        launchGuard.restart();
        actionTimeout.restart();
        return true;
    }

    function finishAction(exitCode: int): void {
        if (!actionPending)
            return;
        launchGuard.stop();
        actionTimeout.stop();
        actionPending = false;
        if (exitCode !== 0)
            error = "Removable-media action failed";
        refresh();
    }

    onActiveChanged: {
        if (active)
            refresh();
    }

    Component.onCompleted: refresh()

    Process {
        id: reader
        command: [root.backend, "list"]
        stdout: StdioCollector {
            onStreamFinished: root.parseDevices(text)
        }
        onExited: function(exitCode) {
            readerTimeout.stop();
            if (exitCode !== 0) {
                root.ready = false;
                root.devices = [];
                root.error = "Unable to read removable media";
            }
        }
    }

    Process {
        id: action
        onExited: function(exitCode) { root.finishAction(exitCode); }
    }

    Timer {
        interval: 2000
        repeat: true
        running: root.active
        onTriggered: root.refresh()
    }

    Timer {
        id: readerTimeout
        interval: 6000
        onTriggered: {
            if (reader.running) {
                root.ready = false;
                root.devices = [];
                reader.signal(9);
            }
        }
    }

    Timer {
        id: launchGuard
        interval: 100
        onTriggered: {
            if (root.actionPending && !action.running)
                root.finishAction(-1);
        }
    }

    Timer {
        id: actionTimeout
        interval: 100000
        onTriggered: {
            if (root.actionPending && action.running)
                action.signal(9);
        }
    }
}
