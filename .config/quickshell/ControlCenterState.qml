import QtQuick

QtObject {
    enum Phase {
        Closed,
        Opening,
        Open,
        Closing
    }

    enum Menu {
        None,
        Wifi,
        Bluetooth,
        Usb
    }

    property int phase: ControlCenterState.Closed
    property int menu: ControlCenterState.None
    property bool powerOpen: false
    property string passwordNetwork: ""
    property bool passwordVisible: false
    property int transitionGeneration: 0

    readonly property bool isOpen: phase === ControlCenterState.Opening || phase === ControlCenterState.Open

    function menuName(): string {
        if (menu === ControlCenterState.Wifi)
            return "wifi";
        if (menu === ControlCenterState.Bluetooth)
            return "bluetooth";
        if (menu === ControlCenterState.Usb)
            return "usb";
        return "none";
    }

    function setMenuName(name: string): bool {
        let nextMenu = ControlCenterState.None;
        if (name === "wifi")
            nextMenu = ControlCenterState.Wifi;
        else if (name === "bluetooth")
            nextMenu = ControlCenterState.Bluetooth;
        else if (name === "usb")
            nextMenu = ControlCenterState.Usb;
        else if (name !== "none")
            return false;

        menu = nextMenu;
        return true;
    }

    function toggleMenu(nextMenu: int): void {
        menu = menu === nextMenu ? ControlCenterState.None : nextMenu;
    }

    function resetContent(): void {
        menu = ControlCenterState.None;
        powerOpen = false;
        passwordNetwork = "";
        passwordVisible = false;
    }
}
