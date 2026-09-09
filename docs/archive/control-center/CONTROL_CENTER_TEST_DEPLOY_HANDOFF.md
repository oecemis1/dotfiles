# Control Center Test and Deployment Handoff

## Purpose

This document specifies test, package, deployment, and rollback work. Read
`CONTROL_CENTER_IMPLEMENTATION_HANDOFF.md` first.

## Test Policy

Use automated tests for each implemented feature. Keep one live test for the
real control center.

Run all other tests in the nested compositor. Do not make routine tests depend
on the real desktop.

## Required Test Classes

Each feature needs these test classes:

| Class | Purpose |
|---|---|
| Smoke | Confirm that the process loads and renders. |
| Coverage | Exercise valid and invalid configuration paths. |
| Green flag | Confirm that the requested effect appears. |
| Red flag | Confirm that the known failure does not return. |

## Baseline Repairs

Complete these repairs before new feature tests:

1. Prevent implicit stale plugin reuse in `tests/run.sh`.
2. Permit explicit `HG_TEST_SO` selection.
3. Add `misc:vfr = false` to the nested configuration.
4. Make `make test` run tier 0 and nested tests only.
5. Keep live tests behind `HG_LIVE=1`.
6. Run tier 0 before each nested full-suite run.

The cached file `tests/out/.hg-test-so` must include source identity. A plain
existing path is not sufficient identity.

Use a source hash, a Nix output path from current source, or an equivalent
deterministic key. Document the selected method in the test code.

## Current Test Files

Inspect these files before changes:

- `/home/orhun/Documents/hyprglass/tests/run.sh`
- `/home/orhun/Documents/hyprglass/tests/lib.sh`
- `/home/orhun/Documents/hyprglass/tests/tier0/`
- `/home/orhun/Documents/hyprglass/tests/nested/`
- `/home/orhun/Documents/hyprglass/tests/live/90-cc-holes.sh`

Existing nested tests use numbers 10 through 35. Some current files are
uncommitted. Check file names before you assign a new number.

## Quickshell Fixture

Add a separate Quickshell fixture to the nested harness. Keep the Eww fixture
until comparison tests pass.

The fixture must start one Quickshell instance on the nested Wayland display.
Use a separate runtime and cache location for the test process.

Do not connect the fixture to the live Quickshell instance. Do not use the live
Wayland display.

Provide test IPC for these actions:

- Open panel
- Close panel
- Select menu
- Move test control
- Reset state
- Report readiness

Capture Quickshell standard output and standard error in the artifact
directory.

## Fixture Gate

The Quickshell fixture must pass before production port work starts.

Use these checks:

1. Confirm the process remains alive.
2. Confirm the `control_center` layer exists.
3. Confirm the fixed surface remains transparent outside content.
4. Confirm the reveal produces intermediate frames.
5. Confirm the natural final frame matches a fresh frame.
6. Confirm movement clears the old position.
7. Confirm repeated open and close operations leave no surface.
8. Confirm IPC rejects an unknown menu.

If the fixture fails, retain all artifacts. Compare the Hyprland log, shell
log, and image crops before you change toolkits.

## Background-Fade Tests

Add a deterministic background field fixture. Use an 8-pixel checkerboard as
the background.

Add a low-alpha sheet with a known rectangle. Add higher-alpha controls inside
the sheet.

Use these image checks:

| Check | Required result |
|---|---|
| Interior standard deviation | Lower than raw background. |
| Exterior RMSE | Near zero against raw background. |
| Boundary line profile | Monotonic across the fade. |
| Boundary second difference | Below a calibrated smoothness limit. |
| Natural versus fresh RMSE | Below `0.01` in the nested panel region. |
| Pill boundary position | Equal within one pixel before and after sheet addition. |

Record each calibrated threshold near the helper that applies it. Include the
source artifact date and a short reason.

## Dynamic Boundary Tests

Test these states:

1. Collapsed panel
2. Wi-Fi menu open
3. Wi-Fi menu closed again
4. Bluetooth menu open
5. USB menu open
6. Power section open
7. Panel during open animation
8. Panel during close animation

For each final state, compare the natural frame with a fresh frame. Search for
rows that match the raw background inside the expected sheet.

## Live-Blur Cache Test

Keep the panel surface static. Change the checkerboard or a test window behind
the panel.

With `live_blur = true`, the blurred interior must change. With
`live_blur = false`, preserve the documented cache behavior.

Do not use a timer inside Hyprglass to force this test.

## Configuration Tests

Extend Lua sanity tests for these values:

- Valid positive `background_fade`
- Zero `background_fade`
- Negative `background_fade`
- Non-finite `background_fade`
- Valid `live_blur`
- Wrong `live_blur` type
- Fade without `background = true`
- Duplicate namespace replacement
- Omitted setting removal

The compositor must not crash after invalid input. The plugin must report a
clear warning or use the documented fallback.

## Shader Tests

Extract and validate every embedded shader. Update the expected shader list if
the implementation adds a new shader.

Keep packed JFA tests for these properties:

- Nearest-neighbor field reads
- Blending disabled during field writes
- Correct sentinel polarity
- Monotonic distance
- Smooth distance
- Correct far-field saturation
- Correct border seeds

## Normal-Path Regression

The background feature must not change normal windows. Add a screenshot
comparison for a normal glass window.

The background feature must not change a layer without pills or background
fade. Add a comparison for this path.

The pill-depth work requires terminal and window regression coverage. Do not
use a no-pill layer as the only normal-window test.

## Live Test Contract

Update `tests/live/90-cc-holes.sh` to use the generic control-center command.
Remove direct Eww variable and window checks after migration acceptance.

The live test must perform these operations:

1. Confirm one active Hyprland instance.
2. Open the control center.
3. Capture the collapsed state.
4. Open the Wi-Fi menu.
5. Wait for available network data.
6. Capture the natural expanded state.
7. Request a fresh damaged frame.
8. Capture the fresh expanded state.
9. Close the Wi-Fi menu.
10. Capture the collapsed state again.
11. Close the panel.

Use `0.02` as the initial natural-versus-fresh RMSE limit. Change this value
only after measured evidence shows a required higher limit.

Do not use `0.15` as a default correctness limit. That value can hide a large
visual change.

For moving wallpapers, use a stable test background or isolate static image
regions. Do not weaken the limit only because unrelated pixels move.

## Real Background Checks

Run live visual checks over these backgrounds:

- Static wallpaper
- Dark terminal
- Light terminal content
- Updating terminal content

Confirm the fade on the top, right, bottom, and rounded corners. Confirm the
blur remains current during terminal output.

## Performance Checks

Measure these values before and after migration:

- Quickshell resident memory
- Eww resident memory
- Idle CPU use
- CPU use during panel animation
- GPU frame time during panel animation
- Panel open latency
- Wi-Fi menu open latency

Use the same session and background for each comparison. Record the command and
the result in test artifacts.

Do not reject Quickshell from one idle-memory value. Use rendering correctness
as the first gate.

## Supported Verification Commands

Run these commands from `/home/orhun/Documents/hyprglass`:

```bash
make test-tier0
make test-nested
tests/run.sh nested '30-red-stale-damage-holes'
tests/run.sh nested '31-red-jfa-pill-field'
HG_LIVE=1 make test-live
```

Run live tests only after the package deployment gate passes.

## Plugin Build

The host can lack Hyprland `pkg-config` data. Use the repository tier-zero
builder when possible.

The known Nix expression uses the dotfiles flake and
`mkHyprlandPlugin`. Read `tests/tier0/01-build.sh` before you duplicate the
expression.

Do not assume that an old Nix store path contains current source.

## Patch Generation

Generate the package patch only from reviewed, committed plugin work.

Use this scope unless current package code requires another file:

```bash
git -C /home/orhun/Documents/hyprglass diff v0.7.0..HEAD -- \
  src Makefile README.md > \
  /home/orhun/Documents/dotfiles/pkgs/hyprglass-regions.patch
```

Run `git diff --check` after generation. Remove trailing whitespace from the
patch.

Compare the generated patch with the dotfiles patch before a Nix build. The
comparison must show no unexpected difference.

## Flake Source Rule

Nix flakes exclude untracked source files. Add each new build input to the Git
index before the Nix build.

Do not commit unless the user requests a commit. Staging a build input does not
authorize a commit.

Inspect staged and unstaged changes before and after the build.

## Dotfiles Build

Run this command from `/home/orhun/Documents/dotfiles`:

```bash
nix build .#nixosConfigurations.odyssey.config.system.build.toplevel
```

The build must include the reviewed Quickshell configuration and Hyprglass
patch. Record the output path.

Do not run `nixos-rebuild switch` during implementation. Do not run a Home
Manager live activation during plugin testing.

## Deployment Procedure

The historical attempt created two plugin instances. Hyprland then crashed and
entered safe mode.

Use this deployment procedure:

1. Stop all live plugin experiments.
2. Confirm one declarative Hyprglass load in the target configuration.
3. Build the complete NixOS generation.
4. Confirm the build uses the expected patch.
5. Confirm the Quickshell service has one startup path.
6. Boot the new generation.
7. Confirm one Hyprland instance.
8. Confirm one Hyprglass plugin entry.
9. Confirm one Quickshell process.
10. Confirm expected layer surfaces with `hyprctl -j layers`.
11. Run the live control-center test.

Do not issue a second reload while the first reload is unresponsive. Do not use
an IPC signature from a prior compositor process.

## Layer Inspection

After each deployment test, inspect `hyprctl -j layers`.

Expected open surfaces are:

- One `control_center_closer`
- One `control_center`

Expected closed surfaces contain neither namespace. A remaining closer is a
failure.

## Eww Removal Gate

Do not remove Eww until all conditions are true:

1. Quickshell passes the nested rendering gate.
2. Hyprglass passes background-fade tests.
3. All service actions pass live checks.
4. Wi-Fi password entry passes focus tests.
5. Sleep and wake preserve one shell process.
6. The live control-center test passes.
7. SwayNC mutual exclusion passes.
8. Remaining Eww callers are removed or migrated.

Search the dotfiles repository for `eww` before package removal. Inspect each
result. Do not assume that all remaining matches are obsolete.

## Rollback

Keep the current Eww configuration until the removal gate passes. Keep the
current Waybar command available in the previous boot generation.

If Quickshell fails after boot, select the prior boot generation. Do not hot
load a second plugin to repair the session.

If the plugin fade fails, disable `background_fade` and `live_blur`. Keep the
pill configuration unchanged.

The screenshot backdrop remains a documented emergency prototype. Do not make
it the default rollback path.

## Final Acceptance

1. Tier-zero tests pass.
2. Nested tests pass without unexpected skips.
3. The Quickshell fixture uses current source.
4. The background profile is smooth and monotonic.
5. Natural and fresh frames match within the approved limit.
6. Normal windows remain unchanged.
7. Live blur updates over terminal output.
8. One Hyprglass plugin instance exists.
9. One Quickshell process exists.
10. Closed panels leave no layer surfaces.
11. The NixOS system build succeeds.
12. The previous boot generation remains available for rollback.
