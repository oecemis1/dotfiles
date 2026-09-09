import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Networking

Scope {
    id: root

    enum Disposition { Rejected, Started, PasswordRequired, EditorRequired }

    property var networking: Networking
    property bool menuActive: false
    property var pendingNetwork: null
    property bool passwordAttempt: false
    property bool cancelRequested: false
    property string error: ""
    property string ipAddress: ""
    property string ipRequestNetwork: ""
    property bool ipRefreshPending: false

    readonly property string ipBackend: {
        const configured = Quickshell.env("CONTROL_CENTER_IP_COMMAND");
        const home = Quickshell.env("HOME") || "";
        return configured ? configured : home + "/.local/bin/control-center-ip";
    }

    signal connected()
    signal passwordRequired(string networkName)
    signal passwordRejected()
    signal connectionFailed(string message)

    readonly property var device: {
        if (!networking || !networking.devices)
            return null;
        const source = Array.isArray(networking.devices) ? networking.devices : networking.devices.values;
        return [...source].find(candidate => candidate.type === DeviceType.Wifi) || null;
    }
    readonly property bool ready: device !== null
    readonly property bool enabled: ready && networking.wifiEnabled
    readonly property var allNetworks: {
        if (!device || !device.networks)
            return [];
        const source = Array.isArray(device.networks) ? device.networks : device.networks.values;
        return [...source];
    }
    readonly property var activeNetwork: allNetworks.find(network => network.connected) || null
    readonly property var networks: allNetworks
        .filter(network => network.name !== "" && network !== activeNetwork && !network.connected)
        .sort((left, right) => right.signalStrength - left.signalStrength)
        .slice(0, 6)
    readonly property bool busy: pendingNetwork !== null

    onMenuActiveChanged: {
        if (device)
            device.scannerEnabled = menuActive;
    }

    onDeviceChanged: {
        if (device)
            device.scannerEnabled = menuActive;
    }

    onActiveNetworkChanged: refreshIp()

    function refreshIp(): void {
        if (activeNetwork === null || device === null || ipReader.running) {
            if (activeNetwork === null)
                ipAddress = "";
            if (activeNetwork !== null && ipReader.running)
                ipRefreshPending = true;
            return;
        }
        ipRequestNetwork = activeNetwork.name;
        ipRefreshPending = false;
        ipReader.running = true;
    }

    function setEnabled(value: bool): bool {
        if (!ready || busy || !networking.wifiHardwareEnabled)
            return false;
        networking.wifiEnabled = value;
        return true;
    }

    function networkNamed(name: string): var {
        return allNetworks.find(network => network.name === name) || null;
    }

    function requestConnection(name: string): int {
        const network = networkNamed(name);
        if (!enabled || busy || network === null)
            return WifiService.Rejected;
        if (network.known || network.security === WifiSecurityType.Open || network.security === WifiSecurityType.Owe) {
            start(network, false);
            network.connect();
            return WifiService.Started;
        }
        if (network.security === WifiSecurityType.WpaPsk || network.security === WifiSecurityType.Wpa2Psk
                || network.security === WifiSecurityType.Sae)
            return WifiService.PasswordRequired;
        return WifiService.EditorRequired;
    }

    function connectWithPassword(name: string, password: string): bool {
        const network = networkNamed(name);
        if (!enabled || busy || network === null || password === "")
            return false;
        start(network, true);
        network.connectWithPsk(password);
        return true;
    }

    function start(network: var, withPassword: bool): void {
        cancelRequested = false;
        pendingNetwork = network;
        passwordAttempt = withPassword;
        error = "";
        actionTimeout.restart();
        Qt.callLater(checkPending);
    }

    function disconnectActive(): bool {
        if (busy || activeNetwork === null)
            return false;
        activeNetwork.disconnect();
        return true;
    }

    function cancel(): void {
        if (pendingNetwork !== null) {
            cancelRequested = true;
            pendingNetwork.disconnect();
            Qt.callLater(checkPending);
            return;
        }
        passwordAttempt = false;
    }

    function checkPending(): void {
        if (pendingNetwork !== null && cancelRequested) {
            if (pendingNetwork.connected) {
                pendingNetwork.disconnect();
                return;
            }
            if (!pendingNetwork.stateChanging) {
                actionTimeout.stop();
                pendingNetwork = null;
                passwordAttempt = false;
                cancelRequested = false;
            }
        } else if (pendingNetwork !== null && pendingNetwork.connected) {
            actionTimeout.stop();
            pendingNetwork = null;
            passwordAttempt = false;
            cancelRequested = false;
            connected();
        }
    }

    function fail(reason: int): void {
        if (pendingNetwork === null)
            return;
        if (cancelRequested) {
            actionTimeout.stop();
            pendingNetwork = null;
            passwordAttempt = false;
            cancelRequested = false;
            return;
        }
        const retainPassword = reason === ConnectionFailReason.NoSecrets;
        const wasPasswordAttempt = passwordAttempt;
        const networkName = pendingNetwork.name;
        actionTimeout.stop();
        pendingNetwork = null;
        passwordAttempt = false;
        if (retainPassword) {
            error = "Wrong password - try again";
            if (wasPasswordAttempt)
                passwordRejected();
            else
                passwordRequired(networkName);
        } else {
            error = reason === ConnectionFailReason.WifiNetworkLost ? "Network is no longer available"
                : reason === ConnectionFailReason.WifiAuthTimeout ? "Connection timed out"
                : "Unable to connect";
            connectionFailed(error);
        }
    }

    Connections {
        target: root.pendingNetwork
        ignoreUnknownSignals: true
        function onConnectedChanged(): void { root.checkPending(); }
        function onStateChangingChanged(): void { root.checkPending(); }
        function onConnectionFailed(reason): void { root.fail(reason); }
    }

    Timer {
        id: actionTimeout
        interval: 30000
        onTriggered: root.fail(ConnectionFailReason.WifiAuthTimeout)
    }

    Process {
        id: ipReader
        command: [root.ipBackend, "get", root.device ? root.device.name : ""]
        stdout: StdioCollector {
            onStreamFinished: {
                if (root.activeNetwork !== null && root.activeNetwork.name === root.ipRequestNetwork)
                    root.ipAddress = text.trim();
            }
        }
        onExited: {
            if (root.ipRefreshPending)
                Qt.callLater(root.refreshIp);
        }
    }
}
