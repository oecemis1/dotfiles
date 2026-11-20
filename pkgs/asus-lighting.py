#!@PYTHON@
import contextlib
import itertools
import signal
import sys
from dataclasses import replace

sys.path.insert(0, "@CORE_DIR@")

import gi

gi.require_version("Gtk", "3.0")
gi.require_version("Gdk", "3.0")
gi.require_version("GLibUnix", "2.0")
from gi.repository import Gdk, Gio, GLib, GLibUnix, Gtk

from asus_lighting_core import (
    BUS_NAME,
    MODE_FIELDS,
    PROPERTIES,
    SLASH_INTERVAL_MAX,
    SLASH_SWITCHES,
    Brightness,
    Direction,
    Field,
    Gateway,
    Interface,
    LedMode,
    PowerFlags,
    Rgb,
    SlashMode,
    SlashProperty,
    Speed,
    system_bus_call,
)


DEBOUNCE_MS = 200
FAILURES = (GLib.Error, ValueError, LookupError)

BRIGHTNESS_LABELS = {
    Brightness.OFF: "Off",
    Brightness.LOW: "Low",
    Brightness.MED: "Medium",
    Brightness.HIGH: "High",
}
MODE_LABELS = {
    LedMode.STATIC: "Static",
    LedMode.BREATHE: "Breathe",
    LedMode.RAINBOW_CYCLE: "Rainbow cycle",
    LedMode.RAINBOW_WAVE: "Rainbow wave",
    LedMode.PULSE: "Pulse",
}
SPEED_LABELS = {Speed.LOW: "Low", Speed.MED: "Medium", Speed.HIGH: "High"}
DIRECTION_LABELS = {
    Direction.RIGHT: "Right",
    Direction.LEFT: "Left",
    Direction.UP: "Up",
    Direction.DOWN: "Down",
}
POWER_LABELS = {
    "boot": "Boot",
    "awake": "Awake",
    "sleep": "Sleep",
    "shutdown": "Shutdown",
}
SLASH_MODE_LABELS = {mode: mode.name.replace("_", " ").title() for mode in SlashMode}
SLASH_SWITCH_LABELS = {
    SlashProperty.SHOW_ON_BOOT: "Show on boot",
    SlashProperty.SHOW_ON_SHUTDOWN: "Show on shutdown",
    SlashProperty.SHOW_ON_SLEEP: "Show on sleep",
    SlashProperty.SHOW_ON_BATTERY: "Show on battery",
    SlashProperty.SHOW_BATTERY_WARNING: "Show battery warning",
    SlashProperty.SHOW_ON_LID_CLOSED: "Show when lid closed",
}


def to_rgba(colour):
    return Gdk.RGBA(colour.red / 255, colour.green / 255, colour.blue / 255, 1.0)


def from_rgba(rgba):
    return Rgb(round(rgba.red * 255), round(rgba.green * 255), round(rgba.blue * 255))


class EnumCombo(Gtk.ComboBoxText):
    def __init__(self, labels):
        super().__init__()
        self.labels = labels
        self.options = ()
        self.set_options(tuple(labels))

    def set_options(self, options):
        if options == self.options:
            return
        self.options = options
        self.remove_all()
        for option in options:
            self.append(option.name, self.labels[option])

    def select(self, option):
        self.set_active_id(option.name)

    def selected(self):
        name = self.get_active_id()
        return next((option for option in self.options if option.name == name), None)


class Debounce:
    def __init__(self, action):
        self.action = action
        self.source = 0
        self.value = None

    @property
    def pending(self):
        return self.source != 0

    def schedule(self, value):
        if self.source:
            GLib.source_remove(self.source)
        self.value = value
        self.source = GLib.timeout_add(DEBOUNCE_MS, self.fire)

    def fire(self):
        self.source = 0
        self.action(self.value)
        return GLib.SOURCE_REMOVE

    def cancel(self):
        if self.source:
            GLib.source_remove(self.source)
            self.source = 0


class Row:
    def __init__(self, grid, index, text, widget):
        self.label = Gtk.Label(label=text, xalign=0)
        self.widget = widget
        widget.set_hexpand(True)
        grid.attach(self.label, 0, index, 1, 1)
        grid.attach(widget, 1, index, 1, 1)

    def set_visible(self, visible):
        self.label.set_visible(visible)
        self.widget.set_visible(visible)


def make_grid():
    return Gtk.Grid(row_spacing=8, column_spacing=16, margin=12)


def make_frame(title, grid):
    frame = Gtk.Frame(label=title)
    frame.add(grid)
    return frame


def make_switch():
    return Gtk.Switch(halign=Gtk.Align.END, valign=Gtk.Align.CENTER)


def make_scale(maximum):
    scale = Gtk.Scale.new_with_range(Gtk.Orientation.HORIZONTAL, 0, maximum, 1)
    scale.set_digits(0)
    scale.set_value_pos(Gtk.PositionType.RIGHT)
    scale.set_size_request(220, -1)
    return scale


class LightingWindow(Gtk.ApplicationWindow):
    def __init__(self, application):
        super().__init__(application=application, title="ASUS Lighting")
        self.set_resizable(False)
        self.gateway = None
        self.aura = None
        self.mode_data = {}
        self.subscription = None
        self.connection = None
        self.bindings = []

        self.brightness = EnumCombo(BRIGHTNESS_LABELS)
        self.effect = EnumCombo(MODE_LABELS)
        self.colour1 = Gtk.ColorButton(use_alpha=False)
        self.colour2 = Gtk.ColorButton(use_alpha=False)
        self.speed = EnumCombo(SPEED_LABELS)
        self.direction = EnumCombo(DIRECTION_LABELS)
        self.power = {name: make_switch() for name in POWER_LABELS}

        keyboard = make_grid()
        index = itertools.count()
        Row(keyboard, next(index), "Brightness", self.brightness)
        Row(keyboard, next(index), "Effect", self.effect)
        self.fields = {
            Field.COLOUR1: Row(keyboard, next(index), "Colour 1", self.colour1),
            Field.COLOUR2: Row(keyboard, next(index), "Colour 2", self.colour2),
            Field.SPEED: Row(keyboard, next(index), "Speed", self.speed),
            Field.DIRECTION: Row(keyboard, next(index), "Direction", self.direction),
        }
        self.power_rows = [
            Row(keyboard, next(index), POWER_LABELS[name], switch)
            for name, switch in self.power.items()
        ]
        self.keyboard_frame = make_frame("Keyboard", keyboard)

        self.slash_enabled = make_switch()
        self.slash_mode = EnumCombo(SLASH_MODE_LABELS)
        self.slash_brightness = make_scale(255)
        self.slash_interval = make_scale(SLASH_INTERVAL_MAX)
        self.slash_switches = {prop: make_switch() for prop in SLASH_SWITCHES}
        self.slash_brightness_debounce = Debounce(
            lambda value: self.apply(
                Interface.SLASH, Gateway.set_slash, SlashProperty.BRIGHTNESS, value
            )
        )
        self.slash_interval_debounce = Debounce(
            lambda value: self.apply(
                Interface.SLASH, Gateway.set_slash, SlashProperty.INTERVAL, value
            )
        )

        lid = make_grid()
        index = itertools.count()
        Row(lid, next(index), "Enabled", self.slash_enabled)
        Row(lid, next(index), "Mode", self.slash_mode)
        Row(lid, next(index), "Brightness", self.slash_brightness)
        Row(lid, next(index), "Interval", self.slash_interval)
        for prop, switch in self.slash_switches.items():
            Row(lid, next(index), SLASH_SWITCH_LABELS[prop], switch)
        self.lid_frame = make_frame("Lid LEDs", lid)

        self.message = Gtk.Label(xalign=0, wrap=True)
        self.infobar = Gtk.InfoBar(show_close_button=True, no_show_all=True)
        self.infobar.get_content_area().add(self.message)
        self.message.show()
        self.infobar.connect("response", lambda bar, _: bar.hide())

        self.controls = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=12)
        self.controls.add(self.keyboard_frame)
        self.controls.add(self.lid_frame)
        root = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=12, margin=12)
        root.add(self.infobar)
        root.add(self.controls)
        self.add(root)

        self.bind(self.brightness, "changed", self.on_brightness)
        self.bind(self.effect, "changed", self.on_effect)
        self.bind(self.colour1, "color-set", self.on_mode_data)
        self.bind(self.colour2, "color-set", self.on_mode_data)
        self.bind(self.speed, "changed", self.on_mode_data)
        self.bind(self.direction, "changed", self.on_mode_data)
        for switch in self.power.values():
            self.bind(switch, "notify::active", self.on_power)
        self.bind(self.slash_enabled, "notify::active", self.on_slash_enabled)
        self.bind(self.slash_mode, "changed", self.on_slash_mode)
        self.bind(self.slash_brightness, "value-changed", self.on_slash_brightness)
        self.bind(self.slash_interval, "value-changed", self.on_slash_interval)
        for prop, switch in self.slash_switches.items():
            self.bind(switch, "notify::active", self.on_slash_switch, prop)

        self.connect("notify::is-active", self.on_active)
        self.connect("destroy", self.on_destroy)
        self.watch = Gio.bus_watch_name(
            Gio.BusType.SYSTEM,
            BUS_NAME,
            Gio.BusNameWatcherFlags.NONE,
            self.on_appeared,
            self.on_vanished,
        )
        self.controls.set_sensitive(False)

    def bind(self, widget, signal_name, handler, *args):
        self.bindings.append((widget, widget.connect(signal_name, handler, *args)))

    @contextlib.contextmanager
    def populating(self):
        for widget, handler in self.bindings:
            widget.handler_block(handler)
        try:
            yield
        finally:
            for widget, handler in self.bindings:
                widget.handler_unblock(handler)

    def show_message(self, text, kind):
        self.message.set_text(text)
        self.infobar.set_message_type(kind)
        self.infobar.show()

    def on_appeared(self, connection, name, owner):
        self.connection = connection
        try:
            self.gateway = Gateway.discover(system_bus_call(connection))
        except FAILURES as error:
            self.show_message(f"Discovery failed: {error}", Gtk.MessageType.ERROR)
            return
        self.subscription = connection.signal_subscribe(
            BUS_NAME,
            PROPERTIES,
            "PropertiesChanged",
            None,
            None,
            Gio.DBusSignalFlags.NONE,
            self.on_properties_changed,
        )
        self.infobar.hide()
        self.keyboard_frame.set_visible(Interface.AURA in self.gateway.available)
        self.lid_frame.set_visible(Interface.SLASH in self.gateway.available)
        if not self.gateway.available:
            self.show_message(
                "No ASUS lighting device was found.", Gtk.MessageType.WARNING
            )
        self.refresh()

    def on_vanished(self, connection, name):
        self.release_subscription()
        self.gateway = None
        self.controls.set_sensitive(False)
        self.show_message(
            "The ASUS daemon (asusd) is not running. Lighting controls are disabled.",
            Gtk.MessageType.WARNING,
        )

    def release_subscription(self):
        if self.subscription is not None and self.connection is not None:
            self.connection.signal_unsubscribe(self.subscription)
        self.subscription = None

    def on_destroy(self, *_):
        self.release_subscription()
        Gio.bus_unwatch_name(self.watch)
        for debounce in (
            self.slash_brightness_debounce,
            self.slash_interval_debounce,
        ):
            debounce.cancel()

    def on_properties_changed(self, connection, sender, path, interface, signal_name, parameters, *_):
        if self.gateway is None:
            return
        (name, _changed, _invalidated) = parameters.unpack()
        touched = self.gateway.interface_for(path, name)
        if touched is not None:
            self.refresh(touched)

    def on_active(self, *_):
        if self.is_active():
            self.refresh()

    def refresh(self, only=None):
        if self.gateway is None:
            return
        try:
            if Interface.AURA in self.gateway.available and only in (None, Interface.AURA):
                aura = self.gateway.read_aura()
                self.populate_aura(
                    aura, self.gateway.read_mode_data(aura.supported_modes)
                )
            if Interface.SLASH in self.gateway.available and only in (None, Interface.SLASH):
                self.populate_slash(self.gateway.read_slash())
        except FAILURES as error:
            self.controls.set_sensitive(False)
            self.show_message(f"Reading the lighting state failed: {error}", Gtk.MessageType.ERROR)
            return
        self.controls.set_sensitive(True)

    def apply(self, interface, setter, *args):
        if self.gateway is None:
            return
        try:
            setter(self.gateway, *args)
        except FAILURES as error:
            self.show_message(f"Write failed: {error}", Gtk.MessageType.ERROR)
        self.refresh(interface)

    def populate_aura(self, state, mode_data):
        self.aura = state
        self.mode_data = mode_data
        data = state.mode_data
        keyboard_power = state.power.keyboard
        with self.populating():
            self.brightness.set_options(state.supported_brightness)
            self.brightness.select(state.brightness)
            self.effect.set_options(state.supported_modes)
            self.effect.select(data.mode)
            self.colour1.set_rgba(to_rgba(data.colour1))
            self.colour2.set_rgba(to_rgba(data.colour2))
            self.speed.select(data.speed)
            self.direction.select(data.direction)
            for field, row in self.fields.items():
                row.set_visible(field in MODE_FIELDS[data.mode])
            for row in self.power_rows:
                row.set_visible(keyboard_power is not None)
            if keyboard_power is not None:
                for name, switch in self.power.items():
                    switch.set_active(getattr(keyboard_power, name))

    def populate_slash(self, state):
        with self.populating():
            self.slash_enabled.set_active(state.enabled)
            self.slash_mode.select(state.mode)
            if not self.slash_brightness_debounce.pending:
                self.slash_brightness.set_value(state.brightness)
            if not self.slash_interval_debounce.pending:
                self.slash_interval.set_value(state.interval)
            for prop, switch in self.slash_switches.items():
                switch.set_active(prop in state.shown)

    def on_brightness(self, *_):
        brightness = self.brightness.selected()
        if brightness is not None:
            self.apply(Interface.AURA, Gateway.set_brightness, brightness)

    def on_effect(self, *_):
        mode = self.effect.selected()
        if mode is None:
            return
        data = self.mode_data.get(mode) or replace(self.aura.mode_data, mode=mode)
        self.apply(Interface.AURA, Gateway.set_led_mode_data, data)

    def on_mode_data(self, *_):
        speed = self.speed.selected()
        direction = self.direction.selected()
        if speed is None or direction is None:
            return
        data = replace(
            self.aura.mode_data,
            colour1=from_rgba(self.colour1.get_rgba()),
            colour2=from_rgba(self.colour2.get_rgba()),
            speed=speed,
            direction=direction,
        )
        self.apply(Interface.AURA, Gateway.set_led_mode_data, data)

    def on_power(self, *_):
        flags = PowerFlags(
            **{name: switch.get_active() for name, switch in self.power.items()}
        )
        self.apply(
            Interface.AURA,
            Gateway.set_led_power,
            self.aura.power.with_keyboard(flags),
        )

    def on_slash_enabled(self, switch, _pspec):
        self.apply(
            Interface.SLASH,
            Gateway.set_slash,
            SlashProperty.ENABLED,
            switch.get_active(),
        )

    def on_slash_mode(self, *_):
        mode = self.slash_mode.selected()
        if mode is not None:
            self.apply(Interface.SLASH, Gateway.set_slash, SlashProperty.MODE, mode)

    def on_slash_brightness(self, scale):
        self.slash_brightness_debounce.schedule(int(scale.get_value()))

    def on_slash_interval(self, scale):
        self.slash_interval_debounce.schedule(int(scale.get_value()))

    def on_slash_switch(self, switch, _pspec, prop):
        self.apply(Interface.SLASH, Gateway.set_slash, prop, switch.get_active())


class LightingApp(Gtk.Application):
    def __init__(self):
        super().__init__(application_id="io.github.orhun.AsusLighting")
        self.window = None

    def do_activate(self):
        if self.window is None:
            self.window = LightingWindow(self)
            self.window.show_all()
        self.window.present()


if __name__ == "__main__":
    app = LightingApp()
    for signum in (signal.SIGINT, signal.SIGTERM):
        GLibUnix.signal_add(
            GLib.PRIORITY_DEFAULT,
            signum,
            lambda: app.quit() or GLib.SOURCE_REMOVE,
        )
    sys.exit(app.run(sys.argv))
