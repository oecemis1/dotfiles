# Pill Border Depth Plan

## Goal

Give alpha-derived pills a dimensional glass border with:

- Convex refractive bevel
- Bright top-left rim
- Darker bottom-right inner edge
- Narrow border glare
- Smooth rounded corners

Theme tint and typography remain controlled by eww CSS.

## Implementation

1. Keep the existing JFA field as the pill boundary source.
2. Convert `boundaryDist / pillBezelPx` into a smooth bevel profile.
3. Derive a pseudo-surface normal from the JFA boundary direction and bevel slope.
4. Use a fixed top-left light direction to calculate:
   - Diffuse rim lighting
   - Opposing inner shadow
   - Narrow specular glare
5. Drive refraction strength from the bevel slope rather than only exponential edge proximity.
6. Apply the new lighting only inside the pill shader path.
7. Reuse existing settings initially:
   - `pills.bezel`
   - `refraction_strength`
   - `fresnel_strength`
   - `specular_strength`
8. Do not add configuration keys unless the existing controls cannot tune the result adequately.
9. Do not change the normal terminal/window rendering path.

## Main Files

- `src/Shaders.hpp`
  - Replace the pill path's basic `specBias` and `shadowBias` calculation.
  - Add the bevel profile, normal, directional lighting, and glare.
- `tests/nested/`
  - Add deterministic pixel assertions for pill lighting.
- `README.md`
  - Document the dimensional pill border after tuning is complete.

## Tests

1. All shaders compile.
2. The JFA field remains smooth and correctly shaped.
3. The top-left pill edge is brighter than the bottom-right edge.
4. Glare has a narrow peak near the boundary.
5. The interior remains clearer and less reflective than the bevel.
6. No effect appears outside the pill mask.
7. Moving and revealed pills retain correct lighting.
8. Terminal and window screenshots remain unchanged.
9. Live control-center verification passes over wallpaper and terminal backgrounds.

## Tuning Order

1. Bevel width
2. Refraction displacement
3. Inner shadow strength
4. Fresnel rim
5. Specular glare width and intensity
6. Final transparency check

## Non-Goals

- Moving or animated glare
- Theme tint inside Hyprglass
- Changes to terminal glass
- Center-dome distortion for pills in the first pass

## Shape-Following Lens Follow-Up

The follow-up implementation adds an optional broad lens to alpha-derived
pills without introducing component metadata or another render pass:

```lua
pills = {
  lens = { magnification = 1.06, width = 20 },
}
```

The lens uses the nearest transparent JFA seed as an outward direction and a
cubic contour-distance profile for normal magnification. A short inward probe
attenuates the profile before nearest-boundary ownership flips at a medial axis.
This keeps moving and revealed controls stable while preserving the first-pass
compact bevel when the lens is omitted.

Physical mapping is covered by `tests/visual/analyze-optics.sh` and
`tests/nested/50-green-optics-mapping.sh`. Invalid and replacement semantics
are covered by `tests/nested/51-red-pill-lens-config.sh`.
