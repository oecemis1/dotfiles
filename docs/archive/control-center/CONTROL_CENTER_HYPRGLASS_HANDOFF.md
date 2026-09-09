# Control Center Hyprglass Handoff

## Purpose

This document specifies the plugin work for the control-center background
sheet. Read `CONTROL_CENTER_IMPLEMENTATION_HANDOFF.md` first.

## Goal

Render a live blurred sheet behind the independent controls. Reduce the visible
blur smoothly near the current outer sheet boundary.

The boundary must follow menu expansion, menu collapse, and panel animation.
The implementation must not use a captured screenshot.

## Existing Pipeline

Hyprglass redirects layer rendering into a transparent framebuffer. The plugin
uses the framebuffer alpha as a glass mask.

The plugin computes one JFA field for alpha-derived pills. Pixels below the
pill threshold are field seeds.

The liquid-glass shader uses these texture units:

| Unit | Current use |
|---|---|
| 0 | Base blurred background |
| 1 | Layer mask texture |
| 2 to 4 | Optional blur variants |
| 5 | Pill JFA field |

Use texture unit 6 for the background JFA field. Confirm the current bindings
before you edit the code.

## Current Limitation

The current mask is binary. `surfacePixel.a` selects or rejects a fragment.

The shader does not use surface alpha to scale the glass result. A client alpha
gradient therefore produces full glass and then a cutoff.

The current `background = true` setting applies to the region path. It does not
create a smooth background fade.

## Selected Design

Compute a second alpha-distance field. This field measures the distance from a
sheet pixel to the current transparent boundary.

Keep the existing pill field. The two fields use different seed thresholds.

| Field | Seed condition | Use |
|---|---|---|
| Pill field | Alpha is below `pill.threshold` | Compute pill bevel geometry. |
| Background field | Alpha is below `mask_threshold` | Compute sheet fade coverage. |

Do not combine these fields. A low-alpha sheet pixel is a pill-field seed. The
same pixel is not a background-field seed.

## Output Model

The plugin does not change Gaussian radius for each pixel. The plugin changes
the glass contribution near the boundary.

The compositor then mixes the blurred result with the unmodified background.
This operation creates the required visual blur fade.

Use this coverage model:

```glsl
float coverage = smoothstep(1.0, max(backgroundFadePx, 1.0), boundaryDistance);
float glassA = glassOpacity * cornerAlpha * coverage;
```

Use coverage `1.0` for pills. Use coverage `1.0` for normal windows. Use
coverage `1.0` when no background fade is configured.

## Proposed Lua Interface

Add these Lua-only layer settings:

```lua
hg.layer("control_center", {
  preset = "control_center_pills",
  background = true,
  background_fade = 24,
  live_blur = true,
  mask_threshold = 0.004,
  pills = {
    threshold = 0.032,
    bezel = 8,
    corner_lobes = true,
  },
})
```

`background_fade` uses logical pixels. Zero disables the fade and preserves
the current output.

`live_blur` forces background sampling when the layer renders in a damaged
frame. This setting keeps terminal and video content current behind the sheet.

Require `background = true` when `background_fade` is nonzero. Report a clear
configuration warning for an invalid combination.

Do not add a legacy `.conf` form in the first implementation.

## Alpha Bands

The Quickshell surface will paint one low-alpha sheet below all controls. The
control backgrounds will use a higher alpha.

Use these values as initial test values:

| Value | Initial setting |
|---|---|
| Mask threshold | `0.004` |
| Sheet alpha | `0.012` |
| Pill threshold | `0.032` |

The sheet changes the final control alpha. Use this equation for threshold
tuning:

```text
combined alpha = control alpha + sheet alpha * (1 - control alpha)
```

The old control threshold was `0.02`. A sheet alpha of `0.012` gives an adjusted
threshold of approximately `0.032`.

Confirm the values with `debug = "mask"`. Confirm attribution with
`debug = "attribution"`.

The alpha carrier remains part of the client surface. Select its color as an
intentional sheet tint. Do not use the carrier as hidden metadata.

## Configuration Types

Do not add unrelated primitive maps without a semantic type. Group background
fade settings in a small configuration type when current code style permits.

The type must reject these values:

- Negative fade width
- Non-finite fade width
- Invalid boolean values from Lua

The reload path must remove omitted settings. A second `hg.layer()` call for
the same namespace replaces the first call.

## Required Source Changes

### `src/PluginConfig.hpp`

1. Add the semantic background-fade configuration type.
2. Add pending and active values for `background_fade`.
3. Add pending and active values for `live_blur`.
4. Document the Lua-only interface.

### `src/PluginConfig.cpp`

1. Extend `SPendingLayer`.
2. Parse `background_fade` in `handleLuaLayer()`.
3. Parse `live_blur` in `handleLuaLayer()`.
4. Check each value before storage.
5. Replace old namespace values during `commitPendingLayers()`.
6. Remove omitted values during replacement.
7. Report invalid combinations during configuration validation.

Preserve the behavior that commit `e513aca` introduced for duplicate layer
namespaces.

### `src/Globals.hpp`

1. Add active per-namespace background-fade state.
2. Add active per-namespace live-blur state.
3. Use semantic types when they improve invalid-state prevention.

### `src/main.cpp`

1. Clear the new active maps before configuration reload.
2. Commit the pending values after the reload.
3. Preserve the current plugin duplicate-load guard.

Do not add a second call that loads the plugin. Do not change live plugin
lifecycle in this feature.

### `src/GlassRenderer.hpp`

1. Generalize `computePillField()` into an alpha-distance function.
2. Add a seed-threshold parameter.
3. Add an outer-border seed option.
4. Extend `SMaskInfo` for the background field.
5. Store background texture, size, and fade width.

The generalized function must still produce the current pill field output.

### `src/GlassRenderer.cpp`

1. Keep GL nearest-neighbor filtering for all field textures.
2. Disable blending during all packed-field passes.
3. Bind the background field to texture unit 6.
4. Upload the new background uniforms.
5. Preserve units 0 through 5.

Reassert nearest-neighbor filtering at each packed-field bind. Do not rely only
on allocation-time texture state.

### `src/ShaderManager.hpp`

Add uniform locations for these values:

- Background JFA texture
- Background JFA size
- Background fade width
- Background field enabled state

Add a JFA initialization uniform only if the border-seed mode needs one.

### `src/ShaderManager.cpp`

1. Resolve each new liquid-glass uniform.
2. Resolve each new JFA uniform.
3. Preserve shader compile failures as build-time test failures.

### `src/Shaders.hpp`

1. Add the background-field sampler.
2. Add a background-distance helper.
3. Generalize the JFA initialization shader.
4. Seed the outer field border for background mode.
5. Identify the base-sheet path before `applyGlass()`.
6. Pass coverage into `applyGlass()`.
7. Keep pill coverage at `1.0`.
8. Keep declared-region coverage unchanged.
9. Keep normal-window coverage unchanged.
10. Add `background_field` debug output.

Do not change pill lighting while you add the background field. The worktree
already contains separate pill-depth changes.

### `src/GlassLayerSurface.hpp`

Add these resources and cache values:

- Background JFA ping framebuffer
- Background JFA pong framebuffer
- Last sampled transformed box
- Background-fade lookup helper
- Live-blur lookup helper

Use names that follow current project style.

### `src/GlassLayerSurface.cpp`

1. Extend `damageOnCommit()` to background-fade layers.
2. Damage the old expanded box after movement or shrink.
3. Damage the new expanded box after movement or growth.
4. Include transformed geometry in the sample cache key.
5. Force a sample when `live_blur` applies.
6. Compute the pill field with the pill threshold.
7. Compute the background field with the mask threshold.
8. Scale both thresholds during compositor fades.
9. Pass both fields to `GlassRenderer::applyGlassEffect()`.

The field must update after client content changes. The blurred background can
remain cached when `live_blur` is false.

## Border Seeding

The control center touches the top and right sides of its fixed layer box. The
field has no client pixels beyond those sides.

Treat each outer field-border pixel as a transparent seed. This rule creates a
fade at all four possible sheet edges.

Do not use border seeding for the pill field. Border seeding can change a pill
that touches the layer boundary.

## Damage Rules

Use the layer resource commit signal. A surface commit can change all mask
geometry without changing the layer box.

Damage the complete expanded layer box after a relevant commit. Increment the
monitor scene generation for the affected monitor.

When the box changes, damage both box versions. This rule prevents old pixels
after a shrink.

## Blur Cache Rules

The current cache can miss content-only updates behind the panel. Window focus
or movement events do not represent all terminal and video updates.

When `live_blur` is true, resample during each damaged render of the layer.
Do not create an independent timer in the plugin.

When `live_blur` is false, preserve the current cache optimization.

## Debug Mode

Add this value:

```lua
debug = "background_field"
```

Display normalized distance as grayscale. Use black at seeds. Use white at the
configured far limit.

Do not change the existing debug colors:

- Cyan for pills
- Yellow for the background slab
- Blue for sub-threshold pixels
- White for remaining slab pixels

These colors provide more than a red-green distinction.

## Plugin Tests

Add configuration variants for these cases:

- Fade with pills
- Fade without pills
- Zero fade
- Invalid negative fade
- Invalid non-finite fade
- Duplicate layer replacement
- Live blur enabled
- Live blur disabled
- Background-field debug mode

Add nested tests for these properties:

1. The outer profile increases monotonically.
2. The outer profile has small second differences.
3. The interior matches full background blur.
4. The exterior matches the raw background.
5. The carrier does not move pill boundaries.
6. A menu reveal moves the outer field boundary.
7. A menu collapse removes the old field boundary.
8. A background update changes live blur output.
9. A fresh frame matches the natural frame.
10. A layer replacement removes omitted fade settings.
11. A close and reopen leaves no old field.
12. A top-edge sheet receives a correct fade.
13. A right-edge sheet receives a correct fade.

Suggested test numbers are 27 through 29 and 36 through 39. Check current test
numbers before you create files.

## Performance Limits

The feature can add one JFA field for a configured layer. Do not compute this
field for unrelated layers.

Do not allocate field framebuffers on every frame. Reuse framebuffers and
resize them only when required.

Do not add continuous screen capture. Do not add a CPU image-processing path.

## Non-Goals

- Per-pixel Gaussian radius
- Screenshot-based production blur
- Changes to normal window glass
- Changes to pill lighting
- New legacy `.conf` settings
- A general compositor blur protocol
- A separate backdrop process

## Acceptance Criteria

1. The collapsed sheet follows the visible content boundary.
2. The expanded sheet follows the visible content boundary.
3. Blur coverage changes smoothly across the configured width.
4. The exterior remains unchanged.
5. Pills remain independent glass slabs.
6. Pill depth remains unchanged.
7. No stale row remains after reveal or collapse.
8. Terminal output changes remain visible through live blur.
9. Normal windows produce the same screenshots as before.
10. Shader validation succeeds for every embedded shader.
11. The feature adds no screenshot process.
12. The feature adds no duplicate plugin instance.
