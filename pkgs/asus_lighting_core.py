import enum
from collections.abc import Callable, Mapping
from dataclasses import astuple, dataclass, replace

from gi.repository import Gio, GLib


BUS_NAME = "xyz.ljones.Asusd"
ROOT_PATH = "/"
AURA_PATH_PREFIX = "/xyz/ljones/aura/"
OBJECT_MANAGER = "org.freedesktop.DBus.ObjectManager"
PROPERTIES = "org.freedesktop.DBus.Properties"
CALL_TIMEOUT_MS = 3000
SLASH_INTERVAL_MAX = 5
ZONE = 0

BusCall = Callable[[str, str, str, GLib.Variant | None], GLib.Variant]


class Interface(enum.Enum):
    AURA = "xyz.ljones.Aura"
    SLASH = "xyz.ljones.Slash"


class Property(enum.Enum):
    def __init__(self, dbus_name, signature):
        self.dbus_name = dbus_name
        self.signature = signature


class AuraProperty(Property):
    BRIGHTNESS = ("Brightness", "u")
    LED_MODE_DATA = ("LedModeData", "(uu(yyy)(yyy)ss)")
    LED_POWER = ("LedPower", "(a(ubbbb))")


class SlashProperty(Property):
    ENABLED = ("Enabled", "b")
    BRIGHTNESS = ("Brightness", "y")
    INTERVAL = ("Interval", "y")
    MODE = ("Mode", "y")
    SHOW_ON_BOOT = ("ShowOnBoot", "b")
    SHOW_ON_SHUTDOWN = ("ShowOnShutdown", "b")
    SHOW_ON_SLEEP = ("ShowOnSleep", "b")
    SHOW_ON_BATTERY = ("ShowOnBattery", "b")
    SHOW_BATTERY_WARNING = ("ShowBatteryWarning", "b")
    SHOW_ON_LID_CLOSED = ("ShowOnLidClosed", "b")


SLASH_SWITCHES = (
    SlashProperty.SHOW_ON_BOOT,
    SlashProperty.SHOW_ON_SHUTDOWN,
    SlashProperty.SHOW_ON_SLEEP,
    SlashProperty.SHOW_ON_BATTERY,
    SlashProperty.SHOW_BATTERY_WARNING,
    SlashProperty.SHOW_ON_LID_CLOSED,
)

INTERFACE_OF = {
    AuraProperty: Interface.AURA,
    SlashProperty: Interface.SLASH,
}


class Brightness(enum.Enum):
    OFF = 0
    LOW = 1
    MED = 2
    HIGH = 3


class LedMode(enum.Enum):
    STATIC = 0
    BREATHE = 1
    RAINBOW_CYCLE = 2
    RAINBOW_WAVE = 3
    PULSE = 10


class Speed(enum.Enum):
    LOW = "Low"
    MED = "Med"
    HIGH = "High"


class Direction(enum.Enum):
    RIGHT = "Right"
    LEFT = "Left"
    UP = "Up"
    DOWN = "Down"


class Field(enum.Enum):
    COLOUR1 = enum.auto()
    COLOUR2 = enum.auto()
    SPEED = enum.auto()
    DIRECTION = enum.auto()


MODE_FIELDS = {
    LedMode.STATIC: frozenset({Field.COLOUR1}),
    LedMode.BREATHE: frozenset({Field.COLOUR1, Field.COLOUR2, Field.SPEED}),
    LedMode.RAINBOW_CYCLE: frozenset({Field.SPEED}),
    LedMode.RAINBOW_WAVE: frozenset({Field.SPEED, Field.DIRECTION}),
    LedMode.PULSE: frozenset({Field.COLOUR1}),
}


class PowerZone(enum.Enum):
    LOGO = 0
    KEYBOARD = 1
    LIGHTBAR = 2
    LID = 3
    REAR_GLOW = 4
    KEYBOARD_AND_LIGHTBAR = 5
    ALLY = 6
    NONE = 255


class SlashMode(enum.Enum):
    STATIC = 0x06
    BOUNCE = 0x10
    SLASH = 0x12
    LOADING = 0x13
    BIT_STREAM = 0x1D
    TRANSMISSION = 0x1A
    FLOW = 0x19
    FLUX = 0x25
    PHANTOM = 0x24
    SPECTRUM = 0x26
    HAZARD = 0x32
    INTERFACING = 0x33
    RAMP = 0x34
    GAME_OVER = 0x42
    START = 0x43
    BUZZER = 0x44


@dataclass(frozen=True)
class Rgb:
    red: int
    green: int
    blue: int


@dataclass(frozen=True)
class LedModeData:
    mode: LedMode
    colour1: Rgb
    colour2: Rgb
    speed: Speed
    direction: Direction

    @classmethod
    def from_wire(cls, raw):
        mode, _zone, colour1, colour2, speed, direction = raw
        return cls(
            LedMode(mode),
            Rgb(*colour1),
            Rgb(*colour2),
            Speed(speed),
            Direction(direction),
        )

    def to_variant(self):
        return GLib.Variant(
            AuraProperty.LED_MODE_DATA.signature,
            (
                self.mode.value,
                ZONE,
                astuple(self.colour1),
                astuple(self.colour2),
                self.speed.value,
                self.direction.value,
            ),
        )


@dataclass(frozen=True)
class PowerFlags:
    boot: bool
    awake: bool
    sleep: bool
    shutdown: bool


@dataclass(frozen=True)
class PowerEntry:
    zone: PowerZone
    flags: PowerFlags


@dataclass(frozen=True)
class LedPower:
    entries: tuple[PowerEntry, ...]

    @classmethod
    def from_wire(cls, raw):
        (entries,) = raw
        return cls(
            tuple(
                PowerEntry(PowerZone(zone), PowerFlags(*flags))
                for zone, *flags in entries
            )
        )

    @property
    def keyboard(self):
        return next(
            (
                entry.flags
                for entry in self.entries
                if entry.zone is PowerZone.KEYBOARD
            ),
            None,
        )

    def with_keyboard(self, flags):
        if self.keyboard is None:
            raise LookupError("No keyboard power entry")
        return LedPower(
            tuple(
                replace(entry, flags=flags) if entry.zone is PowerZone.KEYBOARD else entry
                for entry in self.entries
            )
        )

    def to_variant(self):
        return GLib.Variant(
            AuraProperty.LED_POWER.signature,
            ([(entry.zone.value, *astuple(entry.flags)) for entry in self.entries],),
        )


@dataclass(frozen=True)
class AuraState:
    brightness: Brightness
    mode_data: LedModeData
    power: LedPower
    supported_brightness: tuple[Brightness, ...]
    supported_modes: tuple[LedMode, ...]

    @classmethod
    def from_wire(cls, raw):
        return cls(
            Brightness(raw["Brightness"]),
            LedModeData.from_wire(raw["LedModeData"]),
            LedPower.from_wire(raw["LedPower"]),
            tuple(Brightness(value) for value in raw["SupportedBrightness"]),
            tuple(LedMode(value) for value in raw["SupportedBasicModes"]),
        )


@dataclass(frozen=True)
class SlashState:
    enabled: bool
    brightness: int
    interval: int
    mode: SlashMode
    shown: frozenset[SlashProperty]

    @classmethod
    def from_wire(cls, raw):
        return cls(
            raw[SlashProperty.ENABLED.dbus_name],
            raw[SlashProperty.BRIGHTNESS.dbus_name],
            raw[SlashProperty.INTERVAL.dbus_name],
            SlashMode(raw[SlashProperty.MODE.dbus_name]),
            frozenset(prop for prop in SLASH_SWITCHES if raw[prop.dbus_name]),
        )


def encode_slash(prop, value):
    if isinstance(value, SlashMode):
        value = value.value
    if prop is SlashProperty.INTERVAL and not 0 <= value <= SLASH_INTERVAL_MAX:
        raise ValueError(f"Interval {value} is outside 0-{SLASH_INTERVAL_MAX}")
    return GLib.Variant(prop.signature, value)


class Unavailable(LookupError):
    pass


class Gateway:
    def __init__(self, call: BusCall, paths: Mapping[Interface, str]):
        self.call = call
        self.paths = dict(paths)

    @classmethod
    def discover(cls, call: BusCall):
        (managed,) = call(
            ROOT_PATH, OBJECT_MANAGER, "GetManagedObjects", None
        ).unpack()
        paths = {}
        for interface in Interface:
            candidates = sorted(
                path
                for path, interfaces in managed.items()
                if path.startswith(AURA_PATH_PREFIX) and interface.value in interfaces
            )
            if candidates:
                paths[interface] = candidates[0]
        return cls(call, paths)

    @property
    def available(self):
        return frozenset(self.paths)

    def interface_for(self, path, name):
        return next(
            (
                interface
                for interface, known in self.paths.items()
                if known == path and interface.value == name
            ),
            None,
        )

    def path(self, interface):
        try:
            return self.paths[interface]
        except KeyError:
            raise Unavailable(f"{interface.value} is not provided") from None

    def get_all(self, interface):
        (properties,) = self.call(
            self.path(interface),
            PROPERTIES,
            "GetAll",
            GLib.Variant("(s)", (interface.value,)),
        ).unpack()
        return properties

    def write(self, prop, value):
        interface = INTERFACE_OF[type(prop)]
        self.call(
            self.path(interface),
            PROPERTIES,
            "Set",
            GLib.Variant("(ssv)", (interface.value, prop.dbus_name, value)),
        )

    def read_aura(self):
        return AuraState.from_wire(self.get_all(Interface.AURA))

    def read_mode_data(self, supported: tuple[LedMode, ...]):
        (stored,) = self.call(
            self.path(Interface.AURA), Interface.AURA.value, "AllModeData", None
        ).unpack()
        return {
            mode: LedModeData.from_wire(stored[mode.value])
            for mode in supported
            if mode.value in stored
        }

    def read_slash(self):
        return SlashState.from_wire(self.get_all(Interface.SLASH))

    def set_brightness(self, brightness: Brightness):
        self.write(AuraProperty.BRIGHTNESS, GLib.Variant("u", brightness.value))

    def set_led_mode_data(self, data: LedModeData):
        self.write(AuraProperty.LED_MODE_DATA, data.to_variant())

    def set_led_power(self, power: LedPower):
        self.write(AuraProperty.LED_POWER, power.to_variant())

    def set_slash(self, prop: SlashProperty, value: bool | int | SlashMode):
        self.write(prop, encode_slash(prop, value))


def system_bus_call(connection) -> BusCall:
    def call(path, interface, method, parameters):
        return connection.call_sync(
            BUS_NAME,
            path,
            interface,
            method,
            parameters,
            None,
            Gio.DBusCallFlags.NONE,
            CALL_TIMEOUT_MS,
            None,
        )

    return call
