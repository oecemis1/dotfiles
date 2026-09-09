import QtQuick
import Quickshell
import Quickshell.Io

Scope {
    id: root

    required property bool panelMapped
    required property Item backdropOrigin
    required property Item controlsOrigin
    required property Item controlsLayout
    required property Item backdropSheet
    required property Item wifiTile
    required property Item bluetoothTile
    required property Item usbTile
    required property Item dndTile
    required property Item menuFrame
    required property Item displaySlider
    required property Item soundSlider
    required property Item powerCard
    required property real sheetRadius
    required property real controlRadius

    readonly property string runtimeDir: Quickshell.env("XDG_RUNTIME_DIR")
    readonly property string instanceSignature: Quickshell.env("HYPRLAND_INSTANCE_SIGNATURE")
    readonly property string socketPath: runtimeDir !== "" && instanceSignature !== ""
        ? `${runtimeDir}/hyprglass/${instanceSignature}.sock` : ""
    readonly property double epoch: Date.now() * 1024 + Math.floor(Math.random() * 1024)
    readonly property bool connected: socketLoader.item !== null && socketLoader.item.connected
    property double serial: 0
    property double mappingGeneration: 0
    property int connectionErrors: 0
    property int connectionCount: 0
    property int reconnectDelay: 250
    property bool previouslyMapped: false
    property bool publishPending: false
    property string lastSnapshot: ""

    readonly property string geometryRevision: [
        panelMapped,
        itemRevision(backdropSheet, backdropOrigin),
        itemRevision(wifiTile, controlsOrigin),
        itemRevision(bluetoothTile, controlsOrigin),
        itemRevision(usbTile, controlsOrigin),
        itemRevision(dndTile, controlsOrigin),
        itemRevision(menuFrame, controlsOrigin),
        itemRevision(displaySlider, controlsOrigin),
        itemRevision(soundSlider, controlsOrigin),
        itemRevision(powerCard, controlsOrigin),
        backdropOrigin.width, backdropOrigin.height,
        controlsOrigin.width, controlsOrigin.height
    ].join("|")

    onPanelMappedChanged: {
        if (panelMapped && !previouslyMapped)
            ++mappingGeneration;
        previouslyMapped = panelMapped;
        schedulePublish();
    }
    onGeometryRevisionChanged: schedulePublish()

    Component.onCompleted: {
        previouslyMapped = panelMapped;
        if (panelMapped)
            mappingGeneration = 1;
        schedulePublish();
        reconnect();
    }

    function number(value: real): string {
        return Math.abs(value) < 0.000000001 ? "0" : Number(value).toString();
    }

    function itemGeometry(item: Item, origin: Item): var {
        const point = item.mapToItem(origin, 0, 0);
        return {
            x: point.x,
            y: point.y,
            width: item.width,
            height: item.height
        };
    }

    function itemRevision(item: Item, origin: Item): string {
        const geometry = itemGeometry(item, origin);
        return [item.x, item.y, geometry.x, geometry.y, geometry.width, geometry.height].join(",");
    }

    function shapeRecord(namespaceName: string, surfaceId: string, shapeId: string,
            role: string, item: Item, origin: Item, radius: real, clipId: string): string {
        const geometry = itemGeometry(item, origin);
        return [
            "SHAPE", namespaceName, surfaceId, mappingGeneration, shapeId, role,
            number(geometry.x), number(geometry.y), number(geometry.width), number(geometry.height),
            number(radius), clipId
        ].join("\t");
    }

    function schedulePublish(): void {
        if (publishPending)
            return;
        publishPending = true;
        if (panelMapped) {
            publishFrame.restart();
            return;
        }
        Qt.callLater(function(): void {
            root.publishPending = false;
            root.publish();
        });
    }

    function publish(): void {
        if (!connected)
            return;
        if (panelMapped)
            controlsLayout.forceLayout();

        const active = panelMapped;
        const menuActive = active && menuFrame.height > 0;
        const shapeCount = active ? (menuActive ? 9 : 8) : 0;
        const clipCount = active ? 2 : 0;
        const nextSerial = serial + 1;
        const activeValue = active ? 1 : 0;
        const records = [
            ["BEGIN", 1, epoch, nextSerial, 2, shapeCount, clipCount].join("\t"),
            ["SURFACE", "control_center_backdrop", "backdrop", mappingGeneration, activeValue].join("\t"),
            ["SURFACE", "control_center", "controls", mappingGeneration, activeValue].join("\t")
        ];

        if (active) {
            records.push([
                "CLIP", "control_center_backdrop", "backdrop", mappingGeneration,
                "cc.clip.backdrop.reveal", 0, 0, number(backdropOrigin.width), number(backdropOrigin.height)
            ].join("\t"));
            records.push([
                "CLIP", "control_center", "controls", mappingGeneration,
                "cc.clip.controls.reveal", 0, 0, number(controlsOrigin.width), number(controlsOrigin.height)
            ].join("\t"));
            records.push(shapeRecord("control_center_backdrop", "backdrop", "cc.backdrop.sheet", "sheet",
                backdropSheet, backdropOrigin, sheetRadius, "cc.clip.backdrop.reveal"));
            records.push(shapeRecord("control_center", "controls", "cc.tile.wifi", "control",
                wifiTile, controlsOrigin, controlRadius, "cc.clip.controls.reveal"));
            records.push(shapeRecord("control_center", "controls", "cc.tile.bluetooth", "control",
                bluetoothTile, controlsOrigin, controlRadius, "cc.clip.controls.reveal"));
            records.push(shapeRecord("control_center", "controls", "cc.tile.usb", "control",
                usbTile, controlsOrigin, controlRadius, "cc.clip.controls.reveal"));
            records.push(shapeRecord("control_center", "controls", "cc.tile.dnd", "control",
                dndTile, controlsOrigin, controlRadius, "cc.clip.controls.reveal"));
            if (menuActive) {
                records.push(shapeRecord("control_center", "controls", "cc.menu.frame", "control",
                    menuFrame, controlsOrigin, Math.min(controlRadius, menuFrame.height / 2), "cc.clip.controls.reveal"));
            }
            records.push(shapeRecord("control_center", "controls", "cc.slider.display", "control",
                displaySlider, controlsOrigin, controlRadius, "cc.clip.controls.reveal"));
            records.push(shapeRecord("control_center", "controls", "cc.slider.sound", "control",
                soundSlider, controlsOrigin, controlRadius, "cc.clip.controls.reveal"));
            records.push(shapeRecord("control_center", "controls", "cc.power.card", "control",
                powerCard, controlsOrigin, Math.min(controlRadius, powerCard.height / 2), "cc.clip.controls.reveal"));
        }

        records.push(["COMMIT", nextSerial].join("\t"));
        const snapshot = records.join("\n") + "\n";
        socketLoader.item.write(snapshot);
        socketLoader.item.flush();
        serial = nextSerial;
        lastSnapshot = snapshot;
    }

    function reconnect(): void {
        socketLoader.active = false;
        reconnectTimer.restart();
    }

    Loader {
        id: socketLoader

        active: false
        sourceComponent: Component {
            Socket {
                path: root.socketPath
                connected: true
                onConnectedChanged: {
                    if (connected) {
                        ++root.connectionCount;
                        root.reconnectDelay = 250;
                        root.schedulePublish();
                    } else if (socketLoader.active) {
                        root.reconnect();
                    }
                }
                onError: {
                    ++root.connectionErrors;
                    root.reconnectDelay = Math.min(root.reconnectDelay * 2, 4000);
                    root.reconnect();
                }
            }
        }
    }

    Timer {
        id: reconnectTimer

        interval: root.reconnectDelay
        repeat: false
        onTriggered: {
            if (root.socketPath !== "" && !root.connected)
                socketLoader.active = true;
        }
    }

    FrameAnimation {
        id: publishFrame

        onTriggered: {
            stop();
            root.publishPending = false;
            root.publish();
        }
    }
}
