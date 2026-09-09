import QtQuick
import Quickshell
import Quickshell.Bluetooth

Scope {
    id: root

    property var adapter: Bluetooth.defaultAdapter
    property var pendingDevice: null
    property bool pendingConnect: false
    property bool pendingObservedTransition: false
    property int actionTimeoutMs: 10000
    property string error: ""

    readonly property bool available: adapter !== null
    readonly property bool radioBusy: available && adapter.state !== undefined
        && (adapter.state === BluetoothAdapterState.Enabling || adapter.state === BluetoothAdapterState.Disabling)
    readonly property bool powered: available && (adapter.state !== undefined
        ? adapter.state === BluetoothAdapterState.Enabled : adapter.enabled)
    readonly property var devices: {
        if (!available || adapter.devices === null)
            return [];
        const values = Array.isArray(adapter.devices) ? adapter.devices : adapter.devices.values;
        return [...values].filter(device => device.paired).sort((left, right) => {
            if (left.connected !== right.connected)
                return left.connected ? -1 : 1;
            return displayName(left).localeCompare(displayName(right));
        }).slice(0, 6);
    }
    readonly property int connectedCount: devices.filter(device => device.connected).length
    readonly property bool busy: pendingDevice !== null || radioBusy

    function displayName(device: var): string {
        return device.name || device.deviceName || device.address;
    }

    function togglePower(): bool {
        if (!available || busy || (adapter.state !== undefined && adapter.state === BluetoothAdapterState.Blocked))
            return false;
        adapter.enabled = !adapter.enabled;
        return true;
    }

    function requestDevice(address: string, connect: bool): bool {
        if (!powered || busy)
            return false;
        const device = devices.find(candidate => candidate.address === address);
        if (!device || device.connected === connect)
            return false;

        pendingDevice = device;
        pendingConnect = connect;
        pendingObservedTransition = false;
        error = "";
        actionTimeout.restart();
        if (connect)
            device.connect();
        else
            device.disconnect();
        Qt.callLater(checkPending);
        return true;
    }

    function checkPending(): void {
        if (pendingDevice === null)
            return;
        if (pendingDevice.connected === pendingConnect) {
            actionTimeout.stop();
            pendingDevice = null;
            error = "";
        }
    }

    Connections {
        target: root.pendingDevice
        ignoreUnknownSignals: true
        function onConnectedChanged(): void { root.checkPending(); }
        function onStateChanged(): void {
            if (root.pendingDevice === null)
                return;
            if (root.pendingDevice.state === BluetoothDeviceState.Connecting
                    || root.pendingDevice.state === BluetoothDeviceState.Disconnecting) {
                root.pendingObservedTransition = true;
            } else if (root.pendingObservedTransition && root.pendingDevice.connected !== root.pendingConnect) {
                const name = root.displayName(root.pendingDevice);
                actionTimeout.stop();
                root.pendingDevice = null;
                root.error = `${name} connection failed`;
            }
        }
    }

    Timer {
        id: actionTimeout
        interval: root.actionTimeoutMs
        onTriggered: {
            const name = root.displayName(root.pendingDevice);
            root.pendingDevice = null;
            root.error = `${name} did not respond`;
        }
    }
}
