import QtQuick
import Quickshell
import Quickshell.Io

Scope {
    id: root

    property bool ready: false
    property bool enabled: false
    property bool actionPending: false
    property bool previousValue: false
    property int stateGeneration: 0
    property int actionGeneration: 0
    property bool subscriberPending: false
    property int pendingState: -1
    property bool verificationPending: false
    property bool verificationAccepted: false
    property bool verificationValue: false
    property string error: ""

    readonly property string backend: {
        const configured = Quickshell.env("CONTROL_CENTER_SWAYNC_COMMAND");
        return configured ? configured : "swaync-client";
    }
    readonly property bool busy: actionPending || action.running

    function updateState(data: string): void {
        try {
            const event = JSON.parse(data);
            if (typeof event.dnd !== "boolean")
                return;
            pendingState = event.dnd ? 1 : 0;
            verifyState();
        } catch (parseError) {
            error = "Unable to parse DND state";
        }
    }

    function verifyState(): void {
        if (verificationPending || verifier.running || pendingState < 0)
            return;

        pendingState = -1;
        verificationPending = true;
        verificationAccepted = false;
        verifier.exec([backend, "--skip-wait", "--get-dnd"]);
        verificationLaunchGuard.restart();
        verificationTimeout.restart();
    }

    function finishVerification(exitCode: int): void {
        if (!verificationPending)
            return;

        verificationLaunchGuard.stop();
        verificationTimeout.stop();
        verificationPending = false;
        if (exitCode === 0 && verificationAccepted) {
            stateGeneration++;
            enabled = verificationValue;
            ready = true;
            error = "";
        } else {
            ready = false;
            error = "Unable to verify DND state";
            if (subscriber.running)
                subscriber.signal(15);
            else
                restartTimer.restart();
        }

        if (pendingState >= 0)
            Qt.callLater(verifyState);
    }

    function toggle(): bool {
        if (!ready || busy)
            return false;

        previousValue = enabled;
        actionGeneration = stateGeneration;
        enabled = !enabled;
        actionPending = true;
        action.exec([backend, "--skip-wait", "--toggle-dnd"]);
        actionLaunchGuard.restart();
        actionTimeout.restart();
        return true;
    }

    function finishAction(exitCode: int): void {
        if (!actionPending)
            return;

        actionLaunchGuard.stop();
        actionTimeout.stop();
        actionKillGuard.stop();
        actionPending = false;
        if (exitCode !== 0) {
            if (stateGeneration === actionGeneration)
                enabled = previousValue;
            ready = false;
            error = "Unable to toggle DND";
            if (subscriber.running)
                subscriber.signal(15);
            else
                restartTimer.restart();
        }
    }

    function startSubscriber(): void {
        if (subscriber.running || subscriberPending)
            return;

        subscriberPending = true;
        subscriber.running = true;
        subscriberLaunchGuard.restart();
    }

    Component.onCompleted: startSubscriber()

    Process {
        id: subscriber

        command: [root.backend, "--skip-wait", "--subscribe"]

        stdout: SplitParser {
            onRead: data => root.updateState(data)
        }

        onStarted: {
            root.subscriberPending = false;
            subscriberLaunchGuard.stop();
        }

        onExited: function(exitCode) {
            root.subscriberPending = false;
            subscriberLaunchGuard.stop();
            root.ready = false;
            root.error = "DND event stream stopped";
            restartTimer.restart();
        }
    }

    Process {
        id: action

        onExited: function(exitCode) {
            root.finishAction(exitCode);
        }
    }

    Process {
        id: verifier

        stdout: StdioCollector {
            onStreamFinished: {
                const state = text.trim();
                if (state === "true" || state === "false") {
                    root.verificationValue = state === "true";
                    root.verificationAccepted = true;
                }
            }
        }

        onExited: function(exitCode) {
            root.finishVerification(exitCode);
        }
    }

    Timer {
        id: restartTimer

        interval: 1000
        onTriggered: root.startSubscriber()
    }

    Timer {
        id: actionLaunchGuard

        interval: 100
        onTriggered: {
            if (root.actionPending && !action.running)
                root.finishAction(-1);
        }
    }

    Timer {
        id: subscriberLaunchGuard

        interval: 100
        onTriggered: {
            if (root.subscriberPending && !subscriber.running) {
                root.subscriberPending = false;
                root.ready = false;
                root.error = "Unable to start DND event stream";
                restartTimer.restart();
            }
        }
    }

    Timer {
        id: actionTimeout

        interval: 2000
        onTriggered: {
            if (root.actionPending && action.running) {
                action.signal(15);
                actionKillGuard.restart();
            }
        }
    }

    Timer {
        id: verificationLaunchGuard

        interval: 100
        onTriggered: {
            if (root.verificationPending && !verifier.running)
                root.finishVerification(-1);
        }
    }

    Timer {
        id: verificationTimeout

        interval: 1000
        onTriggered: {
            if (root.verificationPending && verifier.running)
                verifier.signal(9);
        }
    }

    Timer {
        id: actionKillGuard

        interval: 250
        onTriggered: {
            if (root.actionPending && action.running)
                action.signal(9);
        }
    }
}
