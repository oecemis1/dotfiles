import QtQuick
import Quickshell
import Quickshell.Io

Scope {
    id: root

    property bool pending: false
    property string error: ""

    readonly property string backend: {
        const configured = Quickshell.env("CONTROL_CENTER_POWER_COMMAND");
        const home = Quickshell.env("HOME") || "";
        return configured ? configured : home + "/.local/bin/control-center-power";
    }
    readonly property bool busy: pending || action.running

    function execute(actionName: string): bool {
        if (busy || (actionName !== "suspend" && actionName !== "hibernate" && actionName !== "poweroff"))
            return false;

        pending = true;
        error = "";
        action.exec([backend, actionName]);
        launchGuard.restart();
        actionTimeout.restart();
        return true;
    }

    function finish(exitCode: int): void {
        if (!pending)
            return;

        launchGuard.stop();
        actionTimeout.stop();
        pending = false;
        if (exitCode !== 0)
            error = "Power action failed";
    }

    Process {
        id: action

        onExited: function(exitCode) {
            root.finish(exitCode);
        }
    }

    Timer {
        id: launchGuard

        interval: 100
        onTriggered: {
            if (root.pending && !action.running)
                root.finish(-1);
        }
    }

    Timer {
        id: actionTimeout
        interval: 130000
        onTriggered: {
            if (root.pending && action.running)
                action.signal(9);
        }
    }
}
