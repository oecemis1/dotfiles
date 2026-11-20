#!@PYTHON@
import os
import signal
import sys

import gi

gi.require_version("Gtk", "3.0")
gi.require_version("NM", "1.0")
gi.require_version("AyatanaAppIndicator3", "0.1")
gi.require_version("GLibUnix", "2.0")
from gi.repository import AyatanaAppIndicator3, Gio, GLib, GLibUnix, Gtk, NM


UUID = "c10d378b-595a-55d8-8c10-1db7e9b6a2c9"
AUTH_DIALOG = "@AUTH_DIALOG@"
NMCLI = "@NMCLI@"


def auth_request(setting):
    records = []
    for key in setting.get_data_keys():
        value = setting.get_data_item(key)
        if any(char in key + value for char in "\n\r\0"):
            raise ValueError("VPN profile contains unsupported control characters")
        records.append(f"DATA_KEY={key}\nDATA_VAL={value}\n")
    return "".join(records) + "DONE\nQUIT\n"


def session_secrets(output):
    lines = iter(output.split("\n"))
    values = {}
    for key in lines:
        if not key:
            break
        value = next(lines, None)
        if value is None or key in values:
            raise ValueError("Invalid response from the VPN login dialog")
        values[key] = value
    if not values.get("cookie"):
        return None
    if not all(values.get(key) for key in ("gateway", "gwcert")):
        raise ValueError("VPN login did not return the required connection details")
    return {
        key: values[key]
        for key in ("cookie", "gateway", "gwcert", "resolve")
        if values.get(key)
    }


def secret_fd(values):
    fd = os.memfd_create("eth-vpn-session", os.MFD_CLOEXEC)
    try:
        with os.fdopen(os.dup(fd), "w") as stream:
            for key, value in values.items():
                stream.write(f"vpn.secrets.{key}:{value}\n")
        os.lseek(fd, 0, os.SEEK_SET)
    except BaseException:
        os.close(fd)
        raise
    return fd


class VpnTray(Gtk.Application):
    def __init__(self):
        super().__init__(application_id="io.github.orhun.EthVpn")
        self.indicator = None
        self.process = None
        self.active = None
        self.active_handler = None

    def do_activate(self):
        if self.indicator is not None:
            return
        self.client = NM.Client.new(None)
        self.menu = Gtk.Menu()
        self.status = Gtk.MenuItem(label="ETH VPN")
        self.status.set_sensitive(False)
        self.menu.append(self.status)
        self.connect_item = self.add_item("Connect", self.connect_vpn)
        self.disconnect_item = self.add_item("Disconnect", self.disconnect_vpn)
        self.menu.append(Gtk.SeparatorMenuItem())
        self.add_item("Close", lambda *_: self.quit())
        self.menu.show_all()
        self.indicator = AyatanaAppIndicator3.Indicator.new(
            self.get_application_id(),
            "network-vpn-disconnected-symbolic",
            AyatanaAppIndicator3.IndicatorCategory.COMMUNICATIONS,
        )
        self.indicator.set_menu(self.menu)
        self.indicator.set_status(AyatanaAppIndicator3.IndicatorStatus.ACTIVE)
        for prop in ("active-connections", "connections", "nm-running"):
            self.client.connect(f"notify::{prop}", self.refresh)
        self.hold()
        self.refresh()

    def add_item(self, label, callback):
        item = Gtk.MenuItem(label=label)
        item.connect("activate", callback)
        self.menu.append(item)
        return item

    def refresh(self, *_):
        active = next(
            (
                item
                for item in self.client.get_active_connections()
                if item.get_uuid() == UUID
            ),
            None,
        )
        if active != self.active:
            if self.active is not None:
                self.active.disconnect(self.active_handler)
            self.active = active
            if active is not None:
                self.active_handler = active.connect("notify::state", self.refresh)
        state = active.get_state() if active else NM.ActiveConnectionState.DEACTIVATED
        busy = self.process is not None
        if not self.client.get_nm_running():
            label = "NetworkManager unavailable"
        elif busy:
            label = "ETH VPN — working…"
        else:
            label = {
                NM.ActiveConnectionState.ACTIVATING: "ETH VPN — connecting…",
                NM.ActiveConnectionState.ACTIVATED: "ETH VPN — connected",
                NM.ActiveConnectionState.DEACTIVATING: "ETH VPN — disconnecting…",
            }.get(state, "ETH VPN — disconnected")
        profile = self.client.get_connection_by_uuid(UUID)
        self.status.set_label(label)
        self.indicator.set_title(label)
        icon = {
            NM.ActiveConnectionState.ACTIVATING: "network-vpn-acquiring-symbolic",
            NM.ActiveConnectionState.ACTIVATED: "network-vpn-symbolic",
            NM.ActiveConnectionState.DEACTIVATING: "network-vpn-acquiring-symbolic",
        }.get(state, "network-vpn-disconnected-symbolic")
        self.indicator.set_icon_full(
            "network-vpn-acquiring-symbolic" if busy else icon, label
        )
        self.connect_item.set_sensitive(
            not busy and active is None and profile is not None
        )
        self.disconnect_item.set_sensitive(not busy and active is not None)

    def error(self, message):
        dialog = Gtk.MessageDialog(
            message_type=Gtk.MessageType.ERROR,
            buttons=Gtk.ButtonsType.CLOSE,
            text="ETH VPN",
            secondary_text=message,
        )
        dialog.connect("response", lambda widget, _: widget.destroy())
        dialog.present()

    def connect_vpn(self, *_):
        profile = self.client.get_connection_by_uuid(UUID)
        if profile is None or self.process is not None:
            return
        setting = profile.get_setting_vpn()
        try:
            request = auth_request(setting)
            self.process = Gio.Subprocess.new(
                [
                    AUTH_DIALOG,
                    "-u", UUID,
                    "-n", profile.get_id(),
                    "-s", setting.get_service_type(),
                    "-i",
                ],
                Gio.SubprocessFlags.STDIN_PIPE | Gio.SubprocessFlags.STDOUT_PIPE,
            )
            self.process.communicate_utf8_async(request, None, self.authenticated)
            self.refresh()
        except (GLib.Error, ValueError) as error:
            self.error(str(error))

    def authenticated(self, process, result):
        self.process = None
        try:
            _, output, _ = process.communicate_utf8_finish(result)
            if not process.get_successful():
                raise ValueError("VPN login dialog failed. Please try connecting again.")
            values = session_secrets(output)
            if values is not None:
                launcher = Gio.SubprocessLauncher.new(
                    Gio.SubprocessFlags.STDOUT_PIPE | Gio.SubprocessFlags.STDERR_MERGE
                )
                launcher.take_fd(secret_fd(values), 3)
                try:
                    self.process = launcher.spawnv(
                        [
                            NMCLI,
                            "--wait", "120",
                            "connection", "up", "uuid", UUID,
                            "passwd-file", "/proc/self/fd/3",
                        ]
                    )
                finally:
                    launcher.close()
                self.process.communicate_utf8_async(None, None, self.finished)
        except (GLib.Error, ValueError, OSError) as error:
            self.error(str(error))
        self.refresh()

    def disconnect_vpn(self, *_):
        if self.process is not None:
            return
        try:
            self.process = Gio.Subprocess.new(
                [NMCLI, "connection", "down", "uuid", UUID],
                Gio.SubprocessFlags.STDOUT_PIPE | Gio.SubprocessFlags.STDERR_MERGE,
            )
            self.process.communicate_utf8_async(None, None, self.finished)
            self.refresh()
        except GLib.Error as error:
            self.error(str(error))

    def finished(self, process, result):
        self.process = None
        try:
            _, output, _ = process.communicate_utf8_finish(result)
            if not process.get_successful():
                self.error(output.strip() or "VPN operation failed")
        except GLib.Error as error:
            self.error(str(error))
        self.refresh()

    def do_shutdown(self):
        if self.process is not None:
            self.process.force_exit()
        if self.indicator is not None:
            self.indicator.set_status(AyatanaAppIndicator3.IndicatorStatus.PASSIVE)
        Gtk.Application.do_shutdown(self)


if __name__ == "__main__":
    app = VpnTray()
    for signum in (signal.SIGINT, signal.SIGTERM):
        GLibUnix.signal_add(
            GLib.PRIORITY_DEFAULT,
            signum,
            lambda: app.quit() or GLib.SOURCE_REMOVE,
        )
    sys.exit(app.run(sys.argv))
