# Control Center Background Blur Handoff

## Goal

Add a macOS-like blurred sheet behind the Eww control center while preserving
the independently rendered Hyprglass pills. The blur should weaken toward the
current outer boundary of the panel, including when a menu expands.

## Existing State To Preserve

- Hyprglass renders the individual `control_center` pills.
- The control-center root `.cc` is transparent in the active
  `~/.config/eww/styles/_overrides.scss`.
- The pill mask threshold is `0.02` and corner lobes are enabled only for the
  control center.
- Control-center pill refraction and chromatic aberration are disabled.
- The pill styling, shader changes, package patch, and Hyprglass configuration
  predate this background-blur attempt and were intentionally not reverted.

## What Was Learned

### Hyprland Native Layer Blur

Hyprland native layer blur can be enabled per namespace and can discard pixels
below `ignore_alpha`, but the surface alpha acts as a binary mask. It does not
continuously scale blur strength through an Eww CSS alpha gradient. Native blur
can make a hard or antialiased boundary, but it cannot produce the requested
gradual blur-strength dissipation by itself.

### GTK/Eww CSS Attempts That Failed

- Stacked background-image boxes with increasing CSS `margin` did not clip the
  painted backgrounds; all copies rendered at full allocation.
- `background-clip: padding-box` was ineffective in this GTK3 path.
- Parent `opacity: 0` did not reliably suppress descendant widget painting.
- A fixed 400x940 backdrop layer exposed GTK's gray window canvas below the
  content and produced the large gray rectangle seen during testing.

### Screenshot Backdrop Prototype

The prototype that eventually rendered correctly did this:

1. Before opening the panel, capture its 400x940 screen region with `grim -s 1`.
2. Blur the capture with ImageMagick using `-blur 0x18`.
3. Open a separate Eww `fg` layer named `control_center_backdrop`, below the
   overlay-layer panel and click catcher. This keeps the backdrop out of the
   Hyprglass `control_center` mask.
4. Give that layer a nominal height of 1px and let its content determine the
   real height, avoiding the fixed gray rectangle.
5. Use a homogeneous Eww `stack`: an empty selected child is painted, while an
   unselected `control_center_widget` supplies the exact live dimensions.
6. Poll the backdrop layer geometry while the panel is open. When its height
   changes, crop the blurred source and create an alpha mask with:

   ```text
   roundrectangle inset 24px, radius 18px, Gaussian blur 0x12
   ```

7. Apply that mask with ImageMagick `CopyOpacity` and display the resulting PNG.

This was visually verified at 400x266 collapsed and 400x558 with the Wi-Fi menu
expanded. It produced a clean feathered boundary with no gray canvas and no
duplicate controls.

## Deployment Failures

- The first helper script was untracked, so Nix flake source filtering omitted
  it even though the other Eww files were activated.
- A Home Manager activation reloaded a declaratively configured Hyprglass into
  a compositor where the same plugin had already been hot-loaded. Hyprland
  crashed with two `hyprglass` entries in its crash report and entered safe
  mode.
- An attempted idempotent Lua plugin loader avoided the duplicate load, but a
  later Home Manager reload used a stale pre-crash Hyprland IPC signature.
- A subsequent manual reload was issued while the earlier reload was already
  unresponsive, and the compositor hung. Do not repeat live activation/reload
  testing without first controlling the active instance and plugin lifecycle.

## Reverted Files

The background-blur attempt was removed from:

- `.config/eww/widgets/control-center.yuck`
- `.config/eww/styles/control-center.scss`
- `.local/bin/eww-control-center-toggle`
- `modules/home/linux/hyprland.nix`
- `modules/home/linux/_hyprland/hyprland.nix`
- `~/.local/bin/eww-control-center-backdrop` (live temporary helper)

## Safer Next Attempt

1. Start from a normal compositor session with exactly one Hyprglass instance.
2. Do not use `nixos-rebuild switch` or Home Manager live activation while
   changing plugin loading. Build a boot generation and reboot instead.
3. Keep the backdrop in a separate namespace so it never joins the pill mask.
4. If reusing the screenshot design, keep all logic in tracked files from the
   start and test Eww separately from Hyprland configuration deployment.
5. Verify every test surface is closed by checking `hyprctl -j layers`.
