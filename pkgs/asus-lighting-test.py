import unittest
from dataclasses import replace

from gi.repository import GLib

from asus_lighting_core import (
    AURA_PATH_PREFIX,
    MODE_FIELDS,
    SLASH_SWITCHES,
    AuraState,
    Brightness,
    Direction,
    Field,
    Gateway,
    Interface,
    LedMode,
    LedModeData,
    LedPower,
    PowerEntry,
    PowerFlags,
    PowerZone,
    Rgb,
    SlashMode,
    SlashProperty,
    SlashState,
    Speed,
    Unavailable,
)


AURA_PATH = "/xyz/ljones/aura/19b6_2_6"
MODE_SIGNATURE = "(uu(yyy)(yyy)ss)"
POWER_SIGNATURE = "(a(ubbbb))"
LIVE_MODE = GLib.Variant(MODE_SIGNATURE, (0, 0, (0, 0, 0), (0, 0, 0), "Med", "Right"))
LIVE_POWER = GLib.Variant(POWER_SIGNATURE, ([(1, False, True, False, False)],))

SLASH_BYTES = {
    "STATIC": 0x06,
    "BOUNCE": 0x10,
    "SLASH": 0x12,
    "LOADING": 0x13,
    "BIT_STREAM": 0x1D,
    "TRANSMISSION": 0x1A,
    "FLOW": 0x19,
    "FLUX": 0x25,
    "PHANTOM": 0x24,
    "SPECTRUM": 0x26,
    "HAZARD": 0x32,
    "INTERFACING": 0x33,
    "RAMP": 0x34,
    "GAME_OVER": 0x42,
    "START": 0x43,
    "BUZZER": 0x44,
}


class WireTest(unittest.TestCase):
    def test_led_mode_data_round_trip(self):
        data = LedModeData.from_wire(LIVE_MODE.unpack())
        self.assertEqual(
            data,
            LedModeData(
                LedMode.STATIC, Rgb(0, 0, 0), Rgb(0, 0, 0), Speed.MED, Direction.RIGHT
            ),
        )
        self.assertEqual(data.to_variant(), LIVE_MODE)

    def test_led_mode_data_colours_round_trip(self):
        raw = GLib.Variant(
            MODE_SIGNATURE, (1, 0, (255, 16, 0), (0, 32, 255), "High", "Up")
        )
        data = LedModeData.from_wire(raw.unpack())
        self.assertEqual(data.colour1, Rgb(255, 16, 0))
        self.assertEqual(data.colour2, Rgb(0, 32, 255))
        self.assertEqual(data.to_variant(), raw)

    def test_led_mode_data_ignores_stored_zone(self):
        raw = GLib.Variant(MODE_SIGNATURE, (0, 7, (0, 0, 0), (0, 0, 0), "Med", "Right"))
        self.assertEqual(LedModeData.from_wire(raw.unpack()).to_variant(), LIVE_MODE)

    def test_unknown_mode_raises(self):
        raw = GLib.Variant(MODE_SIGNATURE, (4, 0, (0, 0, 0), (0, 0, 0), "Med", "Right"))
        with self.assertRaises(ValueError):
            LedModeData.from_wire(raw.unpack())

    def test_unknown_speed_raises(self):
        raw = GLib.Variant(MODE_SIGNATURE, (0, 0, (0, 0, 0), (0, 0, 0), "Fast", "Right"))
        with self.assertRaises(ValueError):
            LedModeData.from_wire(raw.unpack())

    def test_unknown_direction_raises(self):
        raw = GLib.Variant(MODE_SIGNATURE, (0, 0, (0, 0, 0), (0, 0, 0), "Med", "Sideways"))
        with self.assertRaises(ValueError):
            LedModeData.from_wire(raw.unpack())

    def test_led_power_round_trip(self):
        power = LedPower.from_wire(LIVE_POWER.unpack())
        self.assertEqual(
            power.entries,
            (PowerEntry(PowerZone.KEYBOARD, PowerFlags(False, True, False, False)),),
        )
        self.assertEqual(power.keyboard, PowerFlags(False, True, False, False))
        self.assertEqual(power.to_variant(), LIVE_POWER)

    def test_unknown_power_zone_raises(self):
        raw = GLib.Variant(POWER_SIGNATURE, ([(9, False, True, False, False)],))
        with self.assertRaises(ValueError):
            LedPower.from_wire(raw.unpack())

    def test_led_power_write_preserves_other_entries(self):
        raw = GLib.Variant(
            POWER_SIGNATURE,
            (
                [
                    (0, True, True, True, True),
                    (1, False, True, False, False),
                    (2, False, False, True, False),
                ],
            ),
        )
        power = LedPower.from_wire(raw.unpack())
        written = power.with_keyboard(PowerFlags(True, False, True, True))
        self.assertEqual(
            written.to_variant(),
            GLib.Variant(
                POWER_SIGNATURE,
                (
                    [
                        (0, True, True, True, True),
                        (1, True, False, True, True),
                        (2, False, False, True, False),
                    ],
                ),
            ),
        )
        self.assertEqual(written.entries[0], power.entries[0])
        self.assertEqual(written.entries[2], power.entries[2])

    def test_led_power_without_keyboard(self):
        raw = GLib.Variant(POWER_SIGNATURE, ([(2, False, True, False, False)],))
        power = LedPower.from_wire(raw.unpack())
        self.assertIsNone(power.keyboard)
        with self.assertRaises(LookupError):
            power.with_keyboard(PowerFlags(True, True, True, True))

    def test_slash_table(self):
        self.assertEqual(len(SlashMode), 16)
        self.assertEqual({mode.name: mode.value for mode in SlashMode}, SLASH_BYTES)
        for name, byte in SLASH_BYTES.items():
            self.assertIs(SlashMode(byte), SlashMode[name])
            self.assertEqual(SlashMode[name].value, byte)

    def test_unknown_slash_byte_raises(self):
        with self.assertRaises(ValueError):
            SlashMode(0x00)

    def test_unknown_slash_byte_in_state_raises(self):
        with self.assertRaises(ValueError):
            SlashState.from_wire(slash_properties(mode=0x00))

    def test_mode_fields(self):
        self.assertEqual(
            MODE_FIELDS,
            {
                LedMode.STATIC: {Field.COLOUR1},
                LedMode.BREATHE: {Field.COLOUR1, Field.COLOUR2, Field.SPEED},
                LedMode.RAINBOW_CYCLE: {Field.SPEED},
                LedMode.RAINBOW_WAVE: {Field.SPEED, Field.DIRECTION},
                LedMode.PULSE: {Field.COLOUR1},
            },
        )
        self.assertEqual(set(MODE_FIELDS), set(LedMode))

    def test_mode_values(self):
        self.assertEqual(
            {mode.name: mode.value for mode in LedMode},
            {
                "STATIC": 0,
                "BREATHE": 1,
                "RAINBOW_CYCLE": 2,
                "RAINBOW_WAVE": 3,
                "PULSE": 10,
            },
        )

    def test_slash_state(self):
        state = SlashState.from_wire(slash_properties())
        self.assertEqual(state.mode, SlashMode.BOUNCE)
        self.assertEqual(state.shown, frozenset(SLASH_SWITCHES) - {SlashProperty.SHOW_ON_SLEEP})


def slash_properties(mode=0x10):
    properties = {
        "Enabled": False,
        "Brightness": 255,
        "Interval": 0,
        "Mode": mode,
    }
    for prop in SLASH_SWITCHES:
        properties[prop.dbus_name] = prop is not SlashProperty.SHOW_ON_SLEEP
    return properties


class FakeBus:
    def __init__(self):
        self.calls = []
        self.stored = {}
        self.aura = {
            "Brightness": GLib.Variant("u", 3),
            "LedModeData": LIVE_MODE,
            "LedPower": LIVE_POWER,
            "SupportedBrightness": GLib.Variant("au", [0, 1, 2, 3]),
            "SupportedBasicModes": GLib.Variant("au", [0, 1, 2, 3, 10]),
        }
        self.slash = {
            name: GLib.Variant(prop.signature, value)
            for (name, value), prop in zip(
                slash_properties().items(),
                (
                    SlashProperty.ENABLED,
                    SlashProperty.BRIGHTNESS,
                    SlashProperty.INTERVAL,
                    SlashProperty.MODE,
                    *SLASH_SWITCHES,
                ),
            )
        }

    def tree(self):
        return {
            "/xyz/ljones": {
                "xyz.ljones.FanCurves": {},
                "xyz.ljones.Platform": {},
                "xyz.ljones.Backlight": {},
            },
            "/xyz/ljones/asus_armoury/ppt_pl1_spl": {"xyz.ljones.AsusArmoury": {}},
            "/xyz/ljones/asus_armoury/nv_tgp": {"xyz.ljones.AsusArmoury": {}},
            "/xyz/ljones/asus_armoury/gpu_mux_mode": {"xyz.ljones.AsusArmoury": {}},
            AURA_PATH: {"xyz.ljones.Aura": {}, "xyz.ljones.Slash": {}},
        }

    def __call__(self, path, interface, method, parameters):
        self.calls.append((path, interface, method, parameters))
        if method == "GetManagedObjects":
            return GLib.Variant("(a{oa{sa{sv}}})", (self.tree(),))
        if method == "GetAll":
            (name,) = parameters.unpack()
            properties = {"xyz.ljones.Aura": self.aura, "xyz.ljones.Slash": self.slash}[name]
            return GLib.Variant("(a{sv})", (properties,))
        if method == "Set":
            name, prop, value = parameters.unpack()
            self.stored[(name, prop)] = parameters.get_child_value(2).get_variant()
            return GLib.Variant("()", ())
        if method == "AllModeData":
            return GLib.Variant(
                "(a{u" + MODE_SIGNATURE + "})",
                (
                    {
                        0: (0, 0, (1, 2, 3), (0, 0, 0), "Med", "Right"),
                        1: (1, 0, (4, 5, 6), (7, 8, 9), "Low", "Left"),
                        9: (9, 0, (0, 0, 0), (0, 0, 0), "Med", "Right"),
                    },
                ),
            )
        raise AssertionError(f"unexpected call {interface}.{method}")

    def targets(self):
        for path, interface, method, parameters in self.calls:
            if interface == "org.freedesktop.DBus.Properties":
                yield path, parameters.unpack()[0], method
            else:
                yield path, interface, method


class GatewayTest(unittest.TestCase):
    def setUp(self):
        self.bus = FakeBus()
        self.gateway = Gateway.discover(self.bus)

    def test_discovery_finds_only_aura_objects(self):
        self.assertEqual(
            self.gateway.paths,
            {Interface.AURA: AURA_PATH, Interface.SLASH: AURA_PATH},
        )
        self.assertTrue(AURA_PATH.startswith(AURA_PATH_PREFIX))

    def test_discovery_requires_the_interface(self):
        class AuraOnly(FakeBus):
            def tree(self):
                tree = super().tree()
                tree[AURA_PATH] = {"xyz.ljones.Aura": {}}
                return tree

        gateway = Gateway.discover(AuraOnly())
        self.assertEqual(gateway.available, {Interface.AURA})
        with self.assertRaises(Unavailable):
            gateway.read_slash()

    def test_discovery_ignores_other_trees(self):
        class Foreign(FakeBus):
            def tree(self):
                return {
                    "/xyz/ljones": {"xyz.ljones.Aura": {}, "xyz.ljones.Slash": {}},
                    "/xyz/ljones/asus_armoury/x": {"xyz.ljones.Aura": {}},
                }

        self.assertEqual(Gateway.discover(Foreign()).available, frozenset())

    def test_readers(self):
        aura = self.gateway.read_aura()
        self.assertEqual(
            aura,
            AuraState(
                Brightness.HIGH,
                LedModeData.from_wire(LIVE_MODE.unpack()),
                LedPower.from_wire(LIVE_POWER.unpack()),
                tuple(Brightness),
                tuple(LedMode),
            ),
        )
        stored = self.gateway.read_mode_data(aura.supported_modes)
        self.assertEqual(set(stored), {LedMode.STATIC, LedMode.BREATHE})
        self.assertEqual(stored[LedMode.BREATHE].colour2, Rgb(7, 8, 9))
        self.assertEqual(stored[LedMode.BREATHE].direction, Direction.LEFT)
        slash = self.gateway.read_slash()
        self.assertEqual(slash.mode, SlashMode.BOUNCE)
        self.assertEqual(slash.brightness, 255)

    def test_setters_encode_properties(self):
        data = replace(
            LedModeData.from_wire(LIVE_MODE.unpack()),
            mode=LedMode.PULSE,
            colour1=Rgb(10, 20, 30),
        )
        power = LedPower.from_wire(LIVE_POWER.unpack()).with_keyboard(
            PowerFlags(True, True, True, True)
        )
        self.gateway.set_brightness(Brightness.LOW)
        self.gateway.set_led_mode_data(data)
        self.gateway.set_led_power(power)
        self.gateway.set_slash(SlashProperty.ENABLED, True)
        self.gateway.set_slash(SlashProperty.BRIGHTNESS, 128)
        self.gateway.set_slash(SlashProperty.INTERVAL, 5)
        self.gateway.set_slash(SlashProperty.MODE, SlashMode.GAME_OVER)
        for prop in SLASH_SWITCHES:
            self.gateway.set_slash(prop, False)
        aura, slash = "xyz.ljones.Aura", "xyz.ljones.Slash"
        self.assertEqual(self.bus.stored[(aura, "Brightness")], GLib.Variant("u", 1))
        self.assertEqual(self.bus.stored[(aura, "LedModeData")], data.to_variant())
        self.assertEqual(self.bus.stored[(aura, "LedPower")], power.to_variant())
        self.assertEqual(self.bus.stored[(slash, "Enabled")], GLib.Variant("b", True))
        self.assertEqual(self.bus.stored[(slash, "Brightness")], GLib.Variant("y", 128))
        self.assertEqual(self.bus.stored[(slash, "Interval")], GLib.Variant("y", 5))
        self.assertEqual(self.bus.stored[(slash, "Mode")], GLib.Variant("y", 0x42))
        for prop in SLASH_SWITCHES:
            self.assertEqual(self.bus.stored[(slash, prop.dbus_name)], GLib.Variant("b", False))

    def test_interval_out_of_range_raises(self):
        with self.assertRaises(ValueError):
            self.gateway.set_slash(SlashProperty.INTERVAL, 6)
        self.assertEqual(self.bus.stored, {})

    def test_only_lighting_objects_are_addressed(self):
        data = LedModeData.from_wire(LIVE_MODE.unpack())
        power = LedPower.from_wire(LIVE_POWER.unpack())
        self.gateway.read_aura()
        self.gateway.read_mode_data(tuple(LedMode))
        self.gateway.read_slash()
        self.gateway.set_brightness(Brightness.MED)
        self.gateway.set_led_mode_data(data)
        self.gateway.set_led_power(power)
        for prop in SlashProperty:
            self.gateway.set_slash(prop, SlashMode.FLOW if prop is SlashProperty.MODE else 1)
        recorded = list(self.bus.targets())
        root, *rest = recorded
        self.assertEqual(root, ("/", "org.freedesktop.DBus.ObjectManager", "GetManagedObjects"))
        self.assertEqual(len(rest), 16)
        for path, interface, _method in rest:
            self.assertEqual(path, AURA_PATH)
            self.assertIn(interface, {"xyz.ljones.Aura", "xyz.ljones.Slash"})
        self.assertEqual(
            {method for _path, _interface, method in rest}, {"GetAll", "Set", "AllModeData"}
        )
        written = {prop for (_name, prop) in self.bus.stored}
        self.assertEqual(written, {"Brightness", "LedModeData", "LedPower"} | {p.dbus_name for p in SlashProperty})
        self.assertTrue(
            written.isdisjoint({"LedMode", "PlatformProfile", "FanCurveData", "FanCurvesEnabled"})
        )

    def test_enums_expose_only_lighting_interfaces(self):
        self.assertEqual(
            {interface.value for interface in Interface},
            {"xyz.ljones.Aura", "xyz.ljones.Slash"},
        )

    def test_interface_for_matches_path_and_name(self):
        self.assertIs(
            self.gateway.interface_for(AURA_PATH, "xyz.ljones.Slash"), Interface.SLASH
        )
        self.assertIsNone(self.gateway.interface_for("/xyz/ljones", "xyz.ljones.Aura"))
        self.assertIsNone(self.gateway.interface_for(AURA_PATH, "xyz.ljones.Platform"))


if __name__ == "__main__":
    unittest.main()
