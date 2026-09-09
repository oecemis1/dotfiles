import QtQuick
import Quickshell
import Quickshell.Bluetooth
import Quickshell.Io
import Quickshell.Networking
import Quickshell.Wayland

Scope {
    id: root

    property var bluetoothAdapter: Bluetooth.defaultAdapter
    property var wifiNetworking: null

    Theme {
        id: theme
    }

    ControlCenterState {
        id: state
    }

    BrightnessService {
        id: brightness

        active: state.isOpen
    }

    AudioService {
        id: audio
    }

    DndService {
        id: dnd
    }

    PowerService {
        id: power
    }

    UsbService {
        id: usb
        active: state.isOpen
    }

    BluetoothService {
        id: bluetooth
        adapter: root.bluetoothAdapter
    }

    WifiService {
        id: wifi
        networking: root.wifiNetworking || Networking
        menuActive: state.menu === ControlCenterState.Wifi && state.isOpen
        onConnected: {
            passwordInput.text = "";
            state.passwordNetwork = "";
        }
        onPasswordRejected: wifiNotice.text = "Wrong password - try again"
        onPasswordRequired: networkName => {
            state.passwordNetwork = networkName;
            Qt.callLater(() => passwordInput.forceActiveFocus());
        }
        onConnectionFailed: message => {
            passwordInput.text = "";
            state.passwordNetwork = "";
            wifiNotice.text = message;
        }
    }

    Connections {
        target: state
        function onPasswordNetworkChanged(): void {
            if (state.passwordNetwork === "")
                passwordInput.text = "";
        }
    }

    GlassGeometryPublisher {
        id: glassGeometry

        panelMapped: root.panelMapped
        backdropOrigin: backdropReveal
        controlsOrigin: panelReveal
        controlsLayout: contentColumn
        backdropSheet: backdropSheet
        wifiTile: wifiTile
        bluetoothTile: bluetoothTile
        usbTile: usbTile
        dndTile: dndTile
        menuFrame: menuClip
        displaySlider: displaySlider
        soundSlider: soundSlider
        powerCard: powerClip
        sheetRadius: theme.sheetRadius
        controlRadius: theme.controlRadius
    }

    readonly property string requestedScreen: Quickshell.env("CONTROL_CENTER_SCREEN")
    readonly property var targetScreen: {
        if (requestedScreen !== "") {
            for (let index = 0; index < Quickshell.screens.length; index++) {
                if (Quickshell.screens[index].name === requestedScreen)
                    return Quickshell.screens[index];
            }
        }
        return Quickshell.screens.length > 0 ? Quickshell.screens[0] : null;
    }
    property bool panelVisible: false
    property bool closerVisible: false
    property real panelProgress: 0
    property real menuHeight: 0
    property real powerHeight: state.powerOpen ? 204 : theme.stripHeight
    readonly property real panelContentHeight: theme.tileHeight * 2 + theme.sliderCardHeight * 2
        + menuHeight + powerHeight + theme.spacing * (menuHeight > 0 ? 5 : 4)
        + theme.outerPadding * 2
    property var closeAction: null
    readonly property bool panelMapped: panelVisible && targetScreen !== null
    readonly property real panelSurfaceWidth: theme.panelWidth + theme.panelShadowExtent * 2
    readonly property real panelSurfaceHeight: theme.panelHeight + theme.panelShadowExtent * 2
    readonly property real panelSurfaceTopMargin: theme.panelTopMargin - theme.panelShadowExtent
    readonly property real panelSurfaceRightMargin: theme.panelRightMargin - theme.panelShadowExtent

    function finishGuarded(animation: Animation, generation: int, callback: var): void {
        let handler = function(): void {
            animation.finished.disconnect(handler);
            if (generation === state.transitionGeneration)
                callback();
        };
        animation.finished.connect(handler);
    }

    function requestOpen(): void {
        if (state.phase === ControlCenterState.Opening || state.phase === ControlCenterState.Open)
            return;

        closeAction = null;
        Quickshell.execDetached([dnd.backend, "--close-panel"]);
        const generation = ++state.transitionGeneration;
        panelAnimation.stop();
        state.resetContent();
        state.phase = ControlCenterState.Opening;
        closerVisible = true;

        Qt.callLater(function(): void {
            if (generation !== state.transitionGeneration)
                return;
            panelVisible = true;
            Qt.callLater(function(): void {
                if (generation !== state.transitionGeneration)
                    return;
                panelAnimation.to = 1;
                finishGuarded(panelAnimation, generation, function(): void {
                    state.phase = ControlCenterState.Open;
                });
                panelAnimation.start();
            });
        });
    }

    function requestClose(): void {
        if (state.phase === ControlCenterState.Closed || state.phase === ControlCenterState.Closing)
            return;

        const generation = ++state.transitionGeneration;
        panelAnimation.stop();
        state.phase = ControlCenterState.Closing;
        panelAnimation.to = 0;
        finishGuarded(panelAnimation, generation, function(): void {
            panelVisible = false;
            Qt.callLater(function(): void {
                if (generation !== state.transitionGeneration)
                    return;
                closerVisible = false;
                state.resetContent();
                state.phase = ControlCenterState.Closed;
                const action = closeAction;
                closeAction = null;
                if (action !== null)
                    Qt.callLater(action);
            });
        });
        panelAnimation.start();
    }

    function requestToggle(): void {
        if (state.isOpen)
            requestClose();
        else
            requestOpen();
    }

    function requestCloseThen(action: var): bool {
        if (!state.isOpen || closeAction !== null)
            return false;

        closeAction = action;
        requestClose();
        return true;
    }

    function requestPower(actionName: string): bool {
        if (power.busy || (actionName !== "suspend" && actionName !== "hibernate" && actionName !== "poweroff"))
            return false;
        return requestCloseThen(function(): void {
            power.execute(actionName);
        });
    }

    function cancelWifiPrompt(): void {
        wifi.cancel();
        passwordInput.text = "";
        state.passwordNetwork = "";
        state.passwordVisible = false;
    }

    function selectWifi(network: var): void {
        const disposition = wifi.requestConnection(network.name);
        if (disposition === WifiService.PasswordRequired) {
            state.passwordNetwork = network.name;
            wifiNotice.text = "";
            Qt.callLater(() => passwordInput.forceActiveFocus());
        } else if (disposition === WifiService.EditorRequired) {
            requestCloseThen(() => Quickshell.execDetached(["nm-connection-editor"]));
        }
    }

    function reset(): void {
        ++state.transitionGeneration;
        panelAnimation.stop();
        panelProgress = 0;
        panelVisible = false;
        closerVisible = false;
        closeAction = null;
        cancelWifiPrompt();
        state.resetContent();
        state.phase = ControlCenterState.Closed;
    }

    component ControlText: Text {
        color: theme.text
        font.family: theme.textFont
        font.pixelSize: 16
        verticalAlignment: Text.AlignVCenter
        renderType: Text.NativeRendering
    }

    component QuickTile: Rectangle {
        id: tile

        required property string icon
        required property string title
        required property string subtitle
        property bool selected: false
        property bool iconEnabled: false
        property bool iconCircular: false
        property bool menuEnabled: true
        signal iconRequested()
        signal menuRequested()

        width: (contentColumn.width - theme.spacing) / 2
        height: theme.tileHeight
        radius: theme.controlRadius
        border.width: 1
        border.color: theme.controlBorder
        color: !iconCircular && selected
            ? (menuMouse.containsMouse ? theme.controlActiveHover : theme.controlActive)
            : (menuMouse.containsMouse ? theme.controlHover : theme.control)

        Behavior on color {
            ColorAnimation {
                duration: theme.hoverDuration
            }
        }

        Item {
            id: iconArea

            width: 52
            height: parent.height

            Rectangle {
                id: iconButton

                anchors.centerIn: parent
                width: tile.iconCircular ? 38 : 52
                height: tile.iconCircular ? 38 : parent.height
                radius: width / 2
                color: tile.iconCircular
                    ? (tile.selected
                        ? (iconMouse.containsMouse ? theme.controlActiveHover : theme.controlActive)
                        : (iconMouse.containsMouse ? theme.controlHover : theme.footer))
                    : "transparent"

                Behavior on color {
                    ColorAnimation { duration: theme.hoverDuration }
                }

                Text {
                    anchors.centerIn: parent
                    color: theme.text
                    text: tile.icon
                    font.family: theme.iconFont
                    font.pixelSize: 22
                    opacity: tile.iconEnabled ? 1 : 0.65
                    renderType: Text.NativeRendering
                }
            }

            MouseArea {
                id: iconMouse

                anchors.fill: parent
                enabled: tile.iconEnabled
                hoverEnabled: true
                cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                onClicked: tile.iconRequested()
            }
        }

        Item {
            anchors.left: iconArea.right
            anchors.right: parent.right
            height: parent.height

            Column {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: 4
                anchors.rightMargin: 10
                spacing: 1

                ControlText {
                    width: parent.width
                    text: tile.title
                    font.pixelSize: 16
                    font.weight: Font.DemiBold
                    elide: Text.ElideRight
                }

                ControlText {
                    width: parent.width
                    color: theme.text
                    text: tile.subtitle
                    font.pixelSize: 14
                    opacity: 0.82
                    elide: Text.ElideRight
                }
            }

            MouseArea {
                id: menuMouse

                anchors.fill: parent
                enabled: tile.menuEnabled
                hoverEnabled: true
                cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                onClicked: tile.menuRequested()
            }
        }
    }

    component SliderCard: Rectangle {
        id: slider

        required property string title
        required property string leftIcon
        required property string rightIcon
        property real level: 0.5
        property bool interactive: false
        property bool leftIconInteractive: false
        signal levelRequested(real level)
        signal leftIconRequested()

        width: contentColumn.width
        height: theme.sliderCardHeight
        radius: theme.controlRadius
        border.width: 1
        border.color: theme.controlBorder
        color: theme.control

        ControlText {
            anchors.top: parent.top
            anchors.topMargin: 10
            anchors.left: parent.left
            anchors.leftMargin: 16
            text: slider.title
            font.pixelSize: 14
            font.weight: Font.DemiBold
        }

        Item {
            id: sliderRow

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.leftMargin: 12
            anchors.rightMargin: 12
            anchors.bottomMargin: 8
            height: 34

            Item {
                id: leftIconArea

                width: 30
                height: parent.height

                Text {
                    anchors.centerIn: parent
                    color: theme.text
                    text: slider.leftIcon
                    font.family: theme.iconFont
                    font.pixelSize: 18
                    renderType: Text.NativeRendering
                }

                MouseArea {
                    anchors.fill: parent
                    enabled: slider.leftIconInteractive
                    cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                    onClicked: slider.leftIconRequested()
                }
            }

            Item {
                id: trackHitArea

                anchors.left: leftIconArea.right
                anchors.right: rightIconArea.left
                anchors.verticalCenter: parent.verticalCenter
                height: 26

                readonly property real thumbWidth: theme.sliderThumbWidth
                readonly property real thumbHeight: theme.sliderThumbHeight
                readonly property real travel: Math.max(1, width - thumbWidth)

                Rectangle {
                    id: sliderTrack

                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.leftMargin: trackHitArea.thumbWidth / 2
                    anchors.rightMargin: trackHitArea.thumbWidth / 2
                    height: 4
                    radius: 2
                    color: theme.sliderTrack

                    Rectangle {
                        width: parent.width * Math.max(0, Math.min(1, slider.level))
                        height: parent.height
                        radius: height / 2
                        color: theme.sliderActive
                    }
                }

                Rectangle {
                    id: thumb

                    width: trackHitArea.thumbWidth
                    height: trackHitArea.thumbHeight
                    x: trackHitArea.travel * Math.max(0, Math.min(1, slider.level))
                    anchors.verticalCenter: parent.verticalCenter
                    radius: width / 2
                    color: trackMouse.pressed ? theme.sliderThumbPressed : theme.sliderThumb
                    opacity: trackMouse.containsMouse || trackMouse.pressed ? 1 : 0
                    scale: trackMouse.pressed ? 1.08 : 1
                    border.width: trackMouse.pressed ? 1 : 0
                    border.color: theme.sliderThumbEdge

                    Behavior on opacity {
                        NumberAnimation {
                            duration: theme.thumbHoverDuration
                            easing.type: Easing.BezierSpline
                            easing.bezierCurve: [0.23, 1, 0.32, 1, 1, 1]
                        }
                    }

                    Behavior on scale {
                        enabled: !trackMouse.pressed
                        NumberAnimation {
                            duration: theme.pressDuration
                            easing.type: Easing.BezierSpline
                            easing.bezierCurve: [0.23, 1, 0.32, 1, 1, 1]
                        }
                    }

                    Behavior on color {
                        enabled: !trackMouse.pressed
                        ColorAnimation {
                            duration: theme.pressDuration
                            easing.type: Easing.BezierSpline
                            easing.bezierCurve: [0.23, 1, 0.32, 1, 1, 1]
                        }
                    }
                }

                MouseArea {
                    id: trackMouse

                    anchors.fill: parent
                    enabled: slider.interactive
                    hoverEnabled: true
                    cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor

                    function request(mouseX: real): void {
                        const centered = mouseX - trackHitArea.thumbWidth / 2;
                        slider.levelRequested(Math.max(0, Math.min(1, centered / trackHitArea.travel)));
                    }

                    onPressed: mouse => request(mouse.x)
                    onPositionChanged: mouse => {
                        if (pressed)
                            request(mouse.x);
                    }
                }
            }

            Item {
                id: rightIconArea

                anchors.right: parent.right
                width: 30
                height: parent.height

                Text {
                    anchors.centerIn: parent
                    color: theme.text
                    text: slider.rightIcon
                    font.family: theme.iconFont
                    font.pixelSize: 18
                    renderType: Text.NativeRendering
                }
            }
        }
    }

    NumberAnimation {
        id: panelAnimation

        target: root
        property: "panelProgress"
        duration: theme.panelDuration
        easing.type: Easing.OutCubic
    }

    Behavior on powerHeight {
        NumberAnimation {
            duration: theme.menuDuration
            easing.type: Easing.OutCubic
        }
    }

    PanelWindow {
        id: closer

        visible: root.closerVisible && root.targetScreen !== null
        screen: root.targetScreen
        color: "transparent"
        surfaceFormat.opaque: false
        focusable: false
        exclusionMode: ExclusionMode.Ignore

        anchors {
            top: true
            right: true
            bottom: true
            left: true
        }

        WlrLayershell.namespace: "control_center_closer"
        WlrLayershell.layer: WlrLayer.Top
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
            onClicked: root.requestClose()
        }
    }

    PanelWindow {
        id: backdrop

        visible: root.panelMapped
        screen: root.targetScreen
        implicitWidth: root.panelSurfaceWidth
        implicitHeight: root.panelSurfaceHeight
        color: "transparent"
        surfaceFormat.opaque: false
        focusable: false
        exclusionMode: ExclusionMode.Ignore

        anchors {
            top: true
            right: true
        }

        margins {
            top: root.panelSurfaceTopMargin
            right: root.panelSurfaceRightMargin
        }

        WlrLayershell.namespace: "control_center_backdrop"
        WlrLayershell.layer: WlrLayer.Top
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

        mask: Region {
            width: 0
            height: 0
        }

        Item {
            id: backdropReveal

            width: parent.width
            height: (root.panelContentHeight + theme.panelShadowExtent * 2) * root.panelProgress
            clip: true

            Rectangle {
                id: backdropSheet

                x: theme.panelShadowExtent
                y: theme.panelShadowExtent
                width: theme.panelWidth
                height: root.panelContentHeight
                radius: theme.sheetRadius
                border.width: 1
                border.color: theme.sheetBorder
                color: theme.sheet
            }
        }
    }

    PanelWindow {
        id: panel

        visible: root.panelMapped
        screen: root.targetScreen
        implicitWidth: root.panelSurfaceWidth
        implicitHeight: root.panelSurfaceHeight
        color: "transparent"
        surfaceFormat.opaque: false
        focusable: state.passwordNetwork !== ""
        exclusionMode: ExclusionMode.Ignore

        anchors {
            top: true
            right: true
        }

        margins {
            top: root.panelSurfaceTopMargin
            right: root.panelSurfaceRightMargin
        }

        WlrLayershell.namespace: "control_center"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: state.passwordNetwork !== ""
            ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

        mask: Region {
            x: 0
            y: 0
            width: panel.width
            height: Math.max(panelReveal.height, root.panelVisible ? 1 : 0)
        }

        Item {
            id: panelReveal

            width: parent.width
            height: (root.panelContentHeight + theme.panelShadowExtent * 2) * root.panelProgress
            clip: true

            Item {
                id: panelContent

                x: theme.panelShadowExtent
                y: theme.panelShadowExtent
                width: theme.panelWidth
                height: root.panelContentHeight

                Column {
                    id: contentColumn

                    x: theme.outerPadding
                    y: theme.outerPadding
                    width: parent.width - theme.outerPadding * 2
                    spacing: theme.spacing

                    Row {
                        width: parent.width
                        height: theme.tileHeight
                        spacing: theme.spacing

                        QuickTile {
                            id: wifiTile

                            icon: "󰤨"
                            title: "Wi-Fi"
                            subtitle: !wifi.ready ? "Unavailable" : !wifi.enabled ? "Off"
                                : wifi.activeNetwork ? wifi.activeNetwork.name : "On"
                            selected: wifi.enabled
                            iconEnabled: wifi.ready && !wifi.busy
                            iconCircular: true
                            onIconRequested: {
                                root.cancelWifiPrompt();
                                wifi.setEnabled(!wifi.enabled);
                            }
                            onMenuRequested: {
                                state.toggleMenu(ControlCenterState.Wifi);
                            }
                        }

                        QuickTile {
                            id: bluetoothTile

                            icon: "󰂯"
                            title: "Bluetooth"
                            subtitle: !bluetooth.available ? "Unavailable"
                                : !bluetooth.powered ? "Off"
                                : bluetooth.connectedCount > 0 ? `${bluetooth.connectedCount} connected` : "On"
                            selected: bluetooth.powered
                            iconEnabled: bluetooth.available && !bluetooth.busy
                            iconCircular: true
                            onMenuRequested: {
                                state.toggleMenu(ControlCenterState.Bluetooth);
                            }
                            onIconRequested: bluetooth.togglePower()
                        }
                    }

                    Row {
                        width: parent.width
                        height: theme.tileHeight
                        spacing: theme.spacing

                        QuickTile {
                            id: usbTile

                            icon: "󱊞"
                            title: "USB"
                            subtitle: usb.ready ? (usb.devices.length === 0 ? "None"
                                : `${usb.devices.length} device${usb.devices.length === 1 ? "" : "s"}`) : "Unavailable"
                            selected: usb.devices.length > 0
                            iconEnabled: true
                            onIconRequested: {
                                state.toggleMenu(ControlCenterState.Usb);
                            }
                            onMenuRequested: {
                                state.toggleMenu(ControlCenterState.Usb);
                            }
                        }

                        QuickTile {
                            id: dndTile

                            icon: "󰤄"
                            title: "DND"
                            subtitle: dnd.error !== "" ? "Error"
                                : dnd.ready ? (dnd.enabled ? "On" : "Off")
                                : "Unavailable"
                            selected: dnd.enabled
                            iconEnabled: dnd.ready && !dnd.busy
                            iconCircular: true
                            menuEnabled: dnd.ready && !dnd.busy
                            onIconRequested: dnd.toggle()
                            onMenuRequested: dnd.toggle()
                        }
                    }

                    Item {
                        id: menuClip

                        property int displayedMenu: ControlCenterState.None
                        property bool followsContent: false
                        property int animationGeneration: 0
                        property bool targetSyncPending: false

                        readonly property real targetHeight: {
                            if (state.menu === ControlCenterState.Wifi)
                                return Math.max(210, usbContent.implicitHeight + 28
                                    + wifiDetails.desiredHeight - wifiDetails.height);
                            if (state.menu === ControlCenterState.Bluetooth)
                                return Math.max(164, usbContent.implicitHeight + 28);
                            if (state.menu === ControlCenterState.Usb)
                                return Math.max(132, usbContent.implicitHeight + 28);
                            return 0;
                        }

                        width: parent.width
                        height: root.menuHeight
                        visible: height > 0 || displayedMenu !== ControlCenterState.None
                        clip: true

                        onTargetHeightChanged: scheduleContentSync()

                        function scheduleContentSync(): void {
                            if (targetSyncPending)
                                return;
                            targetSyncPending = true;
                            Qt.callLater(syncContentHeight);
                        }

                        function syncContentHeight(): void {
                            targetSyncPending = false;
                            if (!followsContent || state.menu === ControlCenterState.None
                                    || displayedMenu !== state.menu
                                    || Math.abs(height - targetHeight) < 0.5)
                                return;

                            ++animationGeneration;
                            menuHeightAnimation.stop();
                            followsContent = false;
                            menuHeightAnimation.duration = theme.passwordDuration;
                            menuHeightAnimation.from = height;
                            menuHeightAnimation.to = targetHeight;
                            menuHeightAnimation.start();
                        }

                        function animateMenu(nextMenu: int): void {
                            const generation = ++animationGeneration;
                            menuHeightAnimation.stop();
                            followsContent = false;
                            menuHeightAnimation.duration = theme.menuDuration;
                            if (nextMenu === ControlCenterState.None) {
                                menuHeightAnimation.from = height;
                                menuHeightAnimation.to = 0;
                                menuHeightAnimation.start();
                                return;
                            }

                            displayedMenu = nextMenu;
                            if (nextMenu !== ControlCenterState.Wifi)
                                root.cancelWifiPrompt();
                            Qt.callLater(function(): void {
                                if (generation !== menuClip.animationGeneration)
                                    return;
                                menuHeightAnimation.from = menuClip.height;
                                menuHeightAnimation.to = menuClip.targetHeight;
                                menuHeightAnimation.start();
                            });
                        }

                        function animateContentResize(nextHeight: real): void {
                            ++animationGeneration;
                            menuHeightAnimation.stop();
                            followsContent = false;
                            menuHeightAnimation.duration = theme.passwordDuration;
                            menuHeightAnimation.from = height;
                            menuHeightAnimation.to = Math.max(0, nextHeight);
                            menuHeightAnimation.start();
                        }

                        Connections {
                            target: state
                            function onMenuChanged(): void {
                                menuClip.animateMenu(state.menu);
                            }
                        }

                        NumberAnimation {
                            id: menuHeightAnimation

                            target: root
                            property: "menuHeight"
                            duration: theme.menuDuration
                            easing.type: Easing.OutCubic
                            onFinished: {
                                if (state.menu === ControlCenterState.None) {
                                    root.cancelWifiPrompt();
                                    menuClip.displayedMenu = ControlCenterState.None;
                                } else {
                                    menuClip.followsContent = true;
                                    menuClip.scheduleContentSync();
                                }
                            }
                        }

                        Rectangle {
                            width: parent.width
                            height: menuClip.height
                            radius: theme.controlRadius
                            border.width: 1
                            border.color: theme.controlBorder
                            color: theme.control

                            Column {
                                id: usbContent
                                anchors.fill: parent
                                anchors.margins: 14
                                spacing: 8

                                ControlText {
                                    text: menuClip.displayedMenu === ControlCenterState.Wifi ? "Wi-Fi" :
                                        menuClip.displayedMenu === ControlCenterState.Bluetooth ? "Bluetooth" : "Removable Media"
                                    font.weight: Font.DemiBold
                                }

                                Column {
                                    id: bluetoothContent
                                    visible: menuClip.displayedMenu === ControlCenterState.Bluetooth
                                    width: parent.width
                                    spacing: 8

                                    ControlText { text: "Devices"; font.weight: Font.DemiBold }
                                    ControlText {
                                        visible: !bluetooth.available || !bluetooth.powered || bluetooth.devices.length === 0
                                        text: !bluetooth.available ? "Bluetooth unavailable"
                                            : !bluetooth.powered ? "Bluetooth is off" : "No paired devices"
                                        color: theme.secondaryText
                                        font.pixelSize: 14
                                    }
                                    Repeater {
                                        model: bluetooth.powered ? bluetooth.devices : []
                                        delegate: Rectangle {
                                            id: bluetoothRow
                                            required property var modelData
                                            readonly property var device: modelData
                                            width: bluetoothContent.width
                                            height: 48
                                            radius: 8
                                            color: theme.footer
                                            ControlText {
                                                anchors.left: parent.left
                                                anchors.leftMargin: 10
                                                anchors.verticalCenter: parent.verticalCenter
                                                width: parent.width - 100
                                                text: `${bluetooth.displayName(bluetoothRow.device)}${bluetoothRow.device.batteryAvailable ? "  " + Math.round(bluetoothRow.device.battery * 100) + "%" : ""}`
                                                font.pixelSize: 13
                                                elide: Text.ElideRight
                                            }
                                            Rectangle {
                                                anchors.right: parent.right
                                                anchors.rightMargin: 8
                                                anchors.verticalCenter: parent.verticalCenter
                                                width: 76
                                                height: 32
                                                radius: 7
                                                color: theme.control
                                                ControlText { anchors.centerIn: parent; text: bluetoothRow.device.connected ? "Disconnect" : "Connect"; font.pixelSize: 12 }
                                                MouseArea {
                                                    anchors.fill: parent
                                                    enabled: !bluetooth.busy
                                                    cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                                                    onClicked: bluetooth.requestDevice(bluetoothRow.device.address, !bluetoothRow.device.connected)
                                                }
                                            }
                                        }
                                    }
                                    ControlText { visible: bluetooth.error !== ""; text: bluetooth.error; color: theme.danger; font.pixelSize: 13 }
                                    Rectangle {
                                        width: parent.width
                                        height: 36
                                        radius: 8
                                        color: theme.footer
                                        ControlText { anchors.centerIn: parent; text: "Open Overskride..."; font.pixelSize: 14 }
                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: root.requestCloseThen(() => Quickshell.execDetached(["overskride"]))
                                        }
                                    }
                                }

                                Column {
                                    id: wifiContent
                                    visible: menuClip.displayedMenu === ControlCenterState.Wifi
                                    width: parent.width
                                    spacing: 8

                                    ControlText { text: "Wi-Fi"; font.weight: Font.DemiBold }
                                    ControlText {
                                        visible: wifi.activeNetwork !== null
                                        text: wifi.activeNetwork ? `${wifi.activeNetwork.name}  ${Math.round(wifi.activeNetwork.signalStrength * 100)}%${wifi.ipAddress !== "" ? "  " + wifi.ipAddress : ""}` : ""
                                        font.pixelSize: 14
                                    }
                                    Rectangle {
                                        id: wifiDisconnect

                                        visible: wifi.activeNetwork !== null
                                        width: parent.width
                                        height: 30
                                        radius: 7
                                        color: wifiDisconnectMouse.containsMouse ? theme.controlHover : theme.footer
                                        Behavior on color { ColorAnimation { duration: theme.hoverDuration } }
                                        ControlText { anchors.centerIn: parent; text: "Disconnect"; font.pixelSize: 12 }
                                        MouseArea { id: wifiDisconnectMouse; anchors.fill: parent; enabled: !wifi.busy; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: wifi.disconnectActive() }
                                    }
                                    Item {
                                        id: wifiDetails

                                        property bool networksMounted: true
                                        property bool remountingNetworks: false
                                        property bool retainedAfterFade: false
                                        property bool networkResizePending: false
                                        property bool transitionPending: false
                                        property int transitionGeneration: 0
                                        property real animatedHeight: wifiNetworksColumn.implicitHeight
                                        property real retainedNetworksHeight: 0
                                        readonly property bool promptVisible: state.passwordNetwork !== ""
                                        readonly property real desiredHeight: promptVisible ? 92
                                            : wifi.enabled
                                                ? (remountingNetworks ? retainedNetworksHeight : wifiNetworksColumn.implicitHeight)
                                                : 0

                                        width: parent.width
                                        height: promptVisible ? Math.max(92, animatedHeight) : animatedHeight
                                        visible: promptVisible || height > 0
                                        clip: true

                                        function transitionPassword(showPrompt: bool): void {
                                            const generation = ++transitionGeneration;
                                            transitionPending = true;
                                            wifiDetailsHeightAnimation.stop();
                                            wifiPasswordOpacityAnimation.stop();
                                            wifiNetworksOpacityAnimation.stop();
                                            wifiNetworksUnmountTimer.stop();

                                            if (showPrompt) {
                                                remountingNetworks = false;
                                                retainedAfterFade = false;
                                            } else {
                                                remountingNetworks = true;
                                                networksMounted = true;
                                            }

                                            Qt.callLater(function(): void {
                                                if (generation !== wifiDetails.transitionGeneration)
                                                    return;
                                                wifiDetailsHeightAnimation.from = wifiDetails.height;
                                                wifiDetailsHeightAnimation.to = wifiDetails.desiredHeight;
                                                wifiPasswordOpacityAnimation.from = wifiPassword.opacity;
                                                wifiPasswordOpacityAnimation.to = showPrompt ? 1 : 0;
                                                wifiNetworksOpacityAnimation.from = wifiNetworksColumn.opacity;
                                                wifiNetworksOpacityAnimation.to = showPrompt ? 0 : 1;
                                                menuClip.animateContentResize(menuClip.targetHeight);
                                                wifiDetailsHeightAnimation.start();
                                                wifiPasswordOpacityAnimation.start();
                                                wifiNetworksOpacityAnimation.start();
                                                wifiDetails.transitionPending = false;
                                            });
                                        }

                                        function scheduleNetworkResize(): void {
                                            if (networkResizePending)
                                                return;
                                            networkResizePending = true;
                                            Qt.callLater(function(): void {
                                                wifiDetails.networkResizePending = false;
                                                if (wifiDetails.promptVisible || wifiDetails.transitionPending
                                                        || wifiDetailsHeightAnimation.running)
                                                    return;
                                                if (menuClip.displayedMenu === ControlCenterState.Wifi
                                                        && state.menu === ControlCenterState.Wifi) {
                                                    wifiDetailsHeightAnimation.stop();
                                                    wifiDetailsHeightAnimation.from = wifiDetails.height;
                                                    wifiDetailsHeightAnimation.to = wifiDetails.desiredHeight;
                                                    menuClip.animateContentResize(menuClip.targetHeight);
                                                    wifiDetailsHeightAnimation.start();
                                                } else {
                                                    wifiDetails.animatedHeight = wifiDetails.desiredHeight;
                                                }
                                            });
                                        }

                                        NumberAnimation {
                                            id: wifiDetailsHeightAnimation

                                            target: wifiDetails
                                            property: "animatedHeight"
                                            duration: theme.passwordDuration
                                            easing.type: Easing.OutCubic
                                        }

                                        NumberAnimation {
                                            id: wifiPasswordOpacityAnimation

                                            target: wifiPassword
                                            property: "opacity"
                                            duration: theme.passwordDuration
                                            easing.type: Easing.OutCubic
                                        }

                                        NumberAnimation {
                                            id: wifiNetworksOpacityAnimation

                                            target: wifiNetworksColumn
                                            property: "opacity"
                                            duration: theme.passwordDuration
                                            easing.type: Easing.OutCubic
                                            onFinished: {
                                                if (wifiDetails.promptVisible) {
                                                    wifiDetails.retainedAfterFade = wifiDetails.networksMounted
                                                        && wifiNetworksColumn.opacity === 0;
                                                    wifiNetworksUnmountTimer.start();
                                                }
                                            }
                                        }

                                        Timer {
                                            id: wifiNetworksUnmountTimer

                                            interval: theme.unmountDelay
                                            repeat: false
                                            onTriggered: {
                                                if (wifiDetails.promptVisible && wifiNetworksColumn.opacity === 0)
                                                    wifiDetails.networksMounted = false;
                                            }
                                        }

                                        Connections {
                                            target: state
                                            function onPasswordNetworkChanged(): void {
                                                wifiDetails.transitionPassword(state.passwordNetwork !== "");
                                            }
                                        }

                                        Rectangle {
                                            id: wifiPassword

                                            width: parent.width
                                            height: 92
                                            radius: 8
                                            color: theme.footer
                                            opacity: 0
                                            visible: opacity > 0
                                            z: 1

                                            Column {
                                                anchors.fill: parent
                                                anchors.margins: 8
                                                spacing: 6
                                                ControlText { text: `Password for ${state.passwordNetwork}`; font.pixelSize: 13 }
                                                Row {
                                                    width: parent.width
                                                    height: 34
                                                    spacing: 6
                                                    Rectangle {
                                                        width: parent.width - 142
                                                        height: 34
                                                        radius: 6
                                                        color: theme.control
                                                        TextInput {
                                                            id: passwordInput
                                                            anchors.fill: parent
                                                            anchors.margins: 7
                                                            color: theme.text
                                                            echoMode: state.passwordVisible ? TextInput.Normal : TextInput.Password
                                                            onAccepted: {
                                                                if (text === "") wifiNotice.text = "Enter a password";
                                                                else wifi.connectWithPassword(state.passwordNetwork, text);
                                                            }
                                                        }
                                                    }
                                                    Rectangle { width: 60; height: 34; radius: 6; color: theme.control; ControlText { anchors.centerIn: parent; text: "Cancel"; font.pixelSize: 12 } MouseArea { anchors.fill: parent; onClicked: root.cancelWifiPrompt() } }
                                                    Rectangle { width: 64; height: 34; radius: 6; color: theme.controlActive; ControlText { anchors.centerIn: parent; text: "Connect"; font.pixelSize: 12 } MouseArea { anchors.fill: parent; onClicked: { if (passwordInput.text === "") wifiNotice.text="Enter a password"; else wifi.connectWithPassword(state.passwordNetwork, passwordInput.text); } } }
                                                }
                                            }
                                        }

                                        Column {
                                            id: wifiNetworksColumn

                                            width: parent.width
                                            spacing: 8
                                            opacity: 1
                                            visible: wifiDetails.networksMounted || opacity > 0
                                            z: 0

                                            onImplicitHeightChanged: {
                                                if (wifiDetails.networksMounted && implicitHeight > 0) {
                                                    wifiDetails.retainedNetworksHeight = implicitHeight;
                                                    wifiDetails.remountingNetworks = false;
                                                }
                                                if (wifiDetails.promptVisible || wifiDetails.transitionPending
                                                        || wifiDetailsHeightAnimation.running)
                                                    return;
                                                wifiDetails.scheduleNetworkResize();
                                            }

                                            Repeater {
                                                model: wifi.enabled && wifiDetails.networksMounted ? wifi.networks : []
                                                delegate: Rectangle {
                                                    id: wifiRow
                                                    required property var modelData
                                                    width: wifiContent.width
                                                    height: 38
                                                    radius: 7
                                                    color: wifiRowMouse.containsMouse ? theme.controlHover : theme.footer
                                                    Behavior on color { ColorAnimation { duration: theme.hoverDuration } }
                                                    ControlText { anchors.left: parent.left; anchors.leftMargin: 10; anchors.verticalCenter: parent.verticalCenter; text: wifiRow.modelData.name; font.pixelSize: 13 }
                                                    ControlText { anchors.right: parent.right; anchors.rightMargin: 10; anchors.verticalCenter: parent.verticalCenter; text: `${Math.round(wifiRow.modelData.signalStrength * 100)}%`; font.pixelSize: 12 }
                                                    MouseArea { id: wifiRowMouse; anchors.fill: parent; enabled: !wifi.busy; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: root.selectWifi(wifiRow.modelData) }
                                                }
                                            }
                                        }
                                    }
                                    ControlText { id: wifiNotice; visible: text !== "" || wifi.error !== ""; text: wifi.error; color: theme.danger; font.pixelSize: 13 }
                                    Rectangle {
                                        id: wifiEditor

                                        width: parent.width; height: 36; radius: 8
                                        color: wifiEditorMouse.containsMouse ? theme.controlHover : theme.footer
                                        Behavior on color { ColorAnimation { duration: theme.hoverDuration } }
                                        ControlText { anchors.centerIn: parent; text: "Edit Connections..."; font.pixelSize: 14 }
                                        MouseArea { id: wifiEditorMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: root.requestCloseThen(() => Quickshell.execDetached(["nm-connection-editor"])) }
                                    }
                                }

                                ControlText {
                                    width: parent.width
                                    visible: false
                                    text: "The service adapter will be connected in the next migration step."
                                    color: theme.secondaryText
                                    font.pixelSize: 14
                                    wrapMode: Text.WordWrap
                                }

                                ControlText {
                                    visible: menuClip.displayedMenu === ControlCenterState.Usb && usb.devices.length === 0
                                    text: usb.ready ? "No devices connected" : "Service unavailable"
                                    color: theme.secondaryText
                                    font.pixelSize: 14
                                }

                                Repeater {
                                    model: menuClip.displayedMenu === ControlCenterState.Usb ? usb.devices : []
                                    delegate: Rectangle {
                                        id: usbRow

                                        required property var modelData
                                        readonly property var device: modelData
                                        width: usbContent.width
                                        height: 58
                                        radius: 8
                                        color: theme.footer

                                        ControlText {
                                            anchors.left: parent.left
                                            anchors.leftMargin: 10
                                            anchors.verticalCenter: parent.verticalCenter
                                            width: parent.width - 150
                                            text: `${modelData.label}\n${modelData.mounted && modelData.free !== "" ? modelData.free + " free of " : ""}${modelData.size}`
                                            font.pixelSize: 13
                                        }

                                        Row {
                                            anchors.right: parent.right
                                            anchors.rightMargin: 8
                                            anchors.verticalCenter: parent.verticalCenter
                                            spacing: 6

                                            Repeater {
                                                model: modelData.mounted ? ["browse", "unmount", "eject"] : ["mount", "eject"]
                                                delegate: Rectangle {
                                                    required property string modelData
                                                    width: 34
                                                    height: 34
                                                    radius: 7
                                                    color: theme.control
                                                    ControlText {
                                                        anchors.centerIn: parent
                                                        text: modelData === "browse" ? "󰉋" : modelData === "mount" ? "󰋊" : modelData === "unmount" ? "󰕧" : "󰆴"
                                                        font.family: theme.iconFont
                                                    }
                                                    MouseArea {
                                                        anchors.fill: parent
                                                        enabled: !usb.busy && usb.ready
                                                        cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                                                        onClicked: {
                                                            if (modelData === "browse")
                                                                root.requestCloseThen(() => usb.run("browse", usbRow.device.path));
                                                            else
                                                                usb.run(modelData, usbRow.device.path);
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }

                                Rectangle {
                                    visible: menuClip.displayedMenu === ControlCenterState.Usb
                                    width: parent.width
                                    height: 36
                                    radius: 8
                                    color: theme.footer
                                    ControlText { anchors.centerIn: parent; text: "Open Disks..."; font.pixelSize: 14 }
                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: root.requestCloseThen(() => usb.run("manage", ""))
                                    }
                                }

                                ControlText {
                                    visible: menuClip.displayedMenu === ControlCenterState.Usb && usb.error !== ""
                                    text: usb.error
                                    color: theme.danger
                                    font.pixelSize: 13
                                }
                            }
                        }
                    }

                    SliderCard {
                        id: displaySlider

                        title: "Display"
                        leftIcon: "󰖙"
                        rightIcon: "󰖨"
                        level: brightness.value / 100
                        interactive: brightness.ready
                        onLevelRequested: level => brightness.requestValue(Math.max(1, Math.round(level * 100)))
                    }

                    SliderCard {
                        id: soundSlider

                        title: "Sound"
                        leftIcon: audio.muted ? "󰝟" : "󰕿"
                        rightIcon: "󰕾"
                        level: audio.volume / 100
                        interactive: audio.available
                        leftIconInteractive: audio.available
                        onLevelRequested: level => audio.setVolume(Math.round(level * 100))
                        onLeftIconRequested: audio.toggleMute()
                    }

                    Item {
                        id: powerClip

                        width: parent.width
                        height: root.powerHeight
                        clip: true

                        Rectangle {
                            width: parent.width
                            height: powerClip.height
                            radius: theme.controlRadius
                            border.width: 1
                            border.color: theme.controlBorder
                            color: theme.control

                            Rectangle {
                                id: powerHeader

                                width: parent.width
                                height: 52
                                radius: theme.controlRadius
                                color: powerHeaderMouse.containsMouse ? theme.controlHover : "transparent"

                                Behavior on color {
                                    ColorAnimation { duration: theme.hoverDuration }
                                }

                                Text {
                                    anchors.left: parent.left
                                    anchors.leftMargin: 16
                                    anchors.verticalCenter: parent.verticalCenter
                                    color: theme.text
                                    text: "󰐥"
                                    font.family: theme.iconFont
                                    font.pixelSize: 22
                                    renderType: Text.NativeRendering
                                }

                                ControlText {
                                    anchors.left: parent.left
                                    anchors.leftMargin: 52
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: "Power"
                                }

                                MouseArea {
                                    id: powerHeaderMouse

                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: state.powerOpen = !state.powerOpen
                                }
                            }

                            Column {
                                x: 14
                                y: 54
                                width: parent.width - 28
                                spacing: 2

                                Repeater {
                                    model: [
                                        { icon: "󰒲", label: "Sleep", action: "suspend" },
                                        { icon: "󰋊", label: "Hibernate", action: "hibernate" },
                                        { icon: "󰐥", label: "Shut Down", action: "poweroff" }
                                    ]

                                    delegate: Rectangle {
                                        id: powerAction

                                        required property var modelData

                                        width: parent.width
                                        height: 46
                                        radius: 8
                                        color: powerActionMouse.containsMouse ? theme.controlHover : "transparent"
                                        opacity: powerActionMouse.containsMouse ? 1 : 0.62

                                        Behavior on color {
                                            ColorAnimation { duration: theme.hoverDuration }
                                        }

                                        Behavior on opacity {
                                            NumberAnimation {
                                                duration: theme.hoverDuration
                                                easing.type: Easing.OutCubic
                                            }
                                        }

                                        Text {
                                            anchors.left: parent.left
                                            anchors.leftMargin: 12
                                            anchors.verticalCenter: parent.verticalCenter
                                            color: theme.text
                                            text: modelData.icon
                                            font.family: theme.iconFont
                                            font.pixelSize: 18
                                            renderType: Text.NativeRendering
                                        }

                                        ControlText {
                                            anchors.left: parent.left
                                            anchors.leftMargin: 44
                                            anchors.right: parent.right
                                            anchors.verticalCenter: parent.verticalCenter
                                            text: modelData.label
                                        }

                                        MouseArea {
                                            id: powerActionMouse

                                            anchors.fill: parent
                                            enabled: !power.busy
                                            hoverEnabled: true
                                            cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                                            onClicked: root.requestPower(modelData.action)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    IpcHandler {
        target: "controlCenter"

        function open(): void {
            root.requestOpen();
        }

        function close(): void {
            root.requestClose();
        }

        function toggle(): void {
            root.requestToggle();
        }

        function setMenu(menu: string): bool {
            return state.setMenuName(menu);
        }

        function cancelWifiPassword(): void {
            root.cancelWifiPrompt();
        }

        function isOpen(): bool {
            return state.isOpen;
        }

        function activeMenu(): string {
            return state.menuName();
        }

        function geometryConnected(): bool {
            return glassGeometry.connected;
        }

        function geometrySocketPath(): string {
            return glassGeometry.socketPath;
        }

        function geometrySerial(): real {
            return glassGeometry.serial;
        }

        function geometryConnectionErrors(): int {
            return glassGeometry.connectionErrors;
        }

        function geometryConnectionCount(): int {
            return glassGeometry.connectionCount;
        }

        function geometrySnapshot(): string {
            return glassGeometry.lastSnapshot;
        }

        function geometryReconnect(): void {
            glassGeometry.reconnect();
        }

        function geometryScheduleBurst(): void {
            glassGeometry.schedulePublish();
            glassGeometry.schedulePublish();
            glassGeometry.schedulePublish();
        }

        function setPowerExpanded(expanded: bool): void {
            state.powerOpen = expanded;
        }

        function wifiReady(): bool {
            return wifi.ready;
        }

        function wifiNetworkCount(): int {
            return wifi.networks.length;
        }

        function wifiActiveName(): string {
            return wifi.activeNetwork ? wifi.activeNetwork.name : "";
        }

        function wifiIpAddress(): string {
            return wifi.ipAddress;
        }

        function wifiPasswordNetwork(): string {
            return state.passwordNetwork;
        }

        function wifiPasswordVisualState(): string {
            return `${wifiPassword.opacity},${wifiPassword.visible},${Math.round(wifiDetails.height)},${Math.round(menuClip.height)}`;
        }

        function wifiPasswordLifecycleState(): string {
            return `${state.passwordNetwork},${wifiPassword.opacity},${wifiPassword.visible},${Math.round(wifiDetails.height)},${Math.round(menuClip.height)}`;
        }

        function selectWifiNetwork(name: string): bool {
            const network = wifi.networkNamed(name);
            if (network === null)
                return false;
            root.selectWifi(network);
            return true;
        }

        function setWifiEnabled(enabled: bool): bool {
            return wifi.setEnabled(enabled);
        }

        function menuHeight(): int {
            return Math.round(menuClip.height);
        }

        function displaySliderY(): int {
            return Math.round(displaySlider.y);
        }

        function wifiNetworksMounted(): bool {
            return wifiDetails.networksMounted;
        }

        function wifiNetworksOpacity(): real {
            return wifiNetworksColumn.opacity;
        }

        function wifiRetainedAfterFade(): bool {
            return wifiDetails.retainedAfterFade;
        }

        function wifiTransitionState(): string {
            return `${Math.round(menuClip.height)},${Math.round(displaySlider.y)},${wifiNetworksColumn.opacity},${wifiDetails.networksMounted}`;
        }

        function brightnessReady(): bool {
            return brightness.ready;
        }

        function brightnessValue(): int {
            return brightness.value;
        }

        function brightnessBusy(): bool {
            return brightness.busy;
        }

        function brightnessWrites(): int {
            return brightness.completedWrites;
        }

        function setBrightness(value: int): int {
            return brightness.requestValue(value);
        }

        function audioReady(): bool {
            return audio.available;
        }

        function volumeValue(): int {
            return audio.volume;
        }

        function audioMuted(): bool {
            return audio.muted;
        }

        function setVolume(value: int): bool {
            return audio.setVolume(value);
        }

        function toggleMute(): bool {
            return audio.toggleMute();
        }

        function dndReady(): bool {
            return dnd.ready;
        }

        function dndEnabled(): bool {
            return dnd.enabled;
        }

        function dndBusy(): bool {
            return dnd.busy;
        }

        function toggleDnd(): bool {
            return dnd.toggle();
        }

        function powerBusy(): bool {
            return power.busy;
        }

        function requestPower(action: string): bool {
            return root.requestPower(action);
        }

        function usbReady(): bool { return usb.ready; }
        function usbCount(): int { return usb.devices.length; }
        function usbBusy(): bool { return usb.busy; }
        function usbAction(action: string, path: string): bool { return usb.run(action, path); }
        function bluetoothReady(): bool { return bluetooth.available; }
        function bluetoothPowered(): bool { return bluetooth.powered; }
        function bluetoothCount(): int { return bluetooth.devices.length; }
        function bluetoothConnectedCount(): int { return bluetooth.connectedCount; }
        function bluetoothBusy(): bool { return bluetooth.busy; }
        function toggleBluetooth(): bool { return bluetooth.togglePower(); }
        function setBluetoothDevice(address: string, connected: bool): bool { return bluetooth.requestDevice(address, connected); }

        function reset(): void {
            root.reset();
        }
    }
}
