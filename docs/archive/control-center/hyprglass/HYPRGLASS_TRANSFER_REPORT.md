# Hyprglass Transfer Report

## Purpose

This report transfers the current Hyprglass control-center work to another engineer.

The user rejected the visual result. The result did not match the requested optical quality.

The tests measured correct behavior. They did not prove an acceptable appearance.

## Requested Result

The user wanted a visible liquid-glass effect with these properties:

- Clear background refraction
- Visible magnification
- Broad glass-body depth
- A narrow optical contour
- Bright upper-left and lower-right corner radiation
- True child glass above parent glass
- No large exterior blur or halo
- Stable behavior during control movement and menu animation

The numbered reference images are in this directory:

`/home/orhun/Documents/control_center_ref_images`

Images 2 through 4 show single glass surfaces.

Images 5 through 7 show parent and child glass surfaces.

## User Assessment

The user considers the current result unacceptable.

Do not use the passing tests as evidence that the appearance is acceptable.

The implementation produced measurable optical changes. The visible changes remained too weak and too flat.

## Important Limitation

The new lens changes only the sampled background.

The lens does not change the positions of text, icons, or other layer content.

The lens uses the nearest alpha boundary. It does not know each control's center or complete bounds.

The result is a shape-following extrusion. It is not a component-centered isotropic dome.

Long controls receive mostly normal-axis magnification along their straight edges.

Thin controls reduce the lens near the medial axis. This reduction prevents a direction discontinuity.

These properties limit the visible body depth.

## Why The Tests Were Insufficient

The phase test used strong synthetic lens values of `1.12` and `1.18`.

The production configuration used values of `1.025` and `1.06`.

The phase test proved that the shader followed its formula.

The phase test did not prove that the production values looked good.

The glass-on-glass test used an eight-pixel checkerboard.

The checkerboard exposed displacement and containment. It did not represent a normal desktop background.

The reference analyzer measured blur, edge energy, and selected image regions.

The analyzer could not recover physical refraction from the reference images.

The reference images do not include their original backgrounds or material masks.

The implementation did not use a required visual similarity gate.

The implementation selected a middle numeric candidate before a complete production optics sweep.

The tests therefore optimized mathematical correctness more than visual quality.

## Current Architecture

The control center uses two compositor surfaces.

`control_center_backdrop` uses `WlrLayer.Top`.

`control_center` uses `WlrLayer.Overlay`.

The child surface samples the completed parent surface.

Both surfaces use fixed `416x956` carriers at screen position `1176,40` in the nested fixture.

The visible panel starts at screen position `1184,48`.

The visible clips and material heights change with the control-center layout.

A transparent damage proxy clears old parent material after a menu closes.

Do not merge the two surfaces.

Do not remove the damage proxy without a replacement test.

## Implemented Plugin Change

The plugin accepts this optional Lua configuration:

```lua
pills = {
  lens = {
    magnification = 1.06,
    width = 20,
  },
}
```

The plugin accepts `magnification` values from `1.0` through `1.25`.

The plugin accepts `width` values from 8 through 48 logical pixels.

The parser requires both values.

The parser ignores the complete lens object when one value is invalid.

An omitted lens preserves the old compact bevel.

The shader uses the existing jump-flood field.

The shader adds one conditional field sample in the broad lens area.

The shader does not add a framebuffer, texture, readback, or render pass.

The shader calculates peak displacement with this formula:

```text
A = width * (magnification - 1) / (1.5 * magnification)
```

The shader uses a cubic contour-distance profile.

The shader uses a short inward probe near a medial axis.

The probe reduces the lens before the nearest boundary changes.

## Production Values

The generated configuration contains these values:

```text
Parent refraction:       0.03
Parent magnification:    1.025
Parent lens width:       20
Parent Fresnel:          0.12
Parent specular:         0.12

Child refraction:        0.08
Child magnification:     1.06
Child lens width:        20
Child Fresnel:           0.35
Child specular:          0.45
Child corner lobes:      enabled
```

Both surfaces keep chromatic aberration at zero.

Both surfaces keep the generic center-dome lens at zero.

The QML sheet border is transparent.

The QML control border is transparent.

The low-alpha fills still define the material masks.

The hand-owned override contains the same production values:

`/home/orhun/.config/hypr/hyprglass.lua`

## Current Graphical Session

One Quickshell process was active during the last check.

The process used `/home/orhun/.config/quickshell`.

The control-center IPC service was available.

The IPC method `isOpen` returned `false`.

No `control_center` surface was mapped during the check.

This work did not activate the new NixOS closure.

This work did not reload the hand-owned Hyprglass override.

Do not assume that the current session uses the new plugin binary.

## Changed Hyprglass Files

The main plugin changes are in these files:

- `src/PluginConfig.hpp`
- `src/PluginConfig.cpp`
- `src/GlassLayerSurface.cpp`
- `src/GlassRenderer.hpp`
- `src/GlassRenderer.cpp`
- `src/ShaderManager.hpp`
- `src/ShaderManager.cpp`
- `src/Shaders.hpp`
- `README.md`
- `PILL_DEPTH_PLAN.md`

The new optical tests are in these files:

- `tests/visual/analyze-optics.sh`
- `tests/visual/optics-manifest.json`
- `tests/visual/self-test.sh`
- `tests/visual/README.md`
- `tests/nested/quickshell-optics/shell.qml`
- `tests/nested/50-green-optics-mapping.sh`
- `tests/nested/51-red-pill-lens-config.sh`
- `tests/nested/conf/variants/36-valid-pill-lens.lua`
- `tests/nested/conf/variants/37-invalid-pill-lens.lua`
- `tests/nested/conf/variants/38-pill-lens-replacement.lua`

## Changed Dotfiles Files

The production changes are in these files:

- `/home/orhun/Documents/dotfiles/modules/home/linux/_hyprland/hyprland.nix`
- `/home/orhun/Documents/dotfiles/.config/quickshell/Theme.qml`
- `/home/orhun/Documents/dotfiles/pkgs/hyprglass.nix`
- `/home/orhun/Documents/dotfiles/pkgs/hyprglass-pill-optics.patch`
- `/home/orhun/Documents/dotfiles/CONTROL_CENTER_PROGRESS_HANDOFF.md`

The complete worktrees contain many earlier uncommitted changes.

Do not revert unrelated changes.

## Package Patch Order

The Nix package applies these patches in this order:

1. `hyprglass-regions.patch`
2. `hyprglass-pill-corners.patch`
3. `hyprglass-background-field.patch`
4. `hyprglass-pill-optics.patch`

Do not regenerate `hyprglass-regions.patch`.

The fourth patch applies to the exact three-patch source.

The fourth patch reproduces the reviewed optical source.

## Test Results

The final tier-zero test result was:

```text
4 passed
/home/orhun/Documents/hyprglass/tests/out/20260830T173019Z
```

The visual analyzer self-test passed.

The full nested test result was:

```text
34 passed
/home/orhun/Documents/hyprglass/tests/out/20260830T171317Z
```

The focused phase test measured these values:

```text
Requested parent magnification: 1.12
Measured parent magnification:  1.1118

Requested child magnification:  1.18
Measured child magnification:   1.1856

Composition p95 error:          0.236 px
Exterior displacement:          0 px
```

The phase test artifacts are here:

`/home/orhun/Documents/hyprglass/tests/out/20260830T170557Z`

The packaged binary also passed the focused tests:

```text
/home/orhun/Documents/hyprglass/tests/out/20260830T172458Z
/home/orhun/Documents/hyprglass/tests/out/20260830T172529Z
```

These results prove mapping, containment, and stability.

These results do not prove acceptable visual quality.

## Build Results

The packaged plugin is here:

`/nix/store/nvilkar344cccjj878m8j59m6awydjrn-hyprglass-0.7.0-regions/lib/libhyprglass.so`

The complete build output link is here:

`/tmp/opencode/odyssey-pill-optics-system`

The build succeeded.

The build was not activated.

## Safe Deployment Rule

Do not load a changed plugin into the active compositor.

Do not load two Hyprglass plugin instances.

Build the complete NixOS generation before activation.

Activate the generation with this command only after review:

```bash
sudo nixos-rebuild switch --flake 'path:/home/orhun/Documents/dotfiles#odyssey'
```

End the graphical session after activation.

Start a new graphical session.

## Recommended Technical Direction

Do not continue to tune only the current two lens values.

First, define a visible acceptance image with a normal desktop background.

Use the same background for each candidate.

Use the numbered references only for visual direction.

Require the user to approve one production screenshot before final packaging.

If the user wants a centered dome, add semantic control geometry.

Supply each control center, size, and stable identity to the plugin.

Do not infer a centered dome from nearest-boundary distance alone.

If semantic geometry is not available, use a wider meniscus model.

Add broad body lighting and absorption to that model.

Keep the compact rim separate from the broad body profile.

Measure exterior spill and center-seam stability for every candidate.

Use synthetic tests as safety gates only.

Do not use synthetic tests as the visual acceptance gate.

## Rollback Values

Use these values to restore the previous flat production configuration:

```text
Parent refraction:       0.0
Parent Fresnel:          0.12
Parent specular:         0.12

Child refraction:        0.0
Child Fresnel:           0.25
Child specular:          0.30
Child corner lobes:      disabled
```

Remove both `pills.lens` objects.

Restore `sheetBorder` to `#24ffffff`.

Restore `controlBorder` to `#38ffffff`.

Remove `hyprglass-pill-optics.patch` from `pkgs/hyprglass.nix` if the plugin API is not required.

Keep the first three package patches in their current order.

Update `/home/orhun/.config/hypr/hyprglass.lua` with the same rollback values.

Do not reload the plugin binary in the active compositor.

## External Research

The implementation research used these repositories:

- `https://github.com/winaviation/liquid-web`
- `https://github.com/sdegenaar/liquid_glass_widgets`

The research used their decomposition and equations as references.

The project did not add either repository as a runtime dependency.

## Final Status

The code compiles.

The package builds.

The automated tests pass.

The user rejects the visual result.

Treat the visual result as a failed product outcome.
