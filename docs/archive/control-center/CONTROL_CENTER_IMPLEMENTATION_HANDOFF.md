# Control Center Implementation Handoff

## Purpose

This document is the entry point for a new implementation context.

The new agent does not need the previous chat. The agent must read the files
and source locations that this document identifies.

These documents use strict ASD-STE100 structural rules. The official dictionary
was unavailable, so lexical compliance is not certified.

## Scope

Replace the Eww control center with Quickshell 0.3.1. Add a live, feathered
background sheet behind the independent Hyprglass controls.

The final implementation must not use a screenshot as the production
background. The final implementation must not use ImageMagick for live blur.

## Handoff Set

Read these documents in this order:

1. `CONTROL_CENTER_IMPLEMENTATION_HANDOFF.md`
2. `CONTROL_CENTER_HYPRGLASS_HANDOFF.md`
3. `CONTROL_CENTER_QUICKSHELL_HANDOFF.md`
4. `CONTROL_CENTER_TEST_DEPLOY_HANDOFF.md`

The file `CONTROL_CENTER_BLUR_HANDOFF.md` contains historical evidence. It is
not the current implementation specification.

## Repositories

| Name | Path | Expected branch |
|---|---|---|
| Hyprglass plugin | `/home/orhun/Documents/hyprglass` | `regions` |
| NixOS dotfiles | `/home/orhun/Documents/dotfiles` | `nixos` |

Both worktrees can contain user changes. Do not remove or reverse these
changes. Read each diff before you edit a changed file.

## Approved Decisions

1. Use Quickshell 0.3.1 for the control center.
2. Use AGS 3 with GTK4 only if the Quickshell test fixture fails.
3. Keep blur generation in Hyprglass.
4. Use one control-center surface for the sheet and the controls.
5. Keep the layer namespace `control_center`.
6. Keep a separate outside-click surface named `control_center_closer`.
7. Use a second alpha-distance field for the sheet boundary.
8. Do not use Quickshell `BackgroundEffect` for the production fade.
9. Do not use Quickshell `ScreencopyView` for the production fade.
10. Keep Eww until the Quickshell implementation passes live tests.

## Required Start Procedure

1. Open `/home/orhun/Documents/hyprglass` as the working directory.
2. Read all four current handoff documents.
3. Read `/home/orhun/Documents/dotfiles/CONTROL_CENTER_BLUR_HANDOFF.md`.
4. Run `git status --short` in both repositories.
5. Read the complete diff in both repositories.
6. Read recent commit subjects in both repositories.
7. Do not edit a file before you understand its current changes.

Do not ask the user to repeat information from the previous chat. Ask the user
only when the current files conflict with an approved decision.

## Fresh Context Prompt

Use this prompt in the new context:

```text
Read /home/orhun/Documents/dotfiles/CONTROL_CENTER_IMPLEMENTATION_HANDOFF.md.
Read each handoff that its Handoff Set section identifies.
Treat those files as the approved implementation specification.
Inspect each source location in the external-information table.
Inspect both Git worktrees before you edit a file.
Start the first incomplete milestone.
Do not repeat the planning work.
Do not change the live session during nested implementation.
```

## Information Outside This Handoff Set

The new agent must inspect current source files. The handoff documents do not
replace source inspection.

The new agent needs no information from the previous chat. The agent does need
the current files and official references in this section.

| Information | Location | Use |
|---|---|---|
| Current plugin source | `/home/orhun/Documents/hyprglass/src/` | Confirm symbols and current behavior. |
| Plugin tests | `/home/orhun/Documents/hyprglass/tests/` | Confirm test names and helpers. |
| Pill-depth plan | `/home/orhun/Documents/hyprglass/PILL_DEPTH_PLAN.md` | Identify current uncommitted feature scope. |
| Current Eww UI | `/home/orhun/Documents/dotfiles/.config/eww/` | Preserve behavior during migration. |
| Eww helper commands | `/home/orhun/Documents/dotfiles/.local/bin/eww-*` | Preserve backend behavior. |
| Hyprland configuration | `/home/orhun/Documents/dotfiles/modules/home/linux/_hyprland/` | Update layers, startup, and callers. |
| Hyprglass package | `/home/orhun/Documents/dotfiles/pkgs/hyprglass.nix` | Build the plugin package. |
| Hyprglass patch | `/home/orhun/Documents/dotfiles/pkgs/hyprglass-regions.patch` | Deploy committed plugin changes. |
| Live Eww style override | `/home/orhun/.config/eww/styles/_overrides.scss` | Read the active visual values. |
| Live Hyprglass override | `/home/orhun/.config/hypr/hyprglass.lua` | Read the active plugin values. |

The live configuration files are evidence. The dotfiles repository remains the
target source of truth.

## Optional Historical Evidence

Use these sources only when current source or test results need more context:

| Information | Location | Use |
|---|---|---|
| Old agent memory | `/home/orhun/.claude/projects/-home-orhun-Documents-dotfiles/memory/hyprglass-plugin.md` | Read prior findings. Do not treat them as current facts. |
| Test artifacts | `/home/orhun/Documents/hyprglass/tests/out/` | Compare old and new image results. |
| Archived plugin handoff | `git -C /home/orhun/Documents/hyprglass show diag-backup:HANDOFF.md` | Read the prior pills and damage investigation. |

## Official External References

Use the Quickshell 0.3.1 documentation. Do not use examples for an older
Quickshell version.

| Subject | URL |
|---|---|
| Quickshell guide | `https://quickshell.org/docs/v0.3.1/guide/` |
| Panel window | `https://quickshell.org/docs/v0.3.1/types/Quickshell/PanelWindow/` |
| Layer shell | `https://quickshell.org/docs/v0.3.1/types/Quickshell.Wayland/WlrLayershell/` |
| IPC handler | `https://quickshell.org/docs/v0.3.1/types/Quickshell.Io/IpcHandler/` |
| Wi-Fi | `https://quickshell.org/docs/v0.3.1/types/Quickshell.Networking/WifiNetwork/` |
| Bluetooth | `https://quickshell.org/docs/v0.3.1/types/Quickshell.Bluetooth/BluetoothDevice/` |
| PipeWire | `https://quickshell.org/docs/v0.3.1/types/Quickshell.Services.Pipewire/` |
| Quickshell changes | `https://quickshell.org/changelog/` |
| Current AGS guide | `https://aylur.github.io/ags/guide/quick-start.html` |

Confirm an API in official documentation before you use it. Do not assume that
an old blog post describes the current API.

## Current System Facts

The Eww panel uses one fixed `400x940` layer surface. The visible content uses
approximately 266 pixels when collapsed.

The Wi-Fi menu increases the visible height to approximately 558 pixels. The
unused part of the layer surface is transparent.

The active Hyprglass configuration uses these values:

```lua
hg.layer("control_center", {
  preset = "control_center_pills",
  mask_threshold = 0.02,
  pills = {
    threshold = 0.02,
    bezel = 8,
    corner_lobes = true,
  },
})
```

The current control-center preset disables refraction and chromatic
aberration. Preserve this behavior.

## Current Worktree Warning

The Hyprglass worktree contains uncommitted pill-depth work. It also contains
an uncommitted duplicate-plugin guard and related tests.

The dotfiles patch can contain plugin changes that are not in Hyprglass
`HEAD`. Confirm patch parity before each package build.

Do not regenerate the package patch from `HEAD` until required plugin changes
are committed. A patch from `HEAD` can remove uncommitted behavior.

## Implementation Order

Use this order:

1. Stabilize the current plugin tests.
2. Prove Quickshell rendering in the nested compositor.
3. Add the Hyprglass background-distance field.
4. Port the control-center shell to Quickshell.
5. Port each system service.
6. Update external callers and startup.
7. Run nested and live tests.
8. Build a complete NixOS generation.
9. Boot the new generation.
10. Remove Eww after final acceptance.

Do not port all services before the Quickshell rendering test passes.

## Safety Rules

1. Do not remove unrelated user changes.
2. Do not use destructive Git commands.
3. Do not commit unless the user requests a commit.
4. Do not create a remote request or issue.
5. Do not activate Home Manager during plugin hot-load tests.
6. Do not load a second Hyprglass plugin instance.
7. Do not use a stale Hyprland IPC signature.
8. Do not run live tests without `HG_LIVE=1`.
9. Do not change the live session during nested tests.
10. Do not remove Eww before the rollback gate passes.

## First Implementation Milestone

The first context must establish a reliable baseline.

1. Fix stale plugin reuse in `tests/run.sh`.
2. Add `misc:vfr = false` to the nested fixture.
3. Make `make test` run tier 0 and nested tests only.
4. Run `make test-tier0`.
5. Run `make test-nested`.
6. Record artifact paths for each failure.
7. Diagnose each failure before Quickshell work starts.

An explicit `HG_TEST_SO` can select a supplied plugin. An implicit cached path
must match the current source or cause a new build.

## Context Handoff Rule

At the end of each context, write a factual handoff in the final response.
Include changed files, test commands, results, artifacts, and unresolved risks.

The next context must read that handoff and inspect the current Git diff. The
next context must not rely on a statement that conflicts with current files.

## Glossary

| Term | Meaning |
|---|---|
| Alpha carrier | A low-alpha painted sheet that supplies the outer boundary. |
| Base sheet | The continuous background glass behind the controls. |
| JFA | The jump-flood algorithm that computes a pixel distance field. |
| Pill | One independent glass control from the high-alpha mask. |
| Fresh frame | A frame after explicit full damage or configuration reload. |
| Natural frame | A frame after normal animation and surface commits. |
| Live blur | Blur that updates when content behind the panel changes. |
| Nested compositor | The isolated Hyprland instance used by automated tests. |
