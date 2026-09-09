# Control Center Quickshell Handoff

## Purpose

This document specifies the Eww replacement. Read
`CONTROL_CENTER_IMPLEMENTATION_HANDOFF.md` first.

## Technology Decision

Use Quickshell 0.3.1. Do not use an older Quickshell API.

AGS 3 with GTK4 is the fallback. Do not use AGS version 1 examples. Current
AGS uses GJS, TypeScript, Gnim, and Astal libraries.

## Decision Reasons

Quickshell provides a Qt Quick scene graph. Qt Quick provides direct state,
layout, clipping, and animation controls.

Quickshell provides first-party Hyprland, layer-shell, IPC, NetworkManager,
Bluetooth, and PipeWire APIs.

AGS provides more service libraries. AGS still uses GTK rendering, which is
closer to the current Eww rendering path.

The rendering test decides the final choice. A toolkit name does not prove
correct Wayland damage.

## Migration Boundary

Replace the control center first. Do not replace all desktop components in the
first migration.

The Eww repository also contains standalone brightness, calendar, and power
windows. Confirm their active callers before you remove Eww.

## Required Rendering Test

Build a Quickshell fixture before production UI work.

The fixture must contain these items:

- One transparent `PanelWindow`
- Namespace `control_center`
- Fixed size `400x940`
- One low-alpha dynamic sheet
- Two higher-alpha controls
- One 300 ms reveal
- One movable control
- One IPC controller

Run the fixture in the existing nested Hyprland harness. Do not use the live
desktop for this gate.

The fixture must pass these operations:

1. Open the panel.
2. Reveal the dynamic section.
3. Hide the dynamic section.
4. Move one control.
5. Repeat open and close operations.
6. Compare a natural frame with a fresh frame.
7. Confirm the old control position becomes raw.
8. Confirm the new control position becomes glass.

If Quickshell fails, diagnose the damage path. Do not select AGS before the
failure cause is known.

## Nix Package

Pin Quickshell 0.3.1 through its upstream flake. Make its `nixpkgs` input follow
the repository `nixpkgs` input.

Use a tagged release. Do not track the Quickshell master branch for this work.

The official source is:

```text
github:quickshell-mirror/quickshell?ref=v0.3.1
```

Confirm the exact tag name before you edit `flake.lock`.

## Proposed File Layout

Use one clear QML root under the dotfiles repository. Follow the existing XDG
deployment pattern.

Suggested paths:

```text
.config/quickshell/shell.qml
.config/quickshell/ControlCenter.qml
.config/quickshell/ControlCenterState.qml
.config/quickshell/Theme.qml
.config/quickshell/components/
.config/quickshell/services/
```

Do not create small files without a reusable boundary. Keep one component in
one file when the component has independent state or tests.

## Window Architecture

Create one control-center `PanelWindow` with these properties:

| Property | Value |
|---|---|
| Namespace | `control_center` |
| Width | 400 logical pixels |
| Height | 940 logical pixels |
| Top margin | 2 logical pixels |
| Right margin | 3 logical pixels |
| Anchors | Top and right |
| Layer | Overlay |
| Exclusive zone | None |
| Default keyboard focus | None |
| Root color | Transparent |

Keep the fixed height. Animate content inside the surface. Do not resize the
layer during each reveal frame.

## Outside-Click Surface

Create one full-screen `PanelWindow` below the control center. Use namespace
`control_center_closer`.

Open the closer before the panel. Close the closer after the panel close
animation completes.

The closer must handle left, middle, and right clicks. Each click must close
the panel and stop at the closer.

Clean an orphaned closer during startup and each toggle operation.

Do not use an exclusive keyboard grab for normal panel operation.

## Panel State

Use one state object for these values:

| State | Values |
|---|---|
| Panel state | Closed, opening, open, closing |
| Active menu | None, Wi-Fi, Bluetooth, USB |
| Power section | Open or closed |
| Password prompt | Closed or one selected network |
| Password visibility | Hidden or shown |

Use enums or constrained values. Do not store menu state in an arbitrary
string when QML supports a safer representation.

Only one dynamic menu can be open. A menu change must cancel the Wi-Fi prompt.

## IPC Contract

Use `IpcHandler` for external control. Create one target named
`controlCenter`.

Provide these functions:

```text
open(): void
close(): void
toggle(): void
setMenu(menu: string): bool
isOpen(): bool
activeMenu(): string
wifiReady(): bool
reset(): void
```

Reject an unknown menu. Do not convert an unknown menu to the empty menu.

Create a toolkit-neutral command named `control-center-toggle`. Waybar and live
tests must call this command.

The wrapper must support these operations:

```text
control-center-toggle
control-center-toggle open
control-center-toggle close
control-center-toggle menu wifi
control-center-toggle status
```

Do not preserve an Eww-compatible command surface after migration tests pass.
Update each caller to the generic command.

## Startup

Use a supervised user service when the current session environment supports
it. Tie the service to the graphical session.

Use `Restart=on-failure`. Do not add a loop that starts multiple shell
instances.

Provide one readiness check through Quickshell IPC. The toggle wrapper can
start or wait for the service when required.

Remove the Eww daemon restart logic only after the Quickshell service passes
sleep and wake tests.

## Layout to Preserve

The control center contains these sections in this order:

1. Wi-Fi and Bluetooth quick settings
2. USB and DND quick settings
3. One selected dynamic menu
4. Brightness control
5. Volume control
6. Expandable power section

Preserve the current two-column quick-setting grid. Preserve split actions for
Wi-Fi and Bluetooth.

The icon side changes radio power. The text side changes the active menu.

## Alpha Contract

The transparent root must paint no pixels. The unused fixed-height area must
remain transparent.

Paint one continuous sheet behind the current visible content. Use an initial
alpha of `0.012`.

Use these current control values as the visual baseline:

| Material | Current alpha |
|---|---|
| Normal control | `0.08` |
| Active control | `0.48` |
| Footer control | `0.06` |

The sheet alpha must remain above `mask_threshold`. The sheet alpha must remain
below `pill.threshold`.

The sheet width and height must follow current content. The sheet must not fill
the complete `400x940` surface.

## Sheet Geometry

Use one rounded sheet item behind the content. Bind its size to the visible
content container.

The Hyprglass background field creates the feather. Do not blur the QML item.
Do not create stacked inset rectangles.

Use the sheet color as an intentional tint. Test the tint over a light
background and a dark background.

## Animation

Use a clipped-height animation for panel open and close. Use 250 ms as the
initial duration.

Use a clipped-height animation for menu sections. Use 300 ms as the initial
duration.

Use a 200 ms animation for the Wi-Fi password section.

Keep animation state interruptible. A close request during open must reverse
from the current value.

Do not unmap the panel before the close animation completes. Do not add a fixed
delay that can close a newly reopened panel.

Use a generation token or explicit state transition to reject stale close
callbacks.

## Keyboard Focus

Keep keyboard focus disabled during normal panel use. Enable on-demand focus
only while the password field needs input.

First test a dynamic `WlrLayershell.keyboardFocus` change on the same panel.
Request focus for the password field after the change.

If Hyprland cannot apply the change safely, use two panel instances as the Eww
implementation does. Do not select the two-instance design before the test.

Release focus when the prompt closes. Clear focus when another menu opens.

## Wi-Fi Service

Use `Quickshell.Networking` for Wi-Fi state and actions.

Preserve these behaviors:

- Show enabled state, SSID, signal, and IP address.
- Exclude the active SSID from the available list.
- Group duplicate access points by SSID.
- Sort networks by signal.
- Show at most six networks.
- Connect known profiles without a new password.
- Connect open networks directly.
- Use `connectWithPsk()` for new secured networks.
- Send enterprise networks to `nm-connection-editor`.
- Keep the password after a wrong-password result.
- Clear the password after success, cancel, or unrelated failure.

Do not send the password through command-line arguments. Do not expose the
password through IPC.

## Bluetooth Service

Use `Quickshell.Bluetooth` for adapter and device state.

Show paired devices first. Show connection state and battery when available.

Keep discovery and complex pairing in Overskride. Preserve the current
Overskride handoff.

Bound each connection action. Display an error when a device does not respond.

## Audio Service

Use `Quickshell.Services.Pipewire`. Track the default audio sink with the
required `PwObjectTracker`.

Preserve a maximum volume of 100 percent. Preserve mute state and immediate
slider feedback.

Do not poll `wpctl` after the PipeWire service works correctly.

## Brightness Service

Quickshell 0.3.1 has no required built-in brightness service for this plan.
Use `brightnessctl` through a small toolkit-neutral adapter.

Preserve a minimum brightness of 1 percent. Update the slider immediately.

Avoid one process for each pointer-motion event. Coalesce rapid writes when
the slider generates more changes than the command can process.

## USB Service

Keep a toolkit-neutral helper for removable media. Remove each `eww update`
call from the helper.

Preserve these backends:

- `lsblk` for device data
- UDisks2 for mount and unmount
- `udisksctl` for power off
- Kitty and Yazi for browse
- GNOME Disks for detailed management

The QML service must parse structured JSON. Do not parse formatted user text.

## DND Service

Keep SwayNC as the notification service. The control center manages only DND.

Read DND events from `swaync-client -s`. Toggle DND with `swaync-client -d`.

Opening the control center must close the SwayNC panel. Opening SwayNC must
close the control center without opening it.

## Power Actions

Preserve these actions:

- Suspend
- Hibernate
- Power off

Close the panel before each action. Start the system command only after the
close request succeeds.

## External Handoffs

Preserve these programs:

- `nm-connection-editor`
- `overskride`
- `gnome-disks`
- `kitty --title usb-browse -e yazi`

Close the panel before each external program starts.

## Theme

Move color and measurement values into one QML theme object. Do not duplicate
the same color in each component.

Read the active values from these files:

- `/home/orhun/.config/eww/styles/_colors.scss`
- `/home/orhun/.config/eww/styles/_overrides.scss`
- `/home/orhun/Documents/dotfiles/.config/eww/styles/`

The live override is evidence. Convert accepted values into declarative
dotfiles configuration.

Do not require a hand-owned QML override for the first production version.

## Eww Files to Replace

The migration affects these source groups:

- `.config/eww/widgets/control-center.yuck`
- `.config/eww/widgets/wifi.yuck`
- `.config/eww/widgets/bluetooth.yuck`
- `.config/eww/widgets/usb.yuck`
- `.config/eww/styles/control-center.scss`
- `.config/eww/styles/wifi.scss`
- `.config/eww/styles/bluetooth.scss`
- `.config/eww/styles/usb.scss`
- `.local/bin/eww-control-center-toggle`
- `.local/bin/eww-ensure-daemon`
- `.local/bin/eww-wifi`
- `.local/bin/eww-bluetooth`
- `.local/bin/eww-usb`
- `.local/bin/eww-volume`
- `.local/bin/eww-brightness`

Do not delete a helper until its replacement passes tests.

## External Callers

Update these locations during the integration phase:

- `modules/home/linux/_hyprland/waybar.nix`
- `modules/home/linux/_hyprland/hyprland.nix`
- `modules/home/linux/_hyprland/autostart.nix`
- `modules/nixos/odyssey/boot.nix`
- `modules/home/linux/xdg-configs.nix`
- `modules/home/linux/gui-apps.nix`
- `/home/orhun/Documents/hyprglass/tests/live/90-cc-holes.sh`

Search again before removal. A new caller can exist after this handoff date.

## Quickshell Acceptance Criteria

1. The panel uses exactly one normal control-center surface.
2. The closer uses exactly one full-screen surface.
3. The panel opens and closes without a blink.
4. Each menu changes the outer sheet boundary.
5. The normal panel does not take keyboard focus.
6. The password field can take and release focus.
7. An outside click closes the panel.
8. Wi-Fi password data does not enter process arguments.
9. Wi-Fi, Bluetooth, audio, brightness, USB, and DND actions work.
10. SwayNC and the control center cannot remain open together.
11. Sleep and wake do not create a second shell process.
12. The fixed transparent area does not become a gray rectangle.
13. The shell uses no screenshot backdrop.
14. The shell passes the nested damage tests.
