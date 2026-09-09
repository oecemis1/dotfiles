# Control Center Implementation Progress Handoff

## Purpose

This file records implementation work completed on 2026-08-29. Read the four
approved control-center handoff documents before this file. Treat current
source and Git diffs as authoritative when they differ from this report.

## Completed Milestones

### Test Baseline Stabilization

The first implementation milestone is complete.

1. `tests/lib.sh` now keys the implicit plugin cache by a SHA-256 hash of the
   plugin Makefile and C++ source files.
2. An explicit `HG_TEST_SO` still selects a supplied plugin.
3. An old path-only `.hg-test-so` cache entry is rejected.
4. The nested fixture disables VFR with `debug.vfr = false`.
5. `make test` runs tier-zero and nested tests. It does not run live tests.

The approved handoff specified `misc:vfr`. The installed Hyprland reports the
current key as `debug:vfr`. `misc.vfr` caused emergency mode and invalidated
five screenshot tests. The current key fixed all failures.

### Quickshell Rendering Gate

The Quickshell 0.3.1 nested rendering gate is complete.

The fixture contains:

- One transparent `PanelWindow`
- Namespace `control_center`
- Exact geometry `400x940` at top-right with top margin 2 and right margin 3
- One low-alpha dynamic sheet
- Two higher-alpha controls
- One movable control
- One interruptible 300 ms clipped-height reveal
- One typed `IpcHandler` target named `controlCenter`

The rendering test confirms:

1. The Quickshell process remains alive.
2. The `control_center` layer maps exactly once.
3. The fixed unused surface area remains transparent.
4. The reveal produces an intermediate frame.
5. The natural final frame matches a freshly damaged frame.
6. Moving a control clears its old glass position and glasses its new position.
7. An unknown menu is rejected without changing state.
8. Three repeated open and close cycles leave no layer surface.
9. The isolated Quickshell process and runtime directory are removed after the
   test.

The fixture uses a separate short `XDG_RUNTIME_DIR` under `/tmp/opencode`.
Cache, data, state, standard output, and standard error remain in the test
artifact directory. IPC uses the exact fixture path with `--newest` and
`--any-display`. The isolated runtime prevents selection of a live instance.

## Quickshell Pin

The dotfiles flake now pins the approved release:

```text
github:quickshell-mirror/quickshell?ref=v0.3.1
```

The lock resolves revision:

```text
1a4716cde794a59928d9d9fc15f2afc7a95de360
```

Its `nixpkgs` input follows the dotfiles `nixpkgs` input. The test harness
builds this pinned package directly. Home Manager now declares the package and
user service, but neither has been activated in the live system.

## Hyprglass Background-Distance Field

The Hyprglass background-distance milestone is complete.

The plugin now provides these Lua-only layer settings:

```lua
hg.layer("control_center", {
  background = true,
  background_fade = 24,
  live_blur = true,
})
```

The implementation contains:

1. A validated semantic fade-width type that rejects negative, non-finite, and
   out-of-range values.
2. Strict Lua boolean parsing for `live_blur`.
3. Replacement semantics that remove omitted fade and live-blur values.
4. A generalized alpha-distance JFA with optional outer-border seeds.
5. An independent background field on texture unit 6. The pill field remains
   on texture unit 5.
6. Base-sheet-only coverage. Pills, declared regions, ordinary no-fade layers,
   and normal windows retain full coverage.
7. A `background_field` grayscale debug mode.
8. Reusable background JFA framebuffers and nearest-neighbor packed-field
   reads.
9. Old-box and new-box damage after layer movement or size changes.
10. Transformed sampling geometry in the blur cache key.
11. Damage-driven live background resampling without a plugin timer.

The nested tests use a deterministic 8-pixel checkerboard. They cover static
fade profiles, all four field borders, Quickshell reveal and collapse, close and
reopen cleanup, live and cached blur, invalid input, duplicate replacement,
pill-boundary stability, zero-fade behavior, ordinary layers, and a normal
Kitty window.

## Files Changed By This Work

### Hyprglass Repository

- `Makefile`
- `tests/lib.sh`
- `tests/nested/conf/hyprland-test.lua`
- `tests/nested/conf/variants/19-quickshell.lua`
- `tests/nested/quickshell/shell.qml`
- `tests/nested/27-quickshell-rendering.sh`
- `README.md`
- `src/Globals.hpp`
- `src/GlassLayerSurface.hpp`
- `src/GlassLayerSurface.cpp`
- `src/GlassRenderer.hpp`
- `src/GlassRenderer.cpp`
- `src/PluginConfig.hpp`
- `src/PluginConfig.cpp`
- `src/ShaderManager.hpp`
- `src/ShaderManager.cpp`
- `src/Shaders.hpp`
- `src/main.cpp`
- `tests/tier0/04-jfa-contract.sh`
- `tests/nested/28-green-background-fade.sh`
- `tests/nested/29-green-background-fade-dynamic.sh`
- `tests/nested/36-red-background-jfa-field.sh`
- `tests/nested/37-red-background-config.sh`
- `tests/nested/38-red-live-blur-cache.sh`
- `tests/nested/39-red-background-regressions.sh`
- `tests/nested/40-quickshell-production-shell.sh`
- `tests/nested/41-quickshell-brightness.sh`
- `tests/nested/42-quickshell-audio.sh`
- `tests/nested/43-quickshell-dnd.sh`
- `tests/nested/44-quickshell-power.sh`
- `tests/nested/45-quickshell-usb.sh`
- `tests/nested/46-quickshell-bluetooth.sh`
- `tests/nested/47-quickshell-wifi.sh`
- `tests/nested/quickshell/fake-brightness`
- `tests/nested/quickshell/fake-swaync`
- `tests/nested/quickshell/fake-power`
- `tests/nested/quickshell/fake-usb`
- `tests/nested/quickshell/fake-ip`
- `tests/nested/quickshell-audio/shell.qml`
- `tests/nested/quickshell-bluetooth/shell.qml`
- `tests/nested/quickshell-wifi/shell.qml`
- `tests/nested/11-config-matrix.sh`
- `tests/nested/conf/variants/20-background-fade-pills.lua` through
  `31-background-no-fade-key.lua`

Some shared files also contain earlier uncommitted pill-depth work. Do not
remove or reverse those changes.

### Dotfiles Repository

- `flake.nix`
- `flake.lock`
- `CONTROL_CENTER_PROGRESS_HANDOFF.md`
- `.config/quickshell/shell.qml`
- `.config/quickshell/ControlCenter.qml`
- `.config/quickshell/BrightnessService.qml`
- `.config/quickshell/AudioService.qml`
- `.config/quickshell/DndService.qml`
- `.config/quickshell/PowerService.qml`
- `.config/quickshell/UsbService.qml`
- `.config/quickshell/BluetoothService.qml`
- `.config/quickshell/WifiService.qml`
- `.config/quickshell/ControlCenterState.qml`
- `.config/quickshell/Theme.qml`
- `.local/bin/control-center-brightness`
- `.local/bin/control-center-power`
- `.local/bin/control-center-usb`
- `.local/bin/control-center-ip`
- `.local/bin/control-center-toggle`
- `modules/home/linux/_hyprland/quickshell.nix`
- `modules/home/linux/hyprland.nix`
- `modules/home/linux/xdg-configs.nix`

The dotfiles repository contains other pre-existing user changes. Do not remove
or reverse them.

## Verification Results

These commands passed:

```bash
make test-tier0
make test-nested
tests/run.sh nested '27-quickshell-rendering'
nix flake check --no-build
tests/run.sh nested '28-green-background-fade'
tests/run.sh nested '29-green-background-fade-dynamic'
tests/run.sh nested '36-red-background-jfa-field'
tests/run.sh nested '37-red-background-config'
tests/run.sh nested '38-red-live-blur-cache'
tests/run.sh nested '39-red-background-regressions'
```

Final results:

```text
Tier zero: 3 passed, 0 failed, 0 skipped
Nested: 16 passed, 0 failed, 0 skipped
Quickshell focused gate: 1 passed, 0 failed, 0 skipped
Final tier zero: 4 passed, 0 failed, 0 skipped
Final nested: 22 passed, 0 failed, 0 skipped
```

Successful artifacts:

```text
/home/orhun/Documents/hyprglass/tests/out/20260829T140925Z
/home/orhun/Documents/hyprglass/tests/out/20260829T141052Z
/home/orhun/Documents/hyprglass/tests/out/20260829T141349Z
/home/orhun/Documents/hyprglass/tests/out/20260829T153750Z
/home/orhun/Documents/hyprglass/tests/out/20260829T153919Z
```

The final geometry evidence is:

```text
/home/orhun/Documents/hyprglass/tests/out/20260829T141349Z/27-quickshell-rendering/layers-open.json
```

## Diagnosed Failure Artifacts

These failed runs are retained as diagnostic evidence:

```text
/home/orhun/Documents/hyprglass/tests/out/20260829T133120Z
```

Cause: obsolete `misc.vfr` key triggered Hyprland emergency mode.

```text
/home/orhun/Documents/hyprglass/tests/out/20260829T135719Z
```

Cause: the initial isolated runtime path exceeded the Unix socket path limit.

```text
/home/orhun/Documents/hyprglass/tests/out/20260829T140654Z
```

Cause: Quickshell 0.3.1 does not permit PID selection with `--any-display`.

```text
/home/orhun/Documents/hyprglass/tests/out/20260829T140757Z
```

Cause: the movement assertion compared a sub-threshold carrier pixel against
an unbound surface. The corrected test compares the old pill position with the
closed raw background.

```text
/home/orhun/Documents/hyprglass/tests/out/20260829T152740Z
```

Cause: the first live-blur test compared a strongly blurred 8-pixel
checkerboard with a solid background of the same mean luminance. The test now
uses a distinct dark background and keeps the original feature threshold.

## Current Risks

1. The whole dotfiles `git diff --check` still reports pre-existing trailing
   whitespace in `pkgs/hyprglass-regions.patch`. The new flake changes pass a
   scoped diff check.
2. The dotfiles package patch can differ from uncommitted Hyprglass source.
   Do not regenerate the patch from `HEAD`.
3. All production Quickshell panel services pass nested tests. Live hardware,
   focus, sleep/wake, and visual acceptance remain separate deployment gates.
4. The source-tree control center has been previewed manually on the live
   compositor, but the formal live suite has not run.
5. No Home Manager activation, `nixos-rebuild switch`, or plugin hot-load
   operation was performed.
6. The dotfiles Hyprglass package patch does not contain this uncommitted
   milestone. Do not regenerate it from `HEAD`.

## Nested Teardown Safety Incident

On 2026-08-29, repeated nested test runs left 38 Hyprland test compositors
running. `nested_stop()` sent `SIGTERM`, but these processes did not exit and
the helper had no forced-cleanup fallback. The accumulated DRM and OpenGL
resources caused the live Hyprland process to abort in
`CHyprOpenGLImpl::begin()`. The watchdog restarted Hyprland with `--safe-mode`.

Recovery actions:

1. All processes whose exact command used
   `tests/nested/conf/hyprland-test.lua` were killed.
2. The safe-mode compositor was exited with the user's approval.
3. Hyprland restarted without `--safe-mode` and loaded
   `/home/orhun/.config/hypr/hyprland.lua`.
4. The recovered session reported one `hyprglass` plugin and monitor scale
   `1.25`.
5. SwayNC, Hypridle, and the Hyprland portal reported active.
6. No nested test compositor remained.

`tests/lib.sh` now tracks process groups for both Hyprland and Quickshell. It
waits after `SIGTERM` and sends `SIGKILL` to a group that remains alive after
its launch process exits.

The teardown safety gate is complete:

1. An isolated smoke test exited with zero nested Hyprland processes.
2. An isolated production-shell test exited with zero nested Hyprland and
   Quickshell processes.
3. A dedicated Quickshell teardown test stopped Quickshell while the nested
   compositor remained healthy, then stopped the compositor with zero leaks.
4. The complete shared suite exited with zero nested Hyprland and Quickshell
   processes.

## Production Shell Milestone

Production shell source was added but not activated:

- `.config/quickshell/shell.qml`
- `.config/quickshell/ControlCenter.qml`
- `.config/quickshell/ControlCenterState.qml`
- `.config/quickshell/Theme.qml`
- `.local/bin/control-center-toggle`
- `modules/home/linux/_hyprland/quickshell.nix`

The shell is hidden by default. Waybar and Eww callers remain unchanged. The
post-recovery focused production-shell gate passed at:

```text
/home/orhun/Documents/hyprglass/tests/out/20260829T163815Z
```

Final verification passed:

```text
Tier zero: 4 passed, 0 failed, 0 skipped
Nested: 23 passed, 0 failed, 0 skipped
Tier-zero artifacts: /home/orhun/Documents/hyprglass/tests/out/20260829T164535Z
Nested artifacts: /home/orhun/Documents/hyprglass/tests/out/20260829T164710Z
```

The path-based command
`nix flake check --no-build path:/home/orhun/Documents/dotfiles` passed. No Home
Manager activation, NixOS switch, or production service start was performed.

## Brightness Service Milestone

The first production service adapter is complete but not activated:

- `.config/quickshell/BrightnessService.qml`
- `.local/bin/control-center-brightness`
- `tests/nested/quickshell/fake-brightness`
- `tests/nested/41-quickshell-brightness.sh`

The toolkit-neutral helper provides a small `get` and `set PERCENT` contract on
top of `brightnessctl`. Both reads and writes preserve the supported `1..100`
range.

The QML service provides:

1. Immediate optimistic slider feedback.
2. An immediate leading write followed by a 50 ms rate limit for dynamic
   pointer-motion updates.
3. One serialized writer with latest-pending-value coalescing during each
   cooldown and in-flight command.
4. A one-second refresh while the panel is open and an immediate refresh when
   it opens.
5. Recovery after a backend executable fails to start.
6. `CONTROL_CENTER_BRIGHTNESS_COMMAND` injection for isolated tests and a
   default `$HOME/.local/bin/control-center-brightness` production backend.

The placeholder brightness strip is now interactive. The volume strip and all
other service placeholders remain unchanged. The focused test proves immediate
state, minimum and maximum clamping, missing-backend recovery, failed-write
recovery, and the exact rate-limited write sequence
`10, 30, 40, 60, 1, 100, 80`.
Both Quickshell production tests inject a fake backend or use an isolated test
`HOME`; they cannot access live brightness hardware.

Final verification passed:

```text
Tier zero: 4 passed, 0 failed, 0 skipped
Nested: 24 passed, 0 failed, 0 skipped
Tier-zero artifacts: /home/orhun/Documents/hyprglass/tests/out/20260829T170429Z
Nested artifacts: /home/orhun/Documents/hyprglass/tests/out/20260829T171033Z
```

The path-based command
`nix flake check --no-build path:/home/orhun/Documents/dotfiles` passed after
the final changes. No nested Hyprland or Quickshell process remained. No Home
Manager activation or NixOS switch was performed during automated verification.

## Live Brightness Preview

The source-tree shell was launched manually against the active `eDP-1` live
output with the pinned Quickshell 0.3.1 package and an explicit source-tree
brightness helper. This did not activate Home Manager, start the declared user
service, or change Waybar from Eww.

The first live trial found that a trailing debounce changed hardware brightness
only after dragging stopped. The service now performs the first write
immediately and rate-limits subsequent writes to the newest value every 50 ms.
The corrected focused gate passed at:

```text
/home/orhun/Documents/hyprglass/tests/out/20260829T172931Z
```

The corrected disposable preview was restarted as PID `401707`, opened
brightness-ready at 50 percent, and had empty standard error. It was stopped
cleanly before audio implementation began. Logs remain under
`/tmp/opencode/control-center-live.*.log`.

## Audio Service Milestone

The volume strip now uses `.config/quickshell/AudioService.qml` and
`Quickshell.Services.Pipewire` directly. It tracks `Pipewire.defaultAudioSink`
with the required `PwObjectTracker`, waits for `PwNode.ready`, clamps writes to
`0..100`, follows external volume and mute signals without polling, and uses a
separate mute target over the full-width slider coordinate system.

The focused fake-sink test covers immediate volume updates, both bounds, mute
and unmute, delayed sink readiness, sink removal, restoration, and replacement.
The shared Quickshell harness clears `PIPEWIRE_RUNTIME_DIR` and
`PIPEWIRE_REMOTE`, so nested production-shell tests cannot inherit a live audio
endpoint.

## DND Service Milestone

The DND tile now uses `.config/quickshell/DndService.qml`. It consumes structured
SwayNC events from `swaync-client --skip-wait --subscribe`, toggles with a
bounded `--skip-wait --toggle-dnd` process, updates optimistically, rejects
concurrent actions, and reconnects after stream startup, exit, or action
failure. Each event is verified by an event-triggered, bounded
`--skip-wait --get-dnd` command, so SwayNC's synthetic daemon-disconnect event
cannot be mistaken for an available service. Generation-aware rollback cannot
overwrite a newer subscribed state.

The focused fake-SwayNC test covers initial events, optimistic and confirmed
state, a visible busy interval, concurrent-action rejection, external changes,
failed-action rollback, autonomous subscription recovery, synthetic
daemon-disconnect events, and forced termination after the two-second action
timeout. Fake state replacement is atomic. The shared Quickshell harness and
production toggle-wrapper test clear `DBUS_SESSION_BUS_ADDRESS`, and all
production-shell tests inject the fake where DND is loaded.

Final service verification passed:

```text
Tier zero: 4 passed, 0 failed, 0 skipped
Nested: 26 passed, 0 failed, 0 skipped
Tier-zero artifacts: /home/orhun/Documents/hyprglass/tests/out/20260829T180229Z
Nested artifacts: /home/orhun/Documents/hyprglass/tests/out/20260829T182043Z
Final service-focused artifacts: /home/orhun/Documents/hyprglass/tests/out/20260829T182828Z
```

`nix flake check --no-build path:/home/orhun/Documents/dotfiles` passed. No test
Hyprland or Quickshell process remained after the full suite.

## Next Milestone

All control-center functionality is now implemented in the source tree.

The final functional milestone added:

1. Wi-Fi through `Quickshell.Networking`, including radio power, active and
   available networks, saved/open/personal/enterprise routing, inline
   prompt-local passwords, wrong-password retention, cancellation, on-demand
   panel focus, IP lookup, disconnect, and editor handoff.
2. Bluetooth through `Quickshell.Bluetooth`, including adapter power, paired
   connected-first devices, battery state, connect/disconnect timeouts, and
   Overskride handoff.
3. Structured removable-media state with stable media identity, serialized and
   bounded mount/unmount/eject actions, fail-closed refreshes, detached browse
   and GNOME Disks handoffs, and conservative multi-volume eject rejection.
4. Allowlisted suspend, hibernate, and power-off actions that run only after
   both panel surfaces complete their guarded close path.
5. Global SwayNC close-on-open behavior and cancellation of Wi-Fi focus/action
   state on every close or menu-switch path.
6. Nested isolation from session D-Bus, system D-Bus, PipeWire, brightness
   hardware, removable media, and real power commands.

Final verification:

```text
Tier zero: 4 passed, 0 failed, 0 skipped
Service-focused: 8 passed, 0 failed, 0 skipped
Nested: 30 passed, 0 failed, 0 skipped
Tier-zero artifacts: /home/orhun/Documents/hyprglass/tests/out/20260829T190509Z
Service artifacts: /home/orhun/Documents/hyprglass/tests/out/20260829T190851Z
Nested artifacts: /home/orhun/Documents/hyprglass/tests/out/20260829T191054Z
```

The next milestone is deployment acceptance, not more panel functionality:

- Resolve the deferred visual-design issues.
- Run controlled live Wi-Fi focus/password and real service-action checks.
- Run the live Hyprglass test and sleep/wake singleton check.
- Build and activate a complete generation only after those gates pass.
- Then route Waybar to `control-center-toggle` and remove Eww in a separate,
  rollback-safe change.

Use this order:

1. Re-read both repository diffs before editing shared files.
2. Preserve the process-group teardown and zero-leak post-run checks.
3. Preserve the current Eww control center and its helpers as rollback.
4. Do not add more service adapters; all required panel services are present.
5. Add focused service tests before changing external callers.
6. Keep Waybar on Eww until all required services and focus handling pass.
7. Do not regenerate the Hyprglass package patch before reviewed plugin work is
   committed.

The predeployment hold ended after the service, live-rendering, and suspend
gates passed. The deployment state is recorded below.

## Live Deployment And Slider Design

The brightness and sound controls now follow the supplied Apple Control Center
reference:

- Separate labeled Display and Sound cards.
- Icon-to-icon horizontal tracks with an inset active value line.
- A `24x18` horizontal capsule thumb.
- Thumb opacity is zero unless the pointer is over the track or dragging it.
- Press feedback is immediate; release uses a 120 ms strong ease-out.
- The pressed thumb scales to `1.08` and switches to low-alpha glass so the
  active value line remains visible beneath it.
- Pointer movement remains one-to-one with the value; only backend writes are
  rate-limited.

The Home Manager generation was activated successfully. The first user-service
launch exposed a stale `WAYLAND_DISPLAY` in the systemd user manager. The
declarative service now starts through a generated launcher that resolves the
newest Hyprland instance and Wayland socket at every launch. Systemd remains the
only Quickshell process creator and retries without a start-limit lockout.

Live acceptance completed:

1. The managed Quickshell service reached active/running with one process.
2. The deployed panel opened and closed through `control-center-toggle`.
3. The live Hyprglass test passed at the required `0.02` RMSE limit:
   `/home/orhun/Documents/hyprglass/tests/out/20260829T194504Z`.
4. Suspend/resume preserved the same Quickshell PID and returned to closed IPC
   state.
5. Waybar now routes every control-center caller through
   `control-center-toggle`.
6. The Eww Hyprland startup entry and declarative post-sleep restart service
   were removed. Eww source and package remain available for rollback.
7. No Eww process is running.
8. The complete latest NixOS generation builds successfully, and previous
   generations remain listed for rollback.

The current shell cannot complete the root NixOS switch because `sudo` requires
an interactive password. Home Manager and the live Waybar/Quickshell cutover are
active. Run this once in an interactive terminal to activate the root-level
removal of the old post-sleep Eww unit:

```bash
sudo nixos-rebuild switch --flake 'path:/home/orhun/Documents/dotfiles#odyssey'
```

## Final Visual Refinement

The requested visual refinements are implemented and active in Home Manager:

- Brightness and volume percentages are removed.
- Wi-Fi, Bluetooth, and DND controls use circular icon buttons.
- The panel begins below Waybar with a 48-pixel top margin.
- Wi-Fi rows and actions have explicit hover feedback.
- The collapsed power card retains its bottom corner radius.
- Menu content remains mounted while collapsing.
- Menu height uses an explicit interruptible animation from its current height,
  including when switching menus rapidly.

The production shell gate and all seven focused service gates pass:

```text
Production shell: PASS
Brightness, audio, DND, power, USB, Bluetooth, Wi-Fi: 7 passed
Service artifacts: /home/orhun/Documents/hyprglass/tests/out/20260829T195720Z
```

The latest Home Manager activation succeeded. The managed service was restarted
once to load the changed QML and reached `active/running` as the only Quickshell
process, PID `602779`, with zero automatic restarts. The panel returned to
`open=false menu=none`; no Eww process is running.

The live rendering harness now resolves the newest Hyprland instance and its
Wayland socket on every run, rather than accepting stale inherited environment
variables. The final live rendering gate passes:

```text
/home/orhun/Documents/hyprglass/tests/out/20260829T200055Z
```

The root NixOS switch above remains the only deployment step that requires the
user's interactive sudo password.

## Interaction Refinement

The next live refinement is active:

- Enabled color is confined to the circular Wi-Fi, Bluetooth, and DND icon
  buttons instead of filling their complete tiles.
- The Power header and all three power actions have 120 ms hover transitions.
- Menu collapse renders the outgoing glass and content at the current animated
  height, then unmounts it after the exit completes.
- Wi-Fi network rows fade and clip out before their delegates are removed.
- The last measured network-list height is retained so reversing from the
  password prompt starts immediately after the rows remount.
- The Wi-Fi detail slot and the enclosing menu animate with the same measured
  height delta, duration, and curve. Display, Sound, and Power therefore move
  with the shrinking or expanding Wi-Fi content rather than after it.

Focused production collapse and password-layout tests pass:

```text
/home/orhun/Documents/hyprglass/tests/out/20260829T201931Z
```

All eight focused service and interaction tests pass:

```text
/home/orhun/Documents/hyprglass/tests/out/20260829T202020Z
```

Home Manager activation and the managed service restart succeeded. The live
Hyprglass rendering gate passes with the refined panel:

```text
/home/orhun/Documents/hyprglass/tests/out/20260829T202224Z
```

## Pill Corner And Teardown Refinement

The pill shader no longer adds a separate corner-only distance band. Corner
lobes now change only the brightness of the shared edge profile. The scalar
pill distance used by both bright and dark edge effects is filtered with the
already-sampled 3x3 Gaussian kernel, removing curved-corner stair steps without
changing the straight-edge width.

The generated regions patch was not regenerated. The validated shader change
is packaged separately as `pkgs/hyprglass-pill-corners.patch` and applied after
`pkgs/hyprglass-regions.patch`.

Power actions now render icons with the icon font and labels with the standard
control text font. Wi-Fi rows reach zero opacity, remain mounted for a 200 ms
retirement interval, and are only then removed. The focused test records and
asserts that zero-opacity retention occurred before teardown.

Verification passes:

```text
Tier zero: 4 passed
Nested: 31 passed
Focused production and Wi-Fi transition: 2 passed
Focused service and interaction: 8 passed
Live rendering: /home/orhun/Documents/hyprglass/tests/out/20260829T212456Z
```

The QML generation is active. The shader package generation builds successfully
at `/tmp/opencode/hyprglass-hm-pill-corners`, but it is intentionally not active
in the running compositor. Do not hot-load or activate the changed plugin path
inside this session; prior duplicate-plugin reloads crashed Hyprland. Activate
that generation from a TTY after logging out, then start a fresh session.

## Dynamic Menu Reflow And Slider Refinement

Slider value fills now use the track's capsule radius, so both the painted and
unpainted portions have rounded left and right ends. The shared hover overlay is
now a 25% dark neutral (`#4011111b`) that remains legible on bright backdrops.

Expanded menu height is synchronized through one interruptible target-height
animation. Target measurement substitutes the Wi-Fi slot's desired height for
its current presentation height, preventing delayed motion and minimum-height
overshoot. Bluetooth adapter/device changes use the same generic reflow path.

The production fixture now verifies intermediate menu and lower-control
positions while:

- Disabling and enabling Wi-Fi in its expanded menu.
- Enabling and disabling Bluetooth after opening its disabled menu.
- Entering and leaving the Wi-Fi password prompt.

Focused service and interaction tests pass:

```text
/home/orhun/Documents/hyprglass/tests/out/20260829T215015Z
```

The QML-only generation is active and its live rendering gate passes:

```text
/home/orhun/Documents/hyprglass/tests/out/20260829T215259Z
```

The refreshed future generation, including the pending pill-corner plugin, is
built at `/tmp/opencode/hyprglass-hm-pill-corners` and remains intentionally
inactive until a fresh compositor session.

## Wi-Fi Password Persistence

`controlCenter.setMenu("wifi")` is now idempotent. It no longer invokes the
destructive Wi-Fi cancellation path when Wi-Fi is already selected. Explicit
password cancellation has its own `cancelWifiPassword` IPC method, while an
actual menu change still clears password state through `ControlCenterState`.

The production fixture verifies that a secured-network prompt survives a
repeated same-menu request and remains selected for at least one second without
input. Focused production and interaction tests pass:

```text
/home/orhun/Documents/hyprglass/tests/out/20260829T224350Z
/home/orhun/Documents/hyprglass/tests/out/20260829T224434Z
```

The fix is active and the live rendering gate passes:

```text
/home/orhun/Documents/hyprglass/tests/out/20260829T224711Z
```

## Password Prompt Visual Lifecycle

The remaining password issue was visual rather than state loss. The password
card now has explicit stacking above retiring network rows. Wi-Fi password state
is retained while the Wi-Fi menu collapses and is cleared only after the parent
height reaches zero. Switching directly to another menu clears it after Wi-Fi
is no longer displayed, and closing the complete panel clears it after the panel
is hidden.

The production fixture now captures the settled password card, asserts full
opacity and its 92-pixel content height, and verifies atomically that the same
prompt remains present throughout the visible parent-collapse frame. All eight
focused interaction tests pass:

```text
/home/orhun/Documents/hyprglass/tests/out/20260829T225420Z
```

The corrected QML is active and live rendering passes:

```text
/home/orhun/Documents/hyprglass/tests/out/20260829T225706Z
```

## Real Wi-Fi Scanner Race

The fake backend did not initially reproduce the remaining prompt failure. A
live reproduction against `hcl-59001` showed that password state and opacity
remained correct while a later scanner/model resize changed the shared Wi-Fi
detail slot from `height=92, visible=true` to `height=0, visible=false`.

The Wi-Fi detail slot now separates its mutable animated network-list height
from its rendered height. While `passwordNetwork` is non-empty, rendered height
is structurally clamped to at least 92 pixels and visibility is forced true.
Asynchronous scanner updates can continue resizing the retired network layer but
cannot hide an active prompt.

The same live reproduction now remained stable for every sample:

```text
hcl-59001,1,true,92,283
```

The test prompt was explicitly cancelled afterward without submitting a
password. All eight focused interaction tests and the live rendering gate pass:

```text
/home/orhun/Documents/hyprglass/tests/out/20260829T230359Z
```

## Control-Center Background Blur

The production `control_center` layer now enables the complete base-sheet blur:

```lua
background = true,
background_fade = 24,
live_blur = true,
```

The protected generated regions patch was not regenerated. The difference from
that package baseline to the tested development source is carried by the
separate `pkgs/hyprglass-background-field.patch`, applied after the regions and
pill-corner patches. This adds low-alpha base-sheet attribution, the independent
background distance field, 24-pixel boundary coverage, transformed cache keys,
old/new geometry damage, and damage-driven live background resampling.

The complete nested suite passes, including static and dynamic background fade,
background-field geometry, invalid/replacement configuration, live/cached blur,
and the production Quickshell shell:

```text
31 passed
/home/orhun/Documents/hyprglass/tests/out/20260830T100914Z
```

The fresh-session Home Manager generation is built at:

```text
/tmp/opencode/hyprglass-hm-background-blur
```

Do not activate this changed plugin path inside the running compositor. Activate
it from a TTY after logging out, then start a new graphical session.

The first fresh session still lacked the continuous sheet because the hand-owned
`~/.config/hypr/hyprglass.lua` loads after generated configuration and replaced
the complete layer declaration with an older pill-only block. That final
override now also uses `mask_threshold = 0.004`, `background = true`,
`background_fade = 24`, and `live_blur = true`. After `config-only` reload, the
live frame visibly contains one blurred sheet across all padding and gaps between
pills. The live reload/damage gate passes:

```text
/home/orhun/Documents/hyprglass/tests/out/20260830T102837Z
```

## Outward Background Fade

The background field now keeps full blur through the complete panel sheet and
for 4 pixels outside it, then fades the glass contribution outward over 24
pixels. Background JFA seeds are opaque sheet pixels, while pill JFA seeds
remain sub-threshold pixels. The base sheet does not receive slab-edge
refraction, Fresnel, specular, or shadow treatment.

The production Quickshell carrier is expanded by the combined 28-pixel extent;
the visible 400-pixel panel remains inset at its original screen position. The
nested Eww tests use a separate padded carrier so existing declared-region and
pill coordinates remain unchanged.

The complete nested suite passes:

```text
31 passed
/home/orhun/Documents/hyprglass/tests/out/20260830T105355Z
```

`pkgs/hyprglass-background-field.patch` was regenerated as an additive diff
after `hyprglass-regions.patch` and `hyprglass-pill-corners.patch`. Applying all
three patches reproduces the tested plugin source. The exact `odyssey` system
closure builds successfully at:

```text
/tmp/opencode/odyssey-background-outward-system
```

Activate it with a normal `nixos-rebuild switch`, then log out and back in. Do
not hot-load the changed plugin binary into the current compositor.

## Clearer Pills And Linear Fade

The control-center pills now use a pill-specific glass opacity so the background
sheet can remain fully blurred while controls are lighter:

```lua
blur = 0.45,
opacity = 0.68,
```

The shared control-center preset also reduces Fresnel and specular strengths to
`0.35` and `0.45`. The plugin validates `pills.opacity` as a finite value from
zero to one and multiplies only pill glass coverage by it.

The former 4-pixel full-strength exterior blur band was removed. Background
coverage now fades linearly from full blur at the sheet edge to zero over 32
pixels. The low-alpha QML sheet changed from white to neutral black, removing
its white edge contribution. The production carrier provides 40 pixels of
space on the left, right, and bottom, and the panel moved 13 pixels left to
expose more of the right-side fade on screen.

Verification passes:

```text
Tier zero: 4 passed
/home/orhun/Documents/hyprglass/tests/out/20260830T111023Z

Nested: 31 passed
/home/orhun/Documents/hyprglass/tests/out/20260830T111938Z
```

The refreshed additive package patch reproduces the verified source. The exact
system closure builds successfully at:

```text
/tmp/opencode/odyssey-control-center-tuning-system
```

## Reference-Calibrated Glass On Glass

The material is now calibrated from the numbered references in
`/home/orhun/Documents/control_center_ref_images`. Images 2-4 define the
single-surface optics; images 5-7 define the parent/child glass hierarchy.
The CPU-only analyzer, semantic ROI manifests, synthetic self-test, contact
sheet generator, and bounded nested sweep live under
`/home/orhun/Documents/hyprglass/tests/visual`.

The production control center is split into two compositor surfaces:

- `control_center_backdrop` renders the rounded parent material on the Top
  layer without accepting input.
- `control_center` renders controls on the Overlay layer, so each child samples
  the already-rendered parent glass.

The parent and child use independent three-iteration presets. The bounded sweep
selected parent blur `0.75` and child blur `1.05`; their measured 10-90 edge
transitions are `12.24 px` and `20.59 px`, with a `1.68` child/parent ratio.
These values are inside the reference ranges. Both use opacity `0.72`, while
child pill coverage is `0.95`. The old 32-pixel outward fade is disabled.

The parent and child surfaces use fixed `416x956` carriers to avoid layer-shell
resize skew. Their visible clips and material heights remain dynamic. A fully
transparent damage proxy toggles once after a material-height animation settles
so removed parent pixels are cleared without adding visible material or
continuous GPU work.

Control and sheet edges now have a one-pixel low-alpha inward border. Shader
Fresnel/specular values were reduced to `0.12/0.12` for the parent and
`0.25/0.30` for children, preventing the former broad white halo.

Verification:

```text
Tier zero: 4 passed
/home/orhun/Documents/hyprglass/tests/out/20260830T131635Z

Visual analyzer self-test: passed

Material sweep winner: p075-c105
/home/orhun/Documents/hyprglass/tests/out/20260830T131413Z/capture-material-sweep

Nested: 32 passed
/home/orhun/Documents/hyprglass/tests/out/20260830T134329Z
```

The plugin source did not change after the previously verified additive package
patch was generated. The exact `odyssey` system closure, including the new QML
surface split and generated Hyprglass configuration, builds at:

```text
/tmp/opencode/odyssey-glass-on-glass-system
```

## Shape-Following Pill Optics

The parent/child surface architecture and calibrated blur values remain
unchanged. Alpha-derived pills now support an optional broad achromatic lens:

```lua
pills = {
  lens = { magnification = 1.06, width = 20 },
}
```

`magnification` is finite from `1.0` through `1.25`; `width` is finite from 8
through 48 logical pixels. Both fields are required and the object is ignored
atomically when invalid. Omitting `lens` preserves the previous compact bevel.
The shader derives a shape-following normal from the existing pill JFA field,
uses a cubic contour profile, and fades before medial-axis direction changes.
It adds one conditional JFA probe but no texture, framebuffer, readback, or
render pass.

The production settings are:

```text
parent: refraction .03, magnification 1.025, width 20,
        Fresnel/specular .12/.12
child:  refraction .08, magnification 1.06, width 20,
        Fresnel/specular .35/.45, corner lobes enabled
```

Chromatic aberration and the generic center-dome lens remain disabled. The
uniform QML sheet/control borders are transparent, so contours now come from
the shader while the low-alpha fills continue to provide the material masks.
The generated configuration and `~/.config/hypr/hyprglass.lua` contain the same
complete layer declarations; the hand-owned override has not been reloaded.

Deterministic optical analysis lives in `tests/visual/analyze-optics.sh`. It
decodes RGB phase backgrounds into backward displacement fields, local
Jacobians, principal display magnification, and parent-after-child composition.
The nested fixture measured parent `1.1118` for requested `1.12`, child `1.1856`
for requested `1.18`, composition p95 `0.236 px`, and zero exterior displacement:

```text
/home/orhun/Documents/hyprglass/tests/out/20260830T170557Z
```

Verification:

```text
Tier zero: 4 passed
/home/orhun/Documents/hyprglass/tests/out/20260830T170416Z

Visual analyzer self-test: passed

Nested: 34 passed
/home/orhun/Documents/hyprglass/tests/out/20260830T171317Z

Packaged binary glass-on-glass: passed
/home/orhun/Documents/hyprglass/tests/out/20260830T172458Z

Packaged binary mapping/config: 2 passed
/home/orhun/Documents/hyprglass/tests/out/20260830T172529Z
```

`pkgs/hyprglass-pill-optics.patch` is a fourth additive tail after
`hyprglass-background-field.patch`. It applies with zero fuzz to the exact
three-patch baseline and reproduces the reviewed optical source. The protected
regions patch was not regenerated. The packaged plugin is:

```text
/nix/store/nvilkar344cccjj878m8j59m6awydjrn-hyprglass-0.7.0-regions/lib/libhyprglass.so
```

The complete unactivated Odyssey closure is:

```text
/nix/store/7jkkygb6s69ndrab6p7i87fl019dahg0-nixos-system-odyssey-26.11.20260809.279b4a8
/tmp/opencode/odyssey-pill-optics-system
```

Do not hot-load the plugin. Activate with a normal NixOS generation switch,
then log out and start a fresh graphical session.
