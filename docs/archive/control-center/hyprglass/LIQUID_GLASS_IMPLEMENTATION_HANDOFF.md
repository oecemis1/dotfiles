# Handoff for the Liquid Glass Implementation

## Document Purpose

This document is the primary source for the next implementation session.

Read this document before you read source files.

Do not repeat the research unless a source fact conflicts with the current code.

This document uses short instructions and controlled terms. It follows an ASD-STE100-inspired style.

## Start Procedure

1. Read this complete document.
2. Run `git status --short --branch`.
3. Do not revert existing changes.
4. Select the first incomplete phase in this document.
5. Read only the files that the selected phase lists.
6. Write tests before production code when the phase specifies tests.
7. Complete each phase before you start the next phase.
8. When a phase passes its exit condition, update its Phase Progress row and start the next incomplete phase in the same turn.
9. End your turn only in these cases. Phase 8 is complete. A required test fails and you cannot fix it inside the phase file list. A step needs a user decision. A tool permission was denied.
10. These steps need a user decision: Phase 9 step 8, Phase 10 step 6, a tolerance change, a commit, or a file deletion. A change to the live compositor of the user or to a hand-owned configuration file also needs a user decision.

Do not read `PILL_DEPTH_PLAN.md` unless you investigate the rejected optics.

Do not use `HYPRGLASS_TRANSFER_REPORT.md` as an acceptance record.

The user rejected the appearance that the report describes.

## Current Status

Phases 0 through 10 are complete, with the user-approved Phase 9 performance exception. See Phase Progress.

All Phase 1 through Phase 10 work is uncommitted in the worktree.

The last commit before this work is `ec9a104`, dated 2026-08-28.

Commit only when the user approves a commit.

The repository branch is `regions`.

The worktree contains many modified and untracked files.

Some changed files contain earlier control-center work.

Do not discard any worktree change unless the user identifies that change for removal.

Before you edit a changed file, inspect only its local diff.

Use this command:

```sh
git diff -- path/to/file
```

Do not run a destructive Git command.

## Objective

Replace the rejected Hyprglass optics with a new Liquid Glass engine.

The new engine must use LiquidGlass from OverShifted as its reproducible base.

The new engine must also include a convex Snell bezel from the kube.io study.

The production control center must send live semantic geometry to Hyprglass.

The result must preserve true parent and child glass composition.

## Required Visual Result

The result must show these properties:

- Clear background refraction.
- Visible component-centered magnification.
- Broad glass-body depth.
- A narrow optical contour.
- Bright upper-left and lower-right rim energy.
- A subtle white specular highlight.
- True child glass above parent glass.
- No large exterior blur halo.
- Stable optics during all control-center animations.

The user rejected the previous appearance because its refraction and body depth were not sufficiently visible.

Passing synthetic tests does not show visual acceptance.

The final gate requires a visual review of production captures.

## Locked Decisions

These decisions are final for the first implementation.

Exception approved during Phase 9: production uses the dense blur described in Approved Production Blur below. The seven-fetch upstream blur remains unchanged for standalone source-parity testing. Earlier exact-blur requirements apply to that parity path, not to the approved production kernel replacement.

1. Replace the current optics by default.
2. Do not keep the rejected optics as a selectable model.
3. Keep useful material and composition features.
4. Add live Quickshell geometry through a Unix socket.
5. Include the convex Snell bezel in the first implementation.
6. Keep the two control-center surfaces.
7. Use semantic centers and complete bounds for the centered mapping.
8. Keep clip boundaries separate from material boundaries.
9. Use the exact OverShifted mode as a differential test state.
10. Require human visual approval before deployment.

## Terms

Use these terms with the same meaning throughout the work.

| Term | Meaning |
|---|---|
| Base engine | The pinned OverShifted shader and blur behavior. |
| Centered mapping | The OverShifted curve that maps samples toward a semantic shape center. |
| Snell bezel | The narrow convex edge displacement from the kube.io equations. |
| Rim | The narrow edge mask that changes saturation and brightness. |
| Specular | The white highlight that uses the rim mask. |
| Material | Tint, tone, opacity, saturation, vibrancy, and blur settings. |
| Semantic shape | One protocol object with a stable ID, bounds, radius, role, and clip chain. |
| Material edge | A physical glass boundary that can have a bezel. |
| Clip edge | A reveal boundary that must not have a bezel. |
| Parent glass | The `control_center_backdrop` surface. |
| Child glass | The `control_center` surface. |
| Parity state | Base engine enabled with all non-base Hyprglass extensions disabled. |
| Rejected mapping | The current edge-normal mapping and the current JFA broad lens. |
| Carrier | The fixed `416x956` Wayland layer surface. |
| Canonical bounds | The complete live material bounds before an ancestor reveal clip applies. |
| Snapshot | One validated and committed set of surfaces, clips, and semantic shapes. |
| Transaction | Protocol records staged between `BEGIN` and `COMMIT`. |
| Epoch | One identifier for a Quickshell process lifetime. |
| Serial | An increasing snapshot number inside one epoch. |
| Mapping generation | An increasing number for each panel map cycle. |
| Monitor scene generation | A plugin counter that invalidates cached background samples on one monitor. |
| Shader generation | A plugin counter that increases after shader reinitialization. |
| Namespace | The Wayland layer-shell namespace that identifies a surface class. |
| Surface ID | The publisher ID for one logical PanelWindow inside one epoch. |
| Active surface | A surface that the publisher expects to map in the current panel cycle. |
| JFA | Jump Flooding Algorithm. It calculates a nearest-boundary field. |
| UV | Normalized two-dimensional texture coordinates. |
| IOR | Index of refraction. The Snell calculation uses this value. |
| FP16 | A framebuffer format with 16-bit floating-point channels. |
| HDR | High Dynamic Range rendering. |
| RMS | Root mean square error. |
| p95 | The 95th percentile of the selected error samples. |
| KiB | 1024 bytes. |
| CPU oracle | A CPU calculation that implements equations in this document. |
| Source oracle | A result from an unmodified pinned reference implementation. |
| Exact parity | The same equations, constants, pass order, and texture state within stated tolerances. |
| Mapping Jacobian | The two-by-two derivative matrix of a stated sample mapping. |
| Monotonic mapping | A mapping with a positive Jacobian determinant in the tested shape domain. This requirement applies only to the standalone incremental Snell mapping. |
| Nonfinite value | A NaN value or a positive or negative infinity value. |
| Check | A test assertion. |
| Validate | Parser or transaction acceptance of an input. |
| Certify | The conservative interval-subdivision proof for a Snell strength prefix. |
| Parity-bypass boolean | A configuration option or code flag that selects the parity boundary from user configuration or skips the centered-mapping acceptance rule. |
| Legacy parser | The Hyprland configuration parser that accepts runtime optical changes through `hyprctl keyword`. |

`Exact parity` does not require bitwise equality between different GPU drivers.

## Phase Progress

Update this table when a phase passes its exit condition.

Do not mark a phase complete before all required tests pass.

| Phase | Status | Evidence |
|---|---|---|
| 0. Protect existing work | Complete | See Phase 0 Evidence. |
| 1. Add mathematical oracles | Complete | See Phase 1 Evidence. |
| 2. Add typed configuration | Complete | See Phase 2 Evidence. |
| 3. Port the exact blur | Complete | See Phase 3 Evidence. |
| 4. Port the centered mapping | Complete | See Phase 4 Evidence. |
| 5. Add Snell bezel and rim | Complete | See Phase 5 Evidence. |
| 6. Add the geometry server | Complete | See Phase 6 Evidence. |
| 7. Publish Quickshell geometry | Complete | See Phase 7 Evidence. |
| 8. Integrate semantic shapes | Complete | See Phase 8 Evidence. |
| 9. Tune and accept | Complete with approved performance exception | User approved the dense frosting and root-owned expansion timing, then explicitly accepted the unresolved repeated-block performance result for packaging and deployment. See Phase 9 Evidence. |
| 10. Package and deploy | Complete | User activated the tested immutable closure and approved its live appearance. Active system/profile, deployed QML, plugin health, and geometry connection verified. See Phase 10 Evidence. |

### Phase 0 Evidence

- Branch `regions` and `git status --short --branch` recorded the dirty worktree while the engineer preserved unrelated changes.

### Phase 1 Evidence

- The independent C99 cross-check and oracle passed 147 of 147 checks in approximately `22.3 s`.
- Both `0.02` candidates passed.
- The standalone Snell-prefix validator rejected the exact `0.04` 9-degree corner regression.
- Tier 0 passed.
- The visual analyzer passed.

### Phase 2 Evidence

- Focused C++ validation passed 931 of 931 checks.
- The differential between C++ and the Phase 1 oracle passed for 56 of 56 objects.
- Complete cold validation took approximately `145 ms`, with cached repeats.
- Production tests cover snapshot precedence, bounded caches, complete lens removal, every failed-reload retention path, and valid recovery.
- Lua sanity passed.
- Tier 0 passed 5 of 5 checks.
- The oracle passed 147 of 147 checks.
- The visual analyzer passed.
- The Nix production build passed.
- Nested configuration and reload smoke tests `11`, `12`, `50`, and `51` passed.
- The nested checks do not claim optical GPU visual parity.
- `git diff --check` reported no errors.

### Phase 3 Evidence

- Post-review Tier 0 passed 7 of 7 checks at `tests/out/20260903T161831Z` (local only).
- Tier 0 covered native and transformed framebuffer contracts and logical pass bounds that are correct at each monitor scale.
- Tier 0 enforced source-tree plugin identity and tested all-or-nothing blur-variant planning without a compositor.
- The CPU oracle passed 151 of 151 checks.
- The visual analyzer passed.
- A Nix production build produced `/nix/store/3n0jl6ghq73r0rgd9chn1mf1vfznpszf-hyprglass-0.7.0-regions/lib/libhyprglass.so` (local only).
- Nested tests passed 37 of 37 tests at `tests/out/20260903T162115Z` (local only).
- Nested tests covered restoration of the target framebuffer with the same background and measured GPU transition profiles.
- Nested tests covered configuration-only cache invalidation without layer recreation and atomic fallback behavior that emits one warning.
- `git diff --check` reported no errors.

### Phase 4 Evidence

- Typed uniforms connect exact centered-superellipse parity and production rounded-rectangle mapping to stable material identities and real window radii.
- A new capture from the pinned OverShifted source executable passed across complete `256x256` shape bounds and a four-pixel exterior ring.
- The capture recorded `p95 = 1/255` and `RMS = 0.0013471` with current offline and full provenance checking.
- The independent CPU and C99 oracle passed 185 of 185 checks.
- Tier 0 passed 9 of 9 checks at `tests/out/20260904T174621Z` (local only).
- The visual analyzer passed and checked that unavailable required measurements cannot pass assertion mode.
- Nested mapping, composition, exterior, physical-displacement, and local-noise checks passed with zero advisories.
- The nested run is recorded at `tests/out/20260904T175317Z` (local only).
- `git diff --check` reported no errors.
- An independent agent review found no remaining Critical, High, or Medium Phase 4 defects.

### Phase 5 Evidence

- The canonical renderer implements typed centered-plus-Snell mapping, signed convex correction, and an independent narrow directional rim.
- The canonical renderer implements dual white specular lobes, opposing inner shadow, whole-layer radii, and fractional-scale behavior.
- The canonical renderer replaces optical snapshots at runtime and updates optics after legacy configuration keyword changes.
- JFA remains coverage-only.
- The independent CPU and C99 oracle passed 230 of 230 checks in `360.221 s`.
- Focused C++ validation passed 1,138 of 1,138 checks.
- The differential passed for 61 of 61 objects.
- Tier 0 passed 10 of 10 checks at `tests/out/20260905T185920Z` (local only).
- The visual analyzer passed.
- Nested typed, rejection, Snell, and rim tests `50`, `51`, and `55` passed with zero advisories.
- The nested run is recorded at `tests/out/20260905T175305Z` (local only).
- The opt-in legacy test measured change RMSE `0.100471` and restored the exact baseline.
- The legacy run is recorded at `tests/out/20260905T175518Z` (local only).
- A new capture from the pinned source executable passed full provenance across the complete `256x256` shape and four-pixel exterior ring.
- The source oracle recorded `p95 = 1/255` and `RMS = 0.0013470653`.
- The source-oracle status is `tests/visual/source-oracle-status.json` for run ID `20260905T184712Z-4049298`.
- The final pinned x86-64 plugin is `/nix/store/riy3dl7xk67r5bx2vn9nb7f57aj0vzb1-hyprglass-0.7.0-regions/lib/libhyprglass.so` (local only).
- A strict agent review found no Critical or High x86-64 implementation defects.
- Phase 5 met its exit condition.

### Phase 6 Evidence

- Phase 6 implemented immutable snapshots, bounded atomic parsing, same-user nonblocking sockets, map binding, disconnect cleanup, and scale-correct old and new damage.
- Semantic tests passed 957 of 957 checks under sanitizers.
- Socket tests passed 102 of 102 checks under sanitizers.
- Tier 0 passed 13 of 13 checks at `tests/out/20260905T234751Z` (local only).
- Nested tests passed 40 of 40 tests at `tests/out/20260906T000834Z` (local only).
- The nested run skipped the isolated legacy test.
- Two agent reviews found no remaining Critical, High, or Medium Phase 6 defects.

### Phase 7 Evidence

- `GlassGeometryPublisher.qml` publishes complete two-namespace transactions from live production items with one process epoch and monotonic serials.
- The publisher sends zero inactive shapes, eight collapsed shapes, nine expanded shapes, and two active reveal clips.
- The publisher forces settled layout, coalesces each frame, recreates failed sockets, resends after reconnect, and advances mapping generation after remap.
- Production test 40 passed strict protocol, animation, resize, retry, reconnect, coalescing, and generation checks.
- Production service tests 40 through 48 passed 9 of 9 tests at `tests/out/20260906T010823Z` (local only).
- An agent review found no remaining Critical, High, or Medium Phase 7 defects.
- The dotfiles QML diff passed `git diff --check`.

### Phase 8 Evidence

- Valid semantic bindings replace declared regions and alpha-derived pills with complete canonical rounded-rectangle geometry.
- Per-shape reveal clips apply after canonical shape selection, preserve material centers, and create no optical boundary.
- Empty, removed, disconnected, stale, ambiguous, over-capacity, and unsupported semantic bindings cannot retain old optical shapes.
- Shader initialization queries fragment uniform capacity, retries a non-semantic shader after semantic-array link failure, and reports disabled namespaces once per shader generation.
- Production control-center presets use the first typed parent and child Snell and rim candidates. The rejected JFA pill settings and obsolete normalized `edge_thickness` values are absent.
- Test 54 passed centered X/Y mapping, composition, exterior, movement, independent protocol clipping, removal, reconnect, and material-local noise checks with zero failures or advisories.
- Final test 54 semantic metrics were `moved=0.0545664`, `stale=0`, `clip=0`, `hidden=0`, `removed=0`, and `reconnect=0`.
- Production glass-on-glass test 49 passed with semantic geometry and preserved parent-child surface order.
- Production and optical nested tests 40 through 57 passed 17 of 17 applicable tests at `tests/out/20260906T025538Z` (local only). Opt-in legacy test 56 was skipped.
- Tier 0 passed 13 of 13 checks at `tests/out/20260906T020950Z` and again after the final shader changes at `tests/out/20260906T022815Z` (local only).
- The independent CPU and C99 oracle passed 230 of 230 checks in `355.304 s`, and the visual analyzer passed.
- The refreshed pinned-source oracle is current at run ID `20260906T024516Z-460077`.
- Focused source, shell, QML, and production Nix diffs passed whitespace and syntax checks.
- Final independent review found no remaining Critical, High, or Medium Phase 8 defects.
- Phase 8 met its exit condition.

### Phase 9 Evidence

- The user authorized capture-tooling changes and build/test helper reads for an isolated production review. No live compositor or hand-owned configuration changes were authorized or made.
- `tests/visual/capture-production-review.sh` extracts production presets from `hyprland.nix`. Raw disables glass; parent, child, and stacked variants explicitly restrict namespace selection.
- The first validated review is `tests/out/20260907T135148Z/capture-production-review`. It contains a normal city wallpaper and a generated terminal-text background with no personal session data.
- The review uses the existing Phase 8 candidate presets without further material tuning. `review.png` shows collapsed, menu-expanded, and power-expanded stacked materials.
- All eight stage reloads passed configuration-error and notification checks. A negative Lua-evaluation probe verifies that an IPC failure cannot pass as an empty notification list.
- Source identity `a578aedf3e015086adfa3eaf14ad7721b20603654540ce586cff078302bbc9ed` matches the canonical build helper and remained unchanged during capture. Config, QML, and binary hashes are recorded in `source-identity.json`.
- Publisher-side geometry snapshots and socket connectivity are recorded. These are not a server-side binding acknowledgement.
- Child-only gaps match raw, and exposed parent gaps match stacked exactly on both backgrounds. Parent and child material regions differ from raw.
- The short temporary Quickshell runtime option avoids PID-dependent socket pathname failures. The ownership/cleanup test passed, and nested test 49 passed with that option at `tests/out/20260907T135704Z`.
- Independent review found no High or Medium issues in the first-material-review capture scope. Owned nested processes were cleaned up after capture.
- Animation probes are explicitly unsynchronized. Frame-accurate animation review, Wi-Fi password-transition capture, a separate broad-color wallpaper view, the 300-frame GPU timing comparison, and user visual approval remain pending.
- Do not package or deploy based on this first review alone.
- User feedback rejected the faded-alpha appearance and clarified that physical glass presence must work without blur or frosting. Do not use stronger blur to conceal weak optical structure or change menu layout to match the reference.
- Clear optical diagnostic `tests/visual/clear-glass.lua` is available through `capture-production-review.sh --clear-glass`. Unique diagnostic presets avoid duplicate production-preset registration. Production config is unchanged.
- Validated clear capture: `tests/out/20260907T143817Z/capture-production-review`. `clear-comparison.png` compares production (left) with the clear diagnostic (right) on identical city and generated terminal backgrounds.
- The diagnostic uses glass opacity 1, zero blur iterations/radius, zero grain, neutral tone and glow, unchanged centered/Snell mappings, and directional white rims. Zero blur still includes the existing half-size linear resampling; QML fills remain unchanged.
- Clear capture passed all 327 recorded checks, including namespace isolation, eight reload error checks, and the negative Lua IPC failure probe. Independent review found no High or Medium issues in this diagnostic scope. Original and diagnostic raw QML panel crops are byte-identical.
- The user accepted the clear-glass direction and requested frosting and blur next. This is not final production visual acceptance.
- `tests/visual/frosted-glass.lua` inherits the approved clear diagnostic and overrides only blur: parent radius 5, child radius 3, one iteration each. Opacity remains 1; mappings, directional rims, tone, grain, and QML layout remain unchanged.
- Validated frosted capture: `tests/out/20260907T150251Z/capture-production-review`, generated with `capture-production-review.sh --frosted-glass`. `frosted-comparison.png` shows clear (left) versus frosted (right) on identical backgrounds.
- All 327 capture checks passed, including exact diagnostic preset bindings, stage isolation, eight reload error checks, and the negative Lua IPC probe. Independent review found no High or Medium issues in this capture scope. Clear and frosted raw panel crops match when the hardware cursor is excluded.
- The blur support fits the fixed 60-framebuffer-pixel padding at scales 1, 1.25, and 2 by the support equation; these captures empirically test scale 1 only. GPU timing remains unmeasured.
- Frosted-material visual feedback remains pending. Production settings, live compositor, and hand-owned configuration remain unchanged.
- The user reported parent pixelation and requested lighter parent frosting. The current diagnostic parent blur radius is 2.5, down from 5; child blur remains 3 and all other settings are unchanged.
- Lighter-parent capture: `tests/out/20260907T152358Z/capture-production-review`, with `lighter-parent.png` for comparison. All 327 capture checks passed; independent review confirmed child-only panel pixels are unchanged outside hardware cursor footprints.
- Coarse and repeated texture remains visible over the text background. The lighter preset is not a pixelation fix; its root cause has not been established. User review and any expanded renderer investigation remain pending.
- The user accepted the lighter-parent direction and requested continued artifact investigation. Keep parent radius 2.5 and child radius 3 while investigating sampling; do not compensate with opacity or layout changes.
- Read-only renderer and image reviews found no evident filtering, framebuffer, or UV-size implementation fault. Repeated texture is present in exposed parent areas beyond the Snell bezel, and its spacing corresponds to sparse radius-scaled blur fetches.
- Standalone diagnostic `tests/visual/blur-sampling-probe.sh` renders the canonical blur shader without any refraction, Snell, QML, or compositor layers and compares it with an independent CPU bilinear-pass model. Final run: `tests/out/20260907T170548Z/blur-sampling-probe`.
- Radius 2.5, 3, and 5 generate secondary profile lobes in both GPU and CPU results; radius 0 and 1 do not in this fixture. Profile coordinates use half-size final-texture pixels, not logical screen pixels. This reproduces a blur-induced repeated-detail mechanism independently of optical mapping.
- GPU/CPU profile maximum error is at most 1/255 in the diagnostic; equivalence metrics are reported, not used to weaken or replace any existing acceptance tolerance. The fixture uses software GLES and does not establish hardware timing or prove that every production artifact has the same cause.
- Production shaders and accepted material settings remain unchanged. A production-only dense blur while preserving the pinned source-parity path would change the locked render contract and requires explicit user approval before implementation.
- The user explicitly approved the production-only dense blur correction while retaining upstream parity. This supersedes the pending decision above.
- `productionblur.frag` now uses adjacent-texel normalized Gaussian sampling; `ShaderManager` selects it for compositor blur. `gaussianblur.frag` remains unchanged for standalone parity. No material, opacity, centered/Snell, rim, or layout settings changed.
- Test-first dense regression initially failed on the missing production shader. Final Tier 0 passed 14 of 14 tests at `tests/out/20260907T183107Z`; routing and GPU/CPU regression were reconfirmed at `tests/out/20260907T191225Z/14-dense-blur`.
- Full nested suite passed 40 of 40 applicable tests at `tests/out/20260907T190148Z`, with opt-in legacy test 56 skipped. Test 39 now disables Kitty mouse auto-hide after a failed run was proven to differ only in a 169-pixel hardware cursor footprint. Tests 40 and 49 use the short temporary socket runtime without substituting a fake compositor PID.
- The independent CPU oracle passed 230 of 230 checks in 360.955 seconds. The visual analyzer passed. Source parity was refreshed against unchanged upstream blur at run `20260907T191225Z-1424810`; offline verification is current.
- Dense frosting capture: `tests/out/20260907T191810Z/capture-production-review`, including `dense-blur-comparison.png`. Capture checks pass; the terminal raw-panel crop is byte-identical to the lighter-parent baseline. The production source identity is `a956973c9fbfeb7f75b6d60d8e2cc5d69bb41868de63f5d2732342cb92f78919`.
- The isolated Intel hardware blur-cost probe recorded 300 samples per shader, p95 0.110937 ms sparse versus 0.298489 ms dense, with zero disjoint events. This is an increase of 0.187552 ms and approximately 169 percent for the blur-only workload. It is not a complete compositor Gate 5 measurement or a performance pass.
- Independent review found no remaining High or Medium defects in this correction. Full stacked compositor GPU timing, animation acceptance, and user visual approval remain pending. Nothing was committed, packaged for deployment, or activated in the live compositor.
- The user approved the corrected dense-blur appearance in `tests/out/20260907T191810Z/capture-production-review` ("it is great"). Preserve this material: dense production blur, parent radius 2.5, child radius 3, one iteration each, with the approved clear-glass opacity and optics inherited unchanged.
- This approval covers the presented frosting and blur appearance. Complete compositor GPU timing and the remaining animation acceptance checks are still required before packaging or deployment. No live activation or commit was authorized.
- Test-only `gpu-frame-timer.cpp` measures elapsed GPU time from before nested HGTEST `beginRender` through after `CHyprOpenGLImpl::end`. It requires explicit environment opt-in, refuses the live instance signature, validates full-frame damage, and asynchronously collects 300 valid hardware timer queries after 60 warmup frames. It does not substitute CPU or presentation timing.
- `measure-compositor-gpu.sh` compares immutable sparse and approved dense binaries with identical accepted materials. The first ABBA attempt at `tests/out/20260908T165715Z/measure-compositor-gpu` failed the relative limit and exhibited large run-level variance and differing cursors. Preserve that evidence; do not use it to infer a fixed dense-blur cost.
- Controlled repeat: `tests/out/20260908T213422Z/measure-compositor-gpu`. Two predeclared ABBA blocks produced 1200 samples per build with invisible nested cursors, identical same-build screenshots, full damage, and zero disjoint events. Aggregate p95: sparse 3.457864 ms, dense 3.541822 ms (+0.083958 ms, +2.428%). Block 1 passed; block 2 measured +10.6024%, exceeding 10%. The runner therefore reports failure of the repeated-block consistency requirement. Performance acceptance remains unresolved; no limit change or exception was approved.
- Continuous motion review: `tests/out/20260908T223414Z/capture-animation-review`. Approved dense frosting was recorded over wallpaper and generated terminal backgrounds, two cycles each, including panel, menu, power, Wi-Fi password/cancel, and interrupted collapse through an in-memory Wi-Fi backend.
- Lossless RGB H.264 masters contain 2642 packets over 44.151 s and 2646 packets over 44.245 s. Separate lossy WebM previews preserve packet counts and near-identical durations. Native capture timestamps, bounded decode checks, packet-cadence diagnostics, stable semantic endpoints, source/config hashes, and service-isolation checks are recorded. Human motion approval remains pending.
- Earlier FFV1 recording had insufficient capture cadence and was not accepted. Later native-timestamp validation was corrected to measure from recorder process launch, not file readiness. Motion sidecars report requested delays plus IPC latency, never exact frame-to-geometry-serial correspondence.
- The animation runner restores its own cleanup traps after nested startup. Two confirmed capture-owned mock DND subscriber groups left by earlier runs were stopped; the final run explicitly verified its owned Quickshell group stopped and left no capture-owned compositor, recorder, or mock subscriber running. The user's live compositor and configuration were not modified.
- Next decision: review the motion videos and choose whether to optimize further or explicitly accept a performance exception after considering the unresolved repeated-block result. Do not package or deploy while this decision is pending.
- User motion feedback identified a more important defect: the parent sheet reached its expanded shape after the Wi-Fi children. Frame analysis of `20260908T223414Z` found a 29-frame collapsed parent plateau and a three-frame (50-51 ms) late finish across four expansions.
- Test 40 now checks two distinct intermediate semantic snapshots in each menu and power expansion/collapse. Parent bottom, power bottom plus 12, reveal clips, and menu/slider spacing agree within the existing 0.001 convention. These checks passed before and after the QML fix; they verify geometry publication, not rendered-frame synchronization.
- The first shared-height binding change alone did not fix rendering. Removing the 32 ms synthetic damage pulse exposed longer parent stalls. Do not use that failed intermediate candidate (`20260909T115813Z`) as acceptance evidence.
- Selected QML fix: root-owned animated `menuHeight` and `powerHeight` now drive both surfaces; canonical panel height is derived from those live values and theme dimensions rather than child-window layout propagation. The copied parent-height state, 32 ms damage timer, and alpha-zero repaint rectangle were removed. Materials, animation durations, easing, semantic IDs, and fixed carriers remain unchanged.
- Selected motion capture: `tests/out/20260909T122114Z/capture-animation-review`. Its absolute-path QML hash is `f4fdd4f3290ff1446ab8cf540b39c06901a6b28223772d02cf9636ac4656d4de`, matching the current selected QML. All four measured Wi-Fi expansions have zero stale-parent frames and zero late parent completion frames.
- Intermediate cross-window pixel spacing still diverges in some frames. Completion-lag removal is verified, but perfect per-frame synchronization is not claimed. Extra forced-layout handlers and a basic Qt render-loop experiment did not consistently resolve that residual and were not retained.
- Production tests 40 through 49 passed 10 of 10 at `tests/out/20260909T131904Z`. Independent source review found no High or Medium issues in the selected root-owned animation change.
- The animation capture tool now accepts an explicit `--qml-revision SHA256` for candidate QML, checks that revision before and after capture, and records it separately from the accepted archive hash. The default archive, material, renderer, and configuration checks remain strict.
- User review of the synchronization candidate, residual intermediate-frame investigation, and performance acceptance remain pending. No live compositor reload, activation, commit, or package deployment occurred.
- The user approved the corrected expansion timing in `tests/out/20260909T122114Z/capture-animation-review` ("yes it is good"). Preserve the selected root-owned animation implementation and the approved glass material. This resolves the requested human review of the trailing-parent fix; it does not authorize a performance exception, commit, packaging, or live activation. The documented intermediate-frame divergence and unresolved performance consistency remain separate limitations.
- The user subsequently requested packaging and deployment and explicitly chose "Accept Exception And Proceed" for the unresolved repeated-block performance result. This authorizes deployment after packaged tests; it does not change the recorded timing data or test limits. The user also chose "Stop Loading It" for the hand-owned override: preserve `~/.config/hypr/hyprglass.lua` unchanged, but remove its automatic load from managed configuration.

### Phase 10 Evidence

- Package `hyprglass-0.7.0-liquid-glass` uses the unchanged current regions patch (SHA-256 `7fdb1ee156a9100ca3ade43af0dfdf699412f4af9d1f3802e533fba2c4c36f16`) followed by the new `hyprglass-liquid-glass.patch` (`e62149b20597e1aadd78ea4bc6a4c39e3eb6d82fe386b36e0bb32579df53c74a`). Superseded patch files remain on disk, unreferenced. No Git index or commit changes were made.
- Applying both patches with zero fuzz to the exact fixed upstream source reproduces the approved complete `src/`, Makefile, and third-party notice byte-for-byte. The package installs both license notices and restricts supported platforms to x86_64-linux.
- Packaged plugin: `/nix/store/8wljy7mcafffwy40xd55ygp4wi4307jj-hyprglass-0.7.0-liquid-glass/lib/libhyprglass.so`, SHA-256 `d2ced7438dc1267bef09ffa8f57a8ed6eac24929be99e6f7d18655cf141a7199`.
- Final packaged nested tests passed 40 of 40 applicable tests at `tests/out/20260909T145240Z`, with the opt-in legacy test skipped. Managed production settings were then captured with the same package at `tests/out/20260909T150743Z/capture-production-review`; all 327 checks passed and the stacked wallpaper panel crop matches the approved dense-material capture exactly.
- Managed configuration now contains the approved neutral base, parent blur 2.5 and child blur 3, full optical opacity, and approved centered/Snell/rim settings. The hand-owned override file is no longer automatically loaded; its contents were not edited.
- Immutable dirty-worktree archive `/nix/store/5xbqnp06pgb9z95s8qhy8aq32qpbbfj8-source` includes the untracked geometry publisher and new patch without staging files. Full NixOS closure built successfully: `/nix/store/piq165p15sl1pj12n651h912h30g0i2m-nixos-system-odyssey-26.11.20260809.279b4a8`. Do not activate the unrelated stale `dotfiles/result` symlink.
- Live activation is blocked on local administrator authentication: `sudo -n true` returned "a password is required". No privileged activation, live plugin hot-swap, or Quickshell restart was performed by this session. The observed current system is `/nix/store/b7kryqbqxljgq2ardc6d2in28wxbj1bj-nixos-system-odyssey-26.11.20260809.279b4a8`; live Quickshell still reports geometry socket connection failures. The user must authenticate locally before the exact tested closure can be activated and live verification completed.
- The user subsequently activated the tested closure and reported "I switched to this and it looks good". Both `/run/current-system` and `/nix/var/nix/profiles/system` now resolve to `/nix/store/piq165p15sl1pj12n651h912h30g0i2m-nixos-system-odyssey-26.11.20260809.279b4a8`.
- Live verification passed: Hyprglass is listed, `hyprctl configerrors` is empty, the notification assertion returns `ok`, and `quickshell-control-center.service` is active. `geometryConnected` is true; the live geometry listener is present with user ownership and mode 0600. The closed panel published two inactive surfaces, zero shapes, and zero clips in a complete transaction.
- Deployed `ControlCenter.qml` and `GlassGeometryPublisher.qml` match their approved source files byte-for-byte by SHA-256. The healthy live session required no further plugin hot-swap, Quickshell restart, or compositor restart from the assistant. Phase 10 is complete; the recorded performance exception and intermediate-frame limitations remain unchanged. No commit was created.

## Source Pins

Do not use a moving branch as an implementation reference.

### OverShifted Base

Repository:

`https://github.com/OverShifted/LiquidGlass`

Commit:

`3797fa541c1f026c521a75885ee271f03bdf9f0f`

OverEngine submodule commit:

`1a460cade8d0162a0040b871cda2e23ba66c4547`

Important upstream files:

- `assets/shaders/BatchRenderer2D.glsl`
- `assets/shaders/Blur.glsl`
- `src/BlurPass.h`
- `src/LiquidGlass.cpp`
- `src/LiquidGlass.h`

### Kube Convex Bezel

Repository:

`https://github.com/kube/kube.io`

The planning session inspected this commit:

`bd091c537fd502f2d1d4d60817e6f05626508e6b`

Article:

`https://kube.io/blog/liquid-glass-css-svg/`

Important article files:

- `app/data/articles/2025_10_04_liquid_glass_css_svg/graphics/MixedUI.tsx`
- `app/data/articles/2025_10_04_liquid_glass_css_svg/components/Filter.tsx`
- `app/data/articles/2025_10_04_liquid_glass_css_svg/lib/displacementMap.ts`
- `app/data/articles/2025_10_04_liquid_glass_css_svg/lib/specular.ts`
- `app/data/articles/2025_10_04_liquid_glass_css_svg/lib/surfaceEquations.ts`

Do not fetch these files again unless this document omits a required equation or source value.

### Source Licensing

LiquidGlass from OverShifted uses the MIT license at the pinned commit.

Preserve the MIT notice when production code copies OverShifted function bodies or shader expressions.

Add a third-party notice before the copied code enters a release package.

The inspected kube.io repository tree did not expose a root license file.

Independently implement the published kube equations from this document.

Do not copy kube.io source text into Hyprglass without a confirmed license.

### Oracle Authority

The CPU oracle is authoritative for equations, constants, finite ranges, and diagnostic Jacobian values.

The unmodified OverShifted executable is authoritative for base GPU pass order and texture sampling.

Build the pinned executable outside the repository, such as under `/tmp/opencode`.

The kube CPU oracle uses the equations in this document before SVG quantization.

Do not use the kube browser image as a pixel oracle.

Create and independently cross-check CPU oracle fixtures before production shader changes.

Store fixed expected values and their derivation metadata in test data.

Normal tests must cross-check authoritative spot values with the independently transcribed C99 reference in `tests/visual/optics-reference.c`.

Do not claim a human review that did not occur.

Do not let the shader implementation generate or update its expected values.

Record the source commit and all runtime values with each source-oracle capture.

Capture the source oracle twice with the same scene.

Use the repeated-source difference as the driver noise floor.

Use the same `512x512` deterministic background and centered `256x256` parity superellipse.

Disable time-dependent input and use the recorded base values.

Compare absolute RGB channel errors inside the shape bounds and a four-pixel exterior ring.

Flatten all selected pixel-channel errors before the percentile calculation.

`sourceRepeatP95` is the p95 value between the two source captures.

`implementation p95 error` compares one implementation capture with the first source capture.

Calculate RMS across the same flattened pixel-channel samples.

For normalized color channels, use this initial parity limit:

```text
implementation p95 error <= max(2/255, 3 * sourceRepeatP95)
implementation RMS error <= 0.005
```

Keep the physical displacement limits in the optical manifest.

## Reference Images

The Apple-style reference images are here:

`/home/orhun/Documents/control_center_ref_images`

Use images 2 through 4 for single-surface structure.

Use images 5 through 7 for parent and child structure.

The images show broad material bodies and narrow contours.

The images also show separate child controls above a parent sheet.

The images do not contain original backgrounds or material masks.

Do not use them as physical displacement or blur oracles.

## Current Architecture

The current compositor architecture supports the required render order.

Replace the compositor architecture only when a failing test identifies an architectural fault.

### Windows

`CGlassDecoration::renderPass()` captures the current framebuffer.

The window path blurs the captured framebuffer and draws glass below the window content.

Windows already have complete centers and bounds.

Windows do not need the semantic geometry socket.

### Layer Surfaces

The `renderLayer` hook inserts a pre-surface pass and a post-surface pass.

`CGlassLayerSurface::sampleAndRedirect()` captures the background.

The function then redirects the layer into a transparent temporary framebuffer.

`CGlassLayerSurface::compositeAndRestore()` restores the target framebuffer.

The function uses the temporary framebuffer as a mask and content source.

This design keeps text and icons above the glass.

### Glass on Glass

`control_center_backdrop` uses `WlrLayer.Top`.

`control_center` uses `WlrLayer.Overlay`.

The child surface samples the completed parent result.

This compositor order already gives true parent and child glass.

Do not merge these surfaces.

Do not share their background sample framebuffers.

### Current Geometry Paths

The current shader has these paths:

- A whole-quad rounded-box path.
- A declared-region path with complete region bounds.
- An alpha-derived pill path with a JFA distance field.

The declared-region path has a limit of 16 regions.

The current alpha pill path knows the nearest boundary only.

The alpha pill path does not know a component center or complete bounds.

## Cause of the Rejected Result

The current pill lens uses the nearest alpha boundary.

The JFA distance field creates a boundary-following extrusion.

The JFA distance field does not create a component-centered isotropic dome.

Long controls magnify mainly along the normal of each straight edge.

Thin controls reduce the lens near the medial axis.

The nearest-boundary behavior removes broad body depth.

The current tests showed formula execution. They did not show visual quality.

The previous production magnification values were also too small.

Do not tune the current lens again.

## Features to Keep

Keep these capabilities as neutral extensions:

- Tint color and tint strength.
- Brightness and contrast.
- Saturation and vibrancy.
- Adaptive dim and adaptive boost.
- Glass opacity.
- Optional chromatic aberration.
- Dark and light theme overrides.
- Built-in and custom presets.
- Layer alpha masks.
- Declared regions.
- Per-surface blur.
- Per-region blur when one region uses a different blur radius.
- Background fade.
- Live blur cache invalidation.
- Parent and child glass composition.
- Premultiplied-alpha compositing.
- FP16 temporary framebuffers in HDR mode.

Keep the capability, not the old numeric meaning.

Retune all defaults for the new engine.

## Optics to Remove or Replace

Remove or replace these behaviors:

- The current edge-normal mapping.
- The current `lens_distortion` polynomial dome.
- The `pills.lens` broad JFA lens.
- The old normalized meaning of `edge_thickness`.
- The old refraction values that use a 50-pixel scale.
- The old lens tests that encode the rejected mapping.

JFA can remain for alpha coverage and background fade.

Do not use JFA to calculate the centered mapping.

An alpha-only pill can receive material and a narrow local rim.

The alpha-only pill must not receive a fabricated centered mapping.

## Exact OverShifted Base

### Runtime Defaults

Use these values for the parity state:

| Setting | Value |
|---|---:|
| Shape power | `3.0` |
| Curve `a` | `0.7` |
| Curve `b` | `2.3` |
| Curve `c` | `5.2` |
| Curve `d` | `6.9` |
| Refraction power | `1.0` |
| Noise | `0.06` |
| Glow weight | `0.25` |
| Glow bias | `0.0` |
| Glow edge 0 | `0.5` |
| Glow edge 1 | `-0.5` |
| Blur radius | `2.0` |
| Blur iterations | `1` |
| Blur downscale factor | `0.5` |

`LiquidGlass.h` supplies these runtime values.

The shader declarations contain different initial values for some uniforms.

`UploadAllUniforms()` replaces those shader values during startup.

Use the runtime values in this table.

`Refraction power` is the exponent applied to the output of the OverShifted curve `f(distance)`.

`Centered-mapping strength` interpolates between identity and the OverShifted result.

`Snell strength` scales only the convex edge correction.

The article `Refraction Level` is equivalent to `Snell strength` in the article demo only.

### Superellipse Distance

The base shader uses this approximate signed distance:

```glsl
float sdSuperellipse(vec2 p, float n, float r) {
    vec2 pAbs = abs(p);
    float numerator = pow(pAbs.x, n) + pow(pAbs.y, n) - pow(r, n);
    float denX = pow(pAbs.x, 2.0 * n - 2.0);
    float denY = pow(pAbs.y, 2.0 * n - 2.0);
    float denominator = n * sqrt(denX + denY) + 0.00001;
    return numerator / denominator;
}
```

The value is negative inside the shape.

The base shader discards a fragment when the value is positive.

### Refraction Curve

The base shader uses this function:

```text
f(x) = 1 - b * (c * e)^(-d * x - a)
```

The centered mapping is:

```glsl
vec2 p = (localUv - vec2(0.5)) * 2.0;
float distance = -sdSuperellipse(p, shapePower, 1.0);
vec2 sampleP = p * pow(f(distance), refractionPower);
```

`sampleP` is a local point in normalized component space.

Convert `sampleP` to the padded Hyprglass sample texture with this sequence:

```text
shapeSampleUv = shapeCenterUv + sampleP * shapeHalfUv
textureUv = toTexUV(shapeSampleUv)
```

Do not use the carrier center for a semantic child shape.

Use each semantic shape center and half-size.

Apply the public centered-mapping strength with this equation:

```text
centeredSampleP = mix(p, sampleP, centeredMappingStrength)
```

The parity state uses `centeredMappingStrength = 1`.

The exact OverShifted curve intentionally inverts the local mapping derivative in a narrow edge band.

This edge inversion produces negative centered-mapping Jacobian values and is part of the selected source behavior.

Preserve it in both parity and production centered refraction.

Do not smooth, clamp, weaken, or reject the centered mapping only because its Jacobian is negative.

Accept a centered mapping only when its CPU-oracle output is finite, bounded by the material shape, symmetric, and does not cross the component center.

Use the same centered-mapping acceptance rule for parity and production.

Do not add a public or internal parity-bypass boolean.

A parity-bypass boolean is a configuration option or code flag that selects the parity boundary from user configuration or skips the centered-mapping acceptance rule.

The internal boundary-kind enumeration in `src/GlassRenderer.cpp` is not a parity-bypass boolean.

### Production Shape Adapter

The parity state uses the exact OverShifted superellipse as its boundary and distance field.

Production semantic controls use the QML rounded rectangle as their material boundary.

Use the transmitted radius to calculate rounded-rectangle coverage, edge distance, and the edge normal.

Do not discard production pixels with the global OverShifted superellipse boundary.

For a semantic rounded rectangle, calculate normalized inward distance with this equation:

```text
centerDistance = max(-roundedRectangleSdfPx, 0)
normalizedDistance = centerDistance / min(shapeHalfWidthPx, shapeHalfHeightPx)
```

`roundedRectangleSdfPx` is negative inside and zero at the material edge.

The distance uses framebuffer pixels after monitor-scale conversion.

Use `normalizedDistance` as the `x` input to the OverShifted curve.

Use the vector from the shape center to the fragment for the centered sample direction.

This adapter preserves the OverShifted curve and matches the QML material boundary.

Use exponent `2.0` for QML circular corners in protocol version 1.

The configurable OverShifted shape power applies only to the parity superellipse.

Production windows use the rounded-rectangle adapter, their real radius, and exponent `2.0`.

Add separate tests for the parity superellipse and the rounded-rectangle adapter.

### Noise

The base shader uses this random function:

```glsl
float rand(vec2 co) {
    return fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453);
}
```

The base sample adds this noise:

```glsl
vec3 noise = vec3(rand(gl_FragCoord.xy * 1e-3) - 0.5);
color += noise * noiseStrength;
```

Production noise must remain stable when the component moves.

Use component-local pixels and a stable material ID as the production seed.

Keep the screen-coordinate formula only in the parity fixture.

Use 32-bit FNV-1a to hash each UTF-8 material ID on the CPU.

For a semantic shape, use its semantic shape ID as the material ID.

For a declared region, use `region:` followed by its zero-based configuration index.

For a whole-layer fallback, use `layer:` followed by the namespace.

For a window, use `window:` followed by the initial application class.

Use `window:unknown` when the initial application class is empty.

Capture the window material ID once when Hyprglass starts tracking the window.

`materialOriginPx` is the monitor-scaled canonical material origin in framebuffer coordinates.

Use the complete unclipped shape origin.

For declared regions, windows, and whole-layer fallbacks, use the equivalent complete material origin.

Pass the low 24 hash bits to the shader as an exact integer-valued float.

Use this production seed calculation:

```text
localPx = framebufferFragmentPx - materialOriginPx
seed = float(fnv1a32(materialId) & 0x00ffffff)
co.x = localPx.x * 0.001 + seed * 0.000001
co.y = localPx.y * 0.001 + seed * 0.000001618034
noise = rand(co) - 0.5
```

Do not round `localPx`.

The CPU noise oracle must use IEEE 754 single-precision operations for this calculation.

### Angular Glow

The base shader uses this angular value:

```glsl
float glow = sin(atan(localUv.y * 2.0 - 1.0,
                      localUv.x * 2.0 - 1.0) - 0.5);
```

The base shader uses this multiplier:

```glsl
float multiplier = glow * glowWeight
    * smoothstep(glowEdge0, glowEdge1, distance)
    + 1.0 + glowBias;
```

The parity state must use this exact operation.

Phase 5 must add the two bright opposing lobes for production.

### Chromatic Extension

The chromatic extension uses a maximum separation of two framebuffer pixels.

Calculate the offset with this equation:

```text
chromaticOffsetPx = 2 * chromaticAberration
sampleDirection = normalizeOrZero(finalSamplePx - fragmentPx)
redSamplePx = finalSamplePx - sampleDirection * chromaticOffsetPx
greenSamplePx = finalSamplePx
blueSamplePx = finalSamplePx + sampleDirection * chromaticOffsetPx
```

Sample one color channel from each corresponding point.

Check and clamp each chromatic point independently with the production sample-bounds rule.

Use zero direction when the final sample equals the fragment position.

The default chromatic-aberration value is zero.

## Approved Production Blur

The user approved this Phase 9 exception after the sparse scaled kernel reproduced repeated text detail in independent GPU and CPU fixtures.

The compositor loads `productionblur.frag`. The standalone source oracle continues to load the unchanged `gaussianblur.frag` below. Do not claim dense production blur matches the upstream kernel.

Preserve half-size framebuffer ownership, zero-iteration resampling, linear filtering, clamp-to-edge sampling, first-iteration resolution asymmetry, and the existing padding bound. Change only the production kernel.

For each pass, calculate:

```text
inputScale = inputTextureDimensionOnAxis / uploadedResolutionOnAxis
sigma = 2 * framebufferScaledRadius * inputScale
support = 5.176470588235294 * framebufferScaledRadius * inputScale
centerWeight = 1
tapWeight(i) = exp(-0.5 * (i / sigma)^2) * clamp(support - i, 0, 1)
```

Sample both sides at adjacent integer input-texel offsets `i`, stopping before `i >= support`. Normalize by the total weight. The last interior tap fades continuously without sampling beyond the support bound. Return the center sample for zero direction, zero radius, or support at most one input texel.

The loop has a hard limit of 60 texels and a support-dependent early exit. Reject unsupported production requests before framebuffer allocation instead of truncating the kernel.

`tests/tier0/14-dense-blur.sh` tests production routing, independent GPU/CPU profiles, constant preservation, symmetry, and absence of secondary lobes. It also retains the sparse reference and requires its known lobes to remain detectable. Existing parity tolerances are not relaxed.

The dense kernel can cost more GPU time. The isolated blur-cost probe is diagnostic only; complete stacked-frame timing remains required before deployment.

## Exact OverShifted Blur

The base Liquid Glass function does not call its local `blur13()` helper.

The base Liquid Glass function samples a separate preblurred framebuffer.

The blur shader uses seven bilinear texture fetches per axis.

Those fetches represent a 13-tap Gaussian kernel.

Use these exact offsets and weights:

```text
center offset  0.0000000000000000  weight 0.1964825501511404
pair offset    1.4117647058823530  weight 0.2969069646728344 each
pair offset    3.2941176470588234  weight 0.09447039785044732 each
pair offset    5.1764705882352940  weight 0.010381362401148057 each
```

Multiply each offset by the blur radius.

Run one horizontal pass and one vertical pass for one iteration.

The upstream output framebuffer uses half of the input width and height.

The upstream first iteration has a resolution asymmetry.

The blur pass uploads the full input resolution before both first-iteration passes.

The vertical pass samples a half-size intermediate with the full input resolution uniform.

The parity fixture must reproduce the first-iteration resolution asymmetry.

Do not silently fix the asymmetry before the parity test passes.

Production can change the asymmetry only after a separate visual review.

Use `GL_LINEAR` for blur input textures.

Use `GL_CLAMP_TO_EDGE` for blur input textures.

Use standard normalized OpenGL texture coordinates and pixel-center sampling.

Calculate each half-size dimension with `max(1, floor(inputDimension * 0.5))`.

Keep the source framebuffer format for the two blur outputs.

A zero radius still performs half-size linear resampling when one iteration runs.

Use this exact pass chain for `blurIterations`:

1. For zero iterations, draw the raw input directly into the half-size final framebuffer with blur direction `(0,0)`. The shader still executes the weighted fetches at one UV. Do not use the intermediate framebuffer.
2. For iteration zero of a positive iteration count, upload the full raw-input resolution. Draw raw input to the half-size intermediate with direction `(1,0)`. Then draw the intermediate to the half-size final framebuffer with direction `(0,1)` without changing the full-resolution uniform.
3. For each later iteration, upload the half-size final-framebuffer resolution. Draw final to intermediate with direction `(1,0)`. Then draw intermediate to final with direction `(0,1)` without changing that half-size resolution uniform.

The half-size final framebuffer is the glass shader input for every iteration count, including zero.

The GPU source oracle is authoritative for pixel differences caused by texture interpolation.

Use the CPU oracle for weights, support, symmetry, and pass dimensions.

Label stored CPU impulse, step, and pass arrays as model expectations.

Keep the source-GPU interpolation capture explicitly pending until Phase 4.

### Hyprglass Framebuffer Change

The current Hyprglass blur mutates one same-size sample framebuffer.

That design cannot reproduce the exact upstream downscale sequence.

Use these framebuffer roles for the new path:

- The full-size framebuffer for the raw sample.
- The half-size intermediate framebuffer for the horizontal pass.
- The half-size framebuffer for the final blurred sample.

The engine can continue to share the global temporary framebuffer for blur.

Each parent and child layer must own its final blurred framebuffer.

Use normalized UVs so the raw and half-size extents remain identical.

### Framebuffer Roles

| Role | Producer | Consumer | Size | Owner |
|---|---|---|---|---|
| Raw sample | Background blit | Horizontal blur | Shape box plus padding | Window or layer state |
| Horizontal result | Horizontal blur pass | Vertical blur pass | Half raw size | Shared blur state |
| Final blurred sample | Vertical blur pass | Glass shader | Half raw size | Window or layer state |
| Layer content | Original layer render | Final compositor | Monitor framebuffer size | Layer state |
| Target | Hyprland render pass | Display and later layers | Monitor framebuffer size | Hyprland |

Do not use the layer-content framebuffer as a background sample.

## Kube Convex Snell Bezel

The article describes an Apple approximation.

The article does not claim pixel parity with Apple.

The approximation assumes one refraction event and orthogonal incident rays.

The approximation also assumes a flat background plane and no material gap.

Use only the convex-squircle profile in the first implementation.

Do not add concave or lip profiles.

### Convex Surface Function

Use this function for normalized bezel distance `x`:

```text
h(x) = (1 - (1 - x)^4)^(1/4)
```

`x = 0` is the outer material edge.

`x = 1` is the inner end of the bezel.

The kube source calculates its derivative with this sequence:

```text
dx = 0.0001 when x < 1
dx = -0.0001 when x >= 1
y = h(x)
y2 = h(x + dx)
derivative = (y2 - y) / dx
```

Use the same derivative in the CPU oracle.

The first implementation must use this finite-difference derivative in both the CPU oracle and the shader.

Do not substitute an analytic derivative in the first implementation.

### Snell Calculation

The kube source uses `eta = 1 / refractiveIndex`.

The kube source calculates the normal with this sequence:

```text
magnitude = sqrt(derivative^2 + 1)
normal.x = -derivative / magnitude
normal.y = -1 / magnitude
```

The kube source calculates the refracted direction with this sequence:

```text
dot = normal.y
k = 1 - eta^2 * (1 - dot^2)
root = sqrt(k)
refracted.x = -(eta * dot + root) * normal.x
refracted.y = eta - (eta * dot + root) * normal.y
```

The kube source calculates signed displacement with this sequence:

```text
remainingBezelHeight = h(x) * effectiveBezelWidth
remainingHeight = remainingBezelHeight + effectiveThickness
displacement = refracted.x * remainingHeight / refracted.y
```

Reject a Snell parameter set when the Snell calculation produces a nonfinite result.

Use the sign from the source oracle. Do not infer the sign from a diagram.

### Direct Shader Use

The article stores displacement in an 8-bit SVG image.

Do not copy that quantization into Hyprglass.

Calculate the signed displacement directly in the fragment shader.

Use an outward material edge normal in layer coordinates.

Calculate edge distance from the original fragment position.

Apply the Snell correction after the centered mapping.

Use this conceptual sequence:

```text
centeredSamplePx = centered mapping result
rawOffset = snellDisplacement * effectiveSnellStrength
maximumOffset = 0.45 * distanceToCenterAlongInwardNormal
safeOffset = maximumOffset * tanh(rawOffset / max(maximumOffset, 0.001))
snellOffsetPx = -outwardEdgeNormal * safeOffset
finalSamplePx = centeredSamplePx + snellOffsetPx
```

The selected convex source profile produces a nonnegative `snellDisplacement`.

Reject an optical object when its CPU-oracle profile produces a negative displacement at a tested point.

Do not apply `abs()` to a signed source-oracle result.

Layer coordinates use positive X to the right and positive Y downward.

The negative outward normal points into the semantic shape.

This sign matches `-cos * distance` and `-sin * distance` in the kube source.

Reject a statically invalid optical object during configuration parsing.

Do not reject live geometry because a material shape becomes small.

Use effective shape values and the smooth shader cap for live geometry.

Do not apply a positive-Jacobian acceptance rule to the exact centered mapping.

Require the centered mapping to remain finite, bounded, symmetric, and on the fragment side of the component center.

Apply positive-Jacobian safety only to the standalone incremental Snell mapping:

```text
snellOnlySamplePx = fragmentPx + snellOffsetPx
```

This mapping excludes the centered result.

The configuration parser must check fixed numeric ranges.

The transaction validator must check semantic geometry only.

The shader must calculate the effective optical values for each semantic shape, declared region, window, and whole-layer fallback.

The shader must apply a smooth cap before an offset can cross the shape center.

Use this cap for positive inward displacement:

```text
maximumOffset = 0.45 * distanceToCenterAlongInwardNormal
safeOffset = maximumOffset * tanh(rawOffset / max(maximumOffset, 0.001))
```

`rawOffset` is the positive magnitude from the Snell equation after strength scaling.

`distanceToCenterAlongInwardNormal` uses this equation:

```text
inwardNormal = -outwardEdgeNormal
distanceToCenterAlongInwardNormal = max(
    dot(shapeCenterPx - fragmentPx, inwardNormal),
    0
)
```

Phase 1 must implement the production rounded-rectangle adapter in the CPU oracle.

Use the same adapter in centered-safety checks and combined-mapping diagnostics.

The configuration parser must run the centered-safety validator and standalone Snell-prefix validator once for each complete optical object.

The centered validator uses the parsed curve `a`, `b`, `c`, `d`, refraction power, and centered-mapping strength.

The Snell-prefix validator uses the parsed IOR, configured thickness, configured bezel width, and configured Snell strength.

Neither validator substitutes a default, a range endpoint, or a parity value for a parsed value.

Use a `65x65` grid over normalized shape X and Y coordinates.

Use a `0.25` logical-pixel finite-difference step after shape scaling.

Use these absolute minimum dimensions in logical pixels: `0.015625`, `0.0625`, `0.25`, `1`, `4`, `16`, `64`, `256`, and `1024`.

Treat zero minimum dimension as the limiting identity state because protocol shapes must have positive dimensions.

Use aspect ratios `1`, `2`, `4`, `8`, `16`, `32`, and `64` in both wide and tall orientations.

Use radius ratios `0`, `0.1`, `0.25`, and `0.5` times the minimum dimension.

Test the Cartesian product of minimum dimension, aspect orientation, and radius ratio.

Calculate effective values for each geometry before testing its mapping.

In addition to the regular grid, add edge-adaptive probes at straight edges, rounded corners, and both sides of the effective bezel transition.

Include inward depth `0.25` logical pixels and at least 33 valid positions along each tested quarter arc.

Include an exact `9`-degree rounded-corner probe.

The probe set must include the `4096x64` rounded shape point `(2047.5,0)` with the `0.25` logical-pixel finite-difference step.

The child settings at Snell strength `0.04` must reject the `256x64`, radius `6.4`, angle `9` degrees, inward-depth `0.25` counterexample.

Valid Jacobian points are inside the rounded material boundary.

Both finite-difference neighbors on each axis must also be inside that boundary.

Require a standalone Snell Jacobian determinant greater than `0.05` at all valid Jacobian points for the complete strength prefix from `0.0` through the configured strength.

Do not assume that endpoint validity implies prefix validity.

Use deterministic conservative interval subdivision or an equivalent continuous-prefix proof.

Reject the optical object when any strength is unsafe or when conservative interval subdivision cannot certify an interval.

The `64x64`, radius `32`, bezel `48`, thickness `64`, IOR `2` regression must fail.

Its strength-`1` endpoint recovers above `0.05` on that geometry.

Lower strengths in the prefix are unsafe.

Calculate the combined centered-plus-Snell Jacobian as diagnostic data only.

Do not use the combined Jacobian to accept or reject configuration.

The oracle must report a true minimum only when it calculates the value over a stated finite sample set.

Otherwise report the value as `minimum_sampled_determinant` or as a detected `first_failure`.

Do not label a traversal-dependent value as a global minimum.

Cache validator results by the complete parsed optical value.

Precompute and cache geometry topology by all relevant values.

Do not run the numerical grid for each animation frame.

### Article Starting Values

The article music player uses these source settings:

| Shape | Size | Radius | Bezel | Thickness | IOR |
|---|---:|---:|---:|---:|---:|
| Search | `320x42` | `21` | `18` | `100` | `1.3` |
| Player desktop | `640x63` | `31` | `29` | `90` | `1.3` |
| Player mobile | `320x54` | `27` | `29` | `90` | `1.3` |

Use `1.3` as the first IOR candidate.

Do not copy the other values directly into every Hyprglass shape.

Use namespace preset values and the Effective Optical Values equations.

Parent and child namespaces can use different material values.

## Kube Rim and Specular

The article uses a separate specular image.

The image uses a fixed light angle and an absolute dot product.

The absolute value creates two opposing bright lobes.

The source default angle is `pi / 3`.

The source mask is nonzero only in a very narrow edge band.

Use an analytic rim mask instead of a texture.

Keep rim width independent from Snell bezel width.

Define `rimWidthPx` as the complete inward support of the rim.

The kube-equivalent support is `2.0` logical pixels.

Skip the complete rim, saturation, inner-shadow, and specular block when effective rim width is zero.

Use this operation for a fragment inside the material edge when effective rim width is positive:

```text
edgeT = clamp(2 * inwardEdgeDistancePx / effectiveRimWidth, 0, 2)
edgeProfile = sqrt(max(1 - (1 - edgeT)^2, 0))
angular = abs(dot(outwardNormalYUp, lightDirectionYUp))
coefficient = edgeProfile * angular
rimMask = coefficient^2
luminance = dot(bodyColor, vec3(0.2126, 0.7152, 0.0722))
saturatedEdge = mix(vec3(luminance), bodyColor, rimSaturation)
color = mix(bodyColor, saturatedEdge, rimMask * fresnelStrength)
whiteTarget = vec3(coefficient)
color = mix(color, whiteTarget, rimMask * specularStrength)
```

Calculate the configured light direction with this equation:

```text
lightDirectionYUp = vec2(cos(lightAngleRadians), sin(lightAngleRadians))
```

Set `outwardNormalYUp = vec2(outwardNormal.x, -outwardNormal.y)`.

The kube parity angle is `pi / 3` in this Y-up coordinate system.

The production angle starts at `2 * pi / 3`.

The production angle places the strongest lobes at upper-left and lower-right edges.

Apply an optional opposing inner shadow before the white specular operation.

Use this inner-shadow calculation:

```text
shadowAngular = max(-dot(outwardNormalYUp, lightDirectionYUp), 0)
shadowMask = edgeProfile^2 * shadowAngular^2
color *= 1 - shadowMask * innerShadowStrength
```

The article music player uses these initial values:

| Setting | Value |
|---|---:|
| Specular opacity | `0.40` |
| Specular saturation | `6` |
| Refraction level | `1.00` |
| Blur level | `1.0` |
| Glass background opacity | `0.60` |

Use these values as test candidates, not final defaults.

Map article `Glass background opacity` to Hyprglass `glass_opacity` for comparison tests.

Map article `Specular opacity` to `specularStrength`.

Map article `Specular saturation` to `rimSaturation`.

Map article `Blur level` to the article Gaussian standard deviation only.

Do not use article `Blur level` as an OverShifted blur radius.

The final defaults require production visual approval.

### First Production Candidates

Use these settings for the first integrated production capture.

| Setting | Parent | Child |
|---|---:|---:|
| Centered-mapping strength | `0.35` | `1.00` |
| Blur radius | `2.0` | `2.0` |
| Blur iterations | `1` | `1` |
| Noise | `0.03` | `0.04` |
| IOR | `1.3` | `1.3` |
| Configured Snell bezel width | `24 px` | `18 px` |
| Configured glass thickness | `36 px` | `32 px` |
| Snell strength | `0.02` | `0.02` |
| Rim width | `2.0 px` | `2.0 px` |
| Rim saturation | `2.0` | `6.0` |
| Fresnel strength | `0.12` | `0.35` |
| Specular strength | `0.12` | `0.40` |
| Inner-shadow strength | `0.04` | `0.08` |
| Production light angle | `2*pi/3` | `2*pi/3` |

These values are starting candidates only.

The original Snell candidates `0.15` and `0.20` were unsafe under the standalone continuous-prefix validator.

Both candidates now start at `0.02`, which passes the complete regular and edge-adaptive Snell-prefix fixture.

The centered strengths remain `0.35` and `1.00` because their exact edge inversion is intentional source behavior.

Keep the fixed Snell-strength range.

Reject an unsafe complete optical object with the centered-safety and standalone Snell-prefix validators.

### Static Numeric Ranges

Use these initial parser ranges:

| Value | Accepted range |
|---|---|
| Shape power | `1.001` through `6.0` |
| Curve `a` | `0.0` through `5.0` |
| Curve `b` | `0.0` through `6.0` |
| Curve `c` | `0.001` through `6.0` |
| Curve `d` | `0.0` through `10.0` |
| Refraction power | `0.0` through `6.0` |
| Centered-mapping strength | `0.0` through `1.25` |
| Noise | `0.0` through `0.30` |
| Chromatic aberration | `0.0` through `1.0` |
| Glow weight | `-1.0` through `1.0` |
| Glow bias | `-1.0` through `1.0` |
| Glow edge 0 | `-1.0` through `1.0` |
| Glow edge 1 | `-1.0` through `1.0` |
| Blur radius | `0.0` through `10.0` |
| Blur iterations | `0` through `5` |
| IOR | `1.0001` through `2.0` |
| Snell bezel width | `0.0` through `48.0` logical pixels |
| Glass thickness | `0.0` through `128.0` logical pixels |
| Snell strength | `0.0` through `1.0`, followed by object-specific standalone Snell-prefix validation |
| Rim width | `0.0` through `4.0` logical pixels |
| Rim saturation | `0.0` through `10.0` |
| Fresnel strength | `0.0` through `1.0` |
| Specular strength | `0.0` through `1.0` |
| Inner-shadow strength | `0.0` through `1.0` |
| Light angle | `-pi` through `pi` |

The shader derives effective shape values from the configured values.

The production-candidate table lists configured values.

The shader applies the Effective Optical Values equations to each production shape.

### Article Filter Order

The article filter uses this order:

1. Gaussian blur.
2. Displacement image.
3. Displacement map.
4. Saturated displaced copy.
5. Specular image.
6. Saturated-edge clip.
7. Specular alpha reduction.
8. Saturated-edge blend.
9. White-specular blend.

Preserve the separate saturated-edge and white-specular concepts.

Do not require the SVG filter order in the compositor implementation.

## Progressive Blur Exclusion

The music player has top and bottom progressive blur overlays.

Those overlays belong to the scroll-container UI.

The progressive overlays are not part of the floating search or player glass filters.

Do not add progressive blur to the Hyprglass shader.

Add progressive blur in QML only when content scrolls below fixed control-center chrome.

## Locked Render Pipeline

Use this render pipeline for the new engine:

1. Capture the unglassed background.
2. Produce the exact preblurred background.
3. Select the semantic shape for the fragment.
4. Calculate canonical local coordinates.
5. Calculate the selected inward distance field.
6. Calculate the centered mapping.
7. Calculate the convex Snell correction.
8. Calculate the one base sample point or three chromatic sample points.
9. Check the bounds of every required sample point.
10. Sample the preblurred background once, or sample each RGB channel at its chromatic point.
11. Add deterministic local noise.
12. Apply the exact base angular glow.
13. Apply optional material tone and tint.
14. Apply the saturated rim.
15. Apply the optional opposing inner shadow.
16. Apply the white specular highlight.
17. Composite layer content above the glass.

For the parity fixture, return opaque magenta when the base sample point is outside normalized texture bounds.

This behavior matches the OverShifted source.

For production, clamp every required sample point to the center of the nearest valid texel in the captured background.

Do not sample outside the captured background.

The parity fixture selects the exact OverShifted superellipse distance.

Production semantic shapes select the rounded-rectangle distance adapter.

Production windows also select the rounded-rectangle adapter and use the real window radius.

The whole-layer fallback uses the real carrier bounds and configured layer radius.

Each optional extension must have one disabled value.

Use these parity and disabled values:

| Setting | Parity value | Disabled value |
|---|---:|---:|
| Centered-mapping strength | `1.0` | `0.0` |
| Snell strength | `0.0` | `0.0` |
| Material tint alpha | `0.0` | `0.0` |
| Brightness | `1.0` | `1.0` |
| Contrast | `1.0` | `1.0` |
| Saturation | `1.0` | `1.0` |
| Vibrancy | `0.0` | `0.0` |
| Adaptive dim | `0.0` | `0.0` |
| Adaptive boost | `0.0` | `0.0` |
| Chromatic aberration | `0.0` | `0.0` |
| Rim saturation | `1.0` | `1.0` |
| Fresnel strength | `0.0` | `0.0` |
| Specular strength | `0.0` | `0.0` |
| Inner-shadow strength | `0.0` | `0.0` |

The parity state uses centered-mapping strength `1.0`.

The parity state must match the base before production tuning starts.

## Semantic Geometry Scope

The first protocol version must publish semantic shapes for physical glass boundaries only.

Do not publish each hover rectangle as a semantic shape.

Do not publish slider tracks or thumbs as semantic shapes.

Do not publish menu rows as semantic shapes.

Those items remain content inside their containing semantic shape.

This scope matches the reference structure and stays below 16 shapes.

### Required Semantic Shapes

Publish these shapes:

| Stable ID | Namespace | Surface ID | Role | Clip list |
|---|---|---|---|---|
| `cc.backdrop.sheet` | `control_center_backdrop` | `backdrop` | `sheet` | `cc.clip.backdrop.reveal` |
| `cc.tile.wifi` | `control_center` | `controls` | `control` | `cc.clip.controls.reveal` |
| `cc.tile.bluetooth` | `control_center` | `controls` | `control` | `cc.clip.controls.reveal` |
| `cc.tile.usb` | `control_center` | `controls` | `control` | `cc.clip.controls.reveal` |
| `cc.tile.dnd` | `control_center` | `controls` | `control` | `cc.clip.controls.reveal` |
| `cc.menu.frame` | `control_center` | `controls` | `control` | `cc.clip.controls.reveal` |
| `cc.slider.display` | `control_center` | `controls` | `control` | `cc.clip.controls.reveal` |
| `cc.slider.sound` | `control_center` | `controls` | `control` | `cc.clip.controls.reveal` |
| `cc.power.card` | `control_center` | `controls` | `control` | `cc.clip.controls.reveal` |

The menu shape is absent when its canonical height is zero.

The power shape always exists while the panel exists.

`Canonical` means complete bounds for the current animation frame.

A real material resize changes canonical bounds and the canonical center.

An ancestor reveal clip does not change canonical bounds or the canonical center.

## Production Geometry

Both panel surfaces use a `416x956` carrier.

The visible panel starts at surface coordinate `(8,8)`.

The content column starts at surface coordinate `(20,20)`.

Use live QML item values in production.

Use the formulas below only for tests and diagnostics.

### Constants

```text
shadow extent = 8
outer padding = 12
content width = 376
spacing = 8
tile width = 184
tile height = 64
control radius = 18
sheet radius = 24
slider height = 82
```

### Dynamic Values

```text
M = live menu clip height
Q = 1 when M > 0, otherwise 0
delta = Q * (M + 8)
P_h = live power clip height
H = 400 + delta + (P_h - 52)
P = panel progress
revealHeight = (H + 16) * P
```

Qt removes zero-height column children from spacing calculations.

The zero-height spacing behavior creates the `Q` term in the test formula.

Do not reconstruct this formula inside Hyprglass.

### Shape Bounds

| ID | Canonical bounds | Radius |
|---|---|---:|
| `cc.backdrop.sheet` | `(8, 8, 400, H)` | `24` |
| `cc.tile.wifi` | `(20, 20, 184, 64)` | `18` |
| `cc.tile.bluetooth` | `(212, 20, 184, 64)` | `18` |
| `cc.tile.usb` | `(20, 92, 184, 64)` | `18` |
| `cc.tile.dnd` | `(212, 92, 184, 64)` | `18` |
| `cc.menu.frame` | `(20, 164, 376, M)` | `min(18, M/2)` |
| `cc.slider.display` | `(20, 164 + delta, 376, 82)` | `18` |
| `cc.slider.sound` | `(20, 254 + delta, 376, 82)` | `18` |
| `cc.power.card` | `(20, 344 + delta, 376, P_h)` | `min(18, P_h/2)` |

### Effective Optical Values

Dynamic shapes can become smaller than their configured optical widths.

Do not reject a valid geometry snapshot because a live shape is small.

For each semantic shape, declared region, window, and whole-layer fallback, calculate these effective values:

```text
minDimension = min(width, height)
aspectRatio = max(width, height) / minDimension
effectiveBezelWidth = min(configuredBezelWidth, radius, 0.45 * minDimension)
effectiveThickness = min(configuredThickness, 1.5 * minDimension)
effectiveRimWidth = min(configuredRimWidth, 0.25 * minDimension)
aspectFactor = 1 - smoothstep(48, 64, aspectRatio)

if configuredBezelWidth == 0 or effectiveBezelWidth == 0:
    sizeFactor = 0
    effectiveSnellStrength = 0
else:
    sizeFactor = smoothstep(0, 2 * configuredBezelWidth, minDimension)
    effectiveSnellStrength = configuredSnellStrength * sizeFactor * aspectFactor
```

When `configuredBezelWidth` or `effectiveBezelWidth` is zero, set `effectiveBezelWidth`, `sizeFactor`, and `effectiveSnellStrength` to zero without calling `smoothstep`.

Skip the complete Snell block when `configuredSnellStrength`, `effectiveSnellStrength`, or `effectiveBezelWidth` is zero.

When `effectiveRimWidth` is zero, skip the complete rim, saturation, inner-shadow, and specular block.

All dimensions in these equations use logical pixels.

The shader divides framebuffer-space shape dimensions and radius by monitor scale before it calculates these effective values.

The shader then multiplies effective bezel width, thickness, and rim width by monitor scale before it uses framebuffer-space edge distances or sample points.

The shader does not scale Snell strength, size factor, or aspect factor because they are dimensionless.

The menu Snell effect therefore starts at zero and increases continuously.

The size factor prevents an optical jump during menu creation and removal.

The aspect factor fades Snell displacement to zero before geometry leaves the validated aspect domain.

### Required Glass Clips

Publish these ancestor reveal clips separately:

| Clip ID | Namespace | Bounds |
|---|---|---|
| `cc.clip.backdrop.reveal` | `control_center_backdrop` | `(0,0,416,revealHeight)` |
| `cc.clip.controls.reveal` | `control_center` | `(0,0,416,revealHeight)` |

Assign `cc.clip.backdrop.reveal` to the sheet.

Assign `cc.clip.controls.reveal` to all child controls.

The menu and power bounds are live material bounds.

Their moving bottom edges are material edges, not clip edges.

A clip can hide part of a canonical shape.

A clip must not move the canonical center.

A clip edge must not create a rim or Snell bezel.

## Geometry Socket

Use a Unix stream socket.

The plugin owns the server.

Quickshell owns one client connection.

Use the main event loop of the compositor for all socket work.

Do not add a worker thread.

Set the listener and all client descriptors to nonblocking mode.

Use bounded buffers for partial records.

Never wait for a client inside an event-loop callback.

### Socket Path

Derive the path from these environment values:

- `XDG_RUNTIME_DIR`
- `HYPRLAND_INSTANCE_SIGNATURE`

Use this path form:

```text
$XDG_RUNTIME_DIR/hyprglass/$HYPRLAND_INSTANCE_SIGNATURE.sock
```

Use the same path with `.lock` appended for the server lock.

Create the directory with mode `0700`.

Create the socket with mode `0600`.

Check `SO_PEERCRED` and require the same user ID.

Disable only the geometry server when an environment value is absent.

Continue window and whole-surface glass rendering without semantic geometry.

Send one plugin notification for the geometry-server failure.

Use this server lifecycle:

1. Create and check the runtime directory. Open the lock file. Acquire an exclusive nonblocking `flock`.
2. When the lock is unavailable, do not remove a socket path. Return an error. The plugin caller sends one notification.
3. When an existing path is a Unix socket, try one nonblocking client connection.
4. Remove the path only after `ECONNREFUSED` and a matching device and inode check. Keep it for all other results.
5. Bind and secure the listener while the plugin holds the lock.
6. Hold the lock until the server object is destroyed. A runtime listener failure does not release the lock.
7. During server teardown, close the listener and client. Remove the matching socket path that this process created. Close the lock descriptor.

Server teardown also runs during failed startup.

Accept one client at a time.

Reject a second client while the first client remains connected.

### Protocol Format

Use a bounded tab-separated text protocol.

Do not add a JSON dependency for protocol version 1.

Use one record per line.

Use these records:

```text
BEGIN\t1\t<epoch>\t<serial>\t<surface-count>\t<shape-count>\t<clip-count>
SURFACE\t<namespace>\t<surface-id>\t<mapping-generation>\t<active>
CLIP\t<namespace>\t<surface-id>\t<mapping-generation>\t<clip-id>\t<x>\t<y>\t<w>\t<h>
SHAPE\t<namespace>\t<surface-id>\t<mapping-generation>\t<shape-id>\t<role>\t<x>\t<y>\t<w>\t<h>\t<radius>\t<clip-list>
COMMIT\t<serial>
```

Allow these characters in IDs:

```text
A-Z a-z 0-9 . _ : -
```

Reserve the complete token `-` as a sentinel.

Reject `-` as an ID.

Use these `role` values:

- `sheet`
- `control`

Use `1` for an active mapped surface.

Use `0` for an inactive surface.

Use `backdrop` as the parent `surface-id`.

Use `controls` as the child `surface-id`.

Increase `mapping-generation` when `panelMapped` changes from false to true.

Use a comma-separated list of clip IDs for `clip-list`.

Use `-` when a semantic shape has no clip.

The `SHAPE` `clip-list` field is the only version 1 field that accepts the `-` sentinel.

Protocol version 1 assigns one ancestor reveal clip to each production shape.

Reject a version 1 `clip-list` that contains a comma or more than one clip ID.

A later protocol version can permit more clips.

Use finite decimal numbers for all geometry.

Do not round animation values before transmission.

All geometry uses layer-local logical pixels.

The coordinate origin is the top-left corner of the carrier.

Positive X points right. Positive Y points down.

The plugin multiplies logical geometry by the monitor scale.

The plugin preserves fractional values until rasterization.

Protocol version 1 supports only normal output transforms.

`Normal` means `WL_OUTPUT_TRANSFORM_NORMAL`.

For another transform, ignore semantic shapes for that layer.

Render one rounded-rectangle shape that matches the complete layer bounds.

Use the new centered, Snell, rim, and material pipeline for that fallback shape.

### Transaction Rules

Stage all records between `BEGIN` and `COMMIT`.

Require the `COMMIT` serial to equal the serial in its corresponding `BEGIN` record.

Commit the snapshot only when all records are valid.

Keep the old snapshot when validation fails.

Require the declared record counts to match.

Require globally unique surface IDs, shape IDs, and clip IDs inside one transaction.

Require an increasing serial for each epoch.

Use unsigned 64-bit decimal integers for epoch, serial, and mapping generation.

Reject an integer that does not fit in 64 bits.

Reject nonfinite values.

Parse geometry as `double` values.

Reject a value that becomes nonfinite after conversion to `float`.

Require a positive semantic-shape width and height.

Allow a clip width or height of zero.

Require a nonnegative clip width and height.

Require `0 <= radius <= min(width,height)/2`.

Require all clip references to exist.

Require each record `mapping-generation` to match its `SURFACE` record.

Accept an active surface record before its Wayland layer maps.

Keep that record pending until exactly one matching namespace maps.

Bind pending geometry when the matching layer maps.

Disable semantic geometry for a namespace when two matching layers map.

When the plugin disables semantic geometry for this reason, use declared regions when they exist.

Use the complete layer fallback when no declared region exists.

Resume the latest valid semantic snapshot automatically when exactly one matching layer remains.

Do not reject the complete transaction only because a layer has not mapped yet.

Reject more than 16 glass shapes in protocol version 1.

Reject more than 16 clips in protocol version 1.

Reject more than four surfaces in protocol version 1.

Reject a transaction larger than 64 KiB.

Reject an individual record larger than 8 KiB.

Do not truncate a transaction.

Clear the connection snapshot after a client disconnects.

Damage the previous shape bounds after a clear.

Damage the union of old and new shape bounds after a committed replacement.

When a clip changes, damage every shape that references the old or new clip.

Expand logical damage by `SAMPLE_PADDING_PX / monitorScale`.

### QML Publication Rules

Create a small publisher component beside `ControlCenter.qml`.

Use `Quickshell.Io.Socket` as the client.

Send a full snapshot after each connection.

Use one process-lifetime epoch.

Calculate the epoch once with this QML-safe integer equation:

```text
epoch = Date.now() * 1024 + floor(Math.random() * 1024)
```

The epoch value remains below the exact-integer limit of JavaScript numbers.

Increase the serial for each snapshot.

Track one mapping generation for the panel.

Reset serial and mapping generation only when the process epoch changes.

Coalesce property changes once per QML event-loop cycle.

Send one transaction for both namespaces.

Send live item coordinates after QML layout completes.

Send a new transaction during each animation frame.

Send inactive `SURFACE` records when `panelMapped` becomes false.

Send active `SURFACE` records before the first mapped frame.

Send zero shapes and zero clips while both surfaces are inactive.

An active collapsed panel sends two surfaces, eight shapes, and two clips.

An active panel with a positive menu height sends nine shapes and two clips.

Use these active surface records:

```text
SURFACE\tcontrol_center_backdrop\tbackdrop\t<generation>\t1
SURFACE\tcontrol_center\tcontrols\t<generation>\t1
```

Do not derive geometry from the alpha mask.

## Typed Configuration Model

Do not add one primitive field for each internal equation without a type boundary.

Create typed structures for the new optical concepts.

Use structures equivalent to these structures:

```cpp
struct SRefractionCurve {
    float a;
    float b;
    float c;
    float d;
    float power;
};

struct SConvexBezel {
    float widthPx;
    float thicknessPx;
    float refractiveIndex;
    float strength;
};

struct SAngularGlow {
    float weight;
    float bias;
    float edge0;
    float edge1;
};

struct SRimMaterial {
    float widthPx;
    float saturation;
    float fresnelStrength;
    float specularStrength;
    float innerShadowStrength;
    float angleRadians;
};
```

Use constructors or parsers that guarantee valid ranges.

Do not let an invalid state reach the render path.

### Proposed Lua Syntax

Extend the existing two-argument `hyprglass.preset()` table form.

Use this shape for the parent preset:

```lua
hyprglass.preset("control_center_parent", {
  refraction_strength = 0.35,
  blur_strength = 2.0,
  blur_iterations = 1,
  noise_strength = 0.03,
  shape_power = 3.0,
  refraction_curve = {
    a = 0.7,
    b = 2.3,
    c = 5.2,
    d = 6.9,
    power = 1.0,
  },
  glow = {
    weight = 0.25,
    bias = 0.0,
    edge0 = 0.5,
    edge1 = -0.5,
  },
  snell = {
    bezel_width = 24.0,
    glass_thickness = 36.0,
    refractive_index = 1.3,
    strength = 0.02,
  },
  rim = {
    width = 2.0,
    saturation = 2.0,
    fresnel_strength = 0.12,
    specular_strength = 0.12,
    inner_shadow_strength = 0.04,
    angle = 2.0943951024,
  },
})
```

Use this shape for the child preset:

```lua
hyprglass.preset("control_center_child", {
  refraction_strength = 1.0,
  blur_strength = 2.0,
  blur_iterations = 1,
  noise_strength = 0.04,
  shape_power = 3.0,
  refraction_curve = {
    a = 0.7,
    b = 2.3,
    c = 5.2,
    d = 6.9,
    power = 1.0,
  },
  glow = {
    weight = 0.25,
    bias = 0.0,
    edge0 = 0.5,
    edge1 = -0.5,
  },
  snell = {
    bezel_width = 18.0,
    glass_thickness = 32.0,
    refractive_index = 1.3,
    strength = 0.02,
  },
  rim = {
    width = 2.0,
    saturation = 6.0,
    fresnel_strength = 0.35,
    specular_strength = 0.40,
    inner_shadow_strength = 0.08,
    angle = 2.0943951024,
  },
})
```

Parse each nested object as one complete value.

Each nested object is optional.

When `refraction_curve` is present, require `a`, `b`, `c`, `d`, and `power`.

When `glow` is present, require `weight`, `bias`, `edge0`, and `edge1`.

When `snell` is present, require `bezel_width`, `glass_thickness`, `refractive_index`, and `strength`.

When `rim` is present, require `width`, `saturation`, `fresnel_strength`, `specular_strength`, `inner_shadow_strength`, and `angle`.

Reject a present nested object when a required field is missing.

Do not fill a missing nested field from defaults or an inherited preset.

Reject the complete nested object when one required field is invalid.

Do not merge a partly valid nested object into an earlier object.

Reject the complete `hyprglass.preset()` call when one nested object is invalid.

Preserve the previously committed preset after that rejection.

Send one configuration notification that names the preset and invalid field.

When a preset contains `rim`, use all values from the nested object.

When a preset omits `rim`, map existing flat Fresnel and specular fields into `SRimMaterial`.

For that legacy mapping, use rim width `2.0`, saturation `1.0`, inner-shadow strength `0.0`, and angle `2*pi/3`.

Use the flat Fresnel value as `fresnelStrength` and the flat specular value as `specularStrength`.

Do not combine nested and flat rim values in one preset layer.

Reject a `hyprglass.preset()` call when the same Lua table contains `rim` and either flat rim field.

A complete nested `rim` object in a later preset layer replaces the rim value inherited from an earlier layer.

When a preset omits `snell`, map the flat `edge_thickness` field to the Snell bezel width in logical pixels.

The flat field sets only the bezel width. The base optical configuration supplies glass thickness, refractive index, and Snell strength.

Reject a `hyprglass.preset()` call when the same Lua table contains `snell` and `edge_thickness`.

A complete nested `snell` object in a later preset layer replaces the Snell values inherited from an earlier layer.

A later nested `snell` object conflicts with an inherited flat `edge_thickness` value.

### Public Capability Mapping

Preserve these public capabilities:

| Capability | New meaning |
|---|---|
| Refraction strength | Identity-to-centered-mapping interpolation. |
| Blur strength | Logical-pixel radius for the exact kernel. |
| Blur iterations | Count for the exact separable pass. |
| Fresnel strength | Colored rim energy. |
| Specular strength | White rim energy. |
| `edge_thickness` | Snell bezel width in logical pixels. |
| Glass opacity | Final glass alpha. |
| Chromatic aberration | Optional bounded sample separation. |

Do not preserve obsolete numeric meanings.

Use `centeredMappingStrength` for the internal refraction-strength field.

Use `blurRadius` for the internal blur-strength field.

Multiply `blurRadius` by monitor scale before the blur pass.

Use `snellStrength` only for the convex Snell correction.

Remove `lens_distortion` from new presets and documentation.

Remove `pills.lens` from new layer configuration.

Retune all built-in presets after parity tests pass.

## Shape Selection

Use semantic shapes before declared Lua regions.

Use declared regions when no semantic snapshot exists.

Use the whole layer or window when neither source exists.

Use alpha masks only for coverage and content composition.

Protocol version 1 requires nonoverlapping semantic shapes inside one surface.

The protocol `role` is validation and diagnostic metadata only in version 1.

It does not select a preset or change shader behavior.

An active semantic shape is a transmitted shape whose referenced `SURFACE` record has `active` set to `1`.

Reject a transaction when two active semantic shapes overlap inside one surface.

Do not claim same-surface nested glass support in version 1.

Cross-surface parent and child composition remains fully supported.

### GPU Shape Data

Pack semantic data into a small number of uniform arrays.

Use one `vec4` for center and half-size.

Use one `vec4` for radius, numeric ID seed, clip index, and a reserved zero value.

Use one `vec4` for each clip rectangle.

Upload one shape count and one clip count.

Do not upload semantic ID strings to the shader.

Check clip intersection after shape selection and before optical sampling.

## Material and Composition Rules

Keep background refraction below QML content.

Do not refract text, icons, or other layer content.

Use the existing temporary layer framebuffer as the content source.

Use the existing premultiplied-alpha over operation.

Use this operation for layer content:

```text
outputAlpha = surfaceAlpha + glassAlpha * (1 - surfaceAlpha)
outputRgbPremultiplied = surfaceRgbPremultiplied
    + glassRgbPremultiplied * (1 - surfaceAlpha)
```

Keep parent and child materials independent by namespace.

The child sample must include the completed parent result.

Semantic geometry changes must invalidate the correct damage regions.

Geometry changes do not always require a new background blur.

Shape movement requires new background sampling when the sampled scene area changes.

An opacity-only content change can reuse a valid background sample.

Any parent geometry, material, opacity, or content change changes the child background.

Increment the monitor scene generation before the child samples after such a parent change.

Keep `live_blur` enabled for the production child until cross-surface invalidation tests pass.

After those tests pass, disable `live_blur` only when generation invalidation gives identical captures.

Use a controlled static fixture with deterministic noise disabled.

Compare cached and `live_blur` captures after separate parent geometry, material, opacity, and content changes.

Require byte-for-byte equality inside the child shape and the exposed parent area.

## Sample Padding

The current fixed sample padding is 60 framebuffer pixels.

Define `SAMPLE_PADDING_PX` as `60` framebuffer pixels.

The convex profile samples inward for the selected first profile.

The exact blur support is much smaller than 60 pixels at base settings.

Still calculate the required support for each accepted parameter set.

Use this conservative support equation:

```text
scaledBlurRadiusPx = blurRadiusLogical * monitorScale
kernelSupportPx = 5.176470588235294 * scaledBlurRadiusPx
    * max(0, 2 * blurIterations - 1)
requiredPaddingPx = ceil(kernelSupportPx + chromaticOffsetPx + 2)
```

The selected convex mappings add zero outward support.

The factor `2 * blurIterations - 1` accounts for later half-size iterations.

When `requiredPaddingPx` exceeds `SAMPLE_PADDING_PX` on a monitor, keep the stored preset and disable glass for the affected window or layer namespace on that monitor.

Render normal surface content and send one notification for each affected material, monitor, and preset generation.

Do not sample an undefined or black border.

Do not add dynamic padding in the first implementation.

## Performance Rules

Do not add a displacement-map texture.

Do not add a specular-map texture.

Do not read pixels from the GPU.

Do not rebuild a CPU map during geometry animation.

Use analytic shader calculations for Snell and rim operations.

Use stable uniform arrays with capacity for 16 shapes.

Upload the actual active count.

The control center uploads eight shapes with a collapsed menu and nine with an expanded menu.

Keep the current 16-shape shader limit for protocol version 1.

Reject shape lists that exceed 16 shapes. Do not truncate a shape list.

Query fragment uniform limits during shader initialization.

Disable glass for the affected semantic namespace when fragment uniforms are insufficient.

Render the QML surface content without glass after this failure.

Send one notification for each affected namespace and shader generation.

Use a cheap rectangle check before each superellipse calculation.

Disable chromatic aberration by default for the new engine.

Do not multiply the full blur cost by three color channels.

## Implementation Phases

Complete these phases in order.

The first line of `src/Shaders.hpp` labels the file as auto-generated.

The repository contains no shader generator or separate canonical shader files.

The build reads `src/Shaders.hpp` directly.

Treat `src/Shaders.hpp` as the current canonical source.

Remove or correct the stale generated-file warning during the first shader phase.

### Phase 0: Protect Existing Work

Read only:

- `git status --short --branch`
- Diffs for files in the next phase.

Tasks:

1. Record the current branch and status in the Phase Progress evidence cell.
2. Do not stage or modify unrelated files.
3. Do not regenerate `/home/orhun/Documents/dotfiles/pkgs/hyprglass-regions.patch`.

Exit condition:

The engineer knows which existing changes overlap the next phase.

### Phase 1: Add Mathematical Oracles

Read only:

- `tests/visual/analyze-optics.sh`
- `tests/visual/optics-manifest.json`
- `tests/visual/self-test.sh`
- `tests/tier0/02-shaders.sh`

Tasks:

1. Add a CPU oracle for the centered superellipse mapping and production rounded-rectangle adapter.
2. Add a CPU oracle for the convex Snell profile.
3. Add a CPU oracle for the dual-lobe rim.
4. Add generated tests for finite outputs and symmetry.
5. Add centered finite, bounded, symmetry, and no-center-crossing tests that preserve the exact edge inversion.
6. Add exact blur impulse and step tests.
7. Add standalone Snell-prefix Jacobian tests and combined-mapping Jacobian diagnostics.
8. Add the regular `65x65` grid, edge-adaptive probes, and the required missed-edge and nonmonotonic-recovery regressions.
9. Add object-specific validator fixtures for both candidates, each individual fixed-range endpoint against the other default values, and known invalid objects.
10. Cross-check authoritative spots with the independent C99 reference implementation.

Required oracle states:

- Centered mapping only.
- Snell only.
- Centered mapping plus Snell.
- Rim only.
- Identity settings.

For the CPU identity state, use these values:

| Setting | Identity value |
|---|---:|
| Centered-mapping strength | `0.0` |
| Snell strength | `0.0` |
| Chromatic aberration | `0.0` |
| Noise | `0.0` |
| Glow weight | `0.0` |
| Glow bias | `0.0` |
| Tint alpha | `0.0` |
| Brightness | `1.0` |
| Contrast | `1.0` |
| Saturation | `1.0` |
| Vibrancy | `0.0` |
| Adaptive dim | `0.0` |
| Adaptive boost | `0.0` |
| Fresnel strength | `0.0` |
| Specular strength | `0.0` |
| Inner-shadow strength | `0.0` |

The CPU identity state returns the fragment sample point and does not invoke blur.

The Phase 4 parity state is different.

It uses centered-mapping strength `1.0`, blur radius `2.0`, one blur iteration, parity noise `0.06`, and the base angular glow values.

It keeps only the non-base material extensions at identity.

Exit condition:

All CPU oracle self-tests pass with independently cross-checked expected fixtures.

The new production differential tests can remain pending until Phase 4 provides GPU captures.

### Phase 2: Add Typed Configuration

Read only:

- `src/PluginConfig.hpp`
- Relevant sections of `src/PluginConfig.cpp`
- `src/BuiltInPresets.hpp`
- `tests/nested/11-config-matrix.sh`
- `tests/tier0/03-lua-sanity.sh`

Tasks:

1. Add typed base-curve settings.
2. Add typed convex-bezel settings.
3. Add typed rim settings.
4. `lens_distortion` has no use in `src`. Tests keep it only as a removed-option rejection regression.
5. `pills.lens` has no use in `src`. Tests keep it only as a parser-removal regression.
6. Reject invalid complete objects atomically.
7. Add replacement and invalid-input tests.
8. Run the Phase 1 centered-safety and standalone Snell-prefix validators before constructing a valid optical object.

9. Keep the combined centered-plus-Snell Jacobian as diagnostics only.

10. Do not add a parity-bypass boolean.

Exit condition:

Configuration tests pass without a shader change.

### Phase 3: Port the Exact Blur

Read only:

- `src/GlassRenderer.hpp`
- `src/GlassRenderer.cpp`
- `src/ShaderManager.hpp`
- `src/ShaderManager.cpp`
- Blur ownership in `src/GlassDecoration.*`
- Blur ownership in `src/GlassLayerSurface.*`
- `src/Shaders.hpp` blur shader section
- `tests/nested/quickshell-optics/shell.qml`
- Relevant capture helpers in `tests/lib.sh`

Tasks:

1. Add the exact 13-tap shader weights.
2. Add full-size raw sample ownership.
3. Add half-size intermediate ownership.
4. Add half-size final sample ownership.
5. Reproduce the first-iteration resolution behavior.
6. Preserve framebuffer and viewport restoration.
7. Preserve layer blur caching.
8. Add impulse and transition tests.

Exit condition:

CPU blur tests and dedicated nested blur captures pass.

### Phase 4: Port the Centered Mapping

Read only:

- `src/Shaders.hpp` glass shader section
- `src/GlassRenderer.cpp` uniform upload section
- `src/ShaderManager.*` glass uniform sections
- `tests/tier0/02-shaders.sh`
- New Phase 1 oracle tests
- `tests/nested/quickshell-optics/shell.qml`
- `tests/nested/54-green-optics-mapping.sh`

Tasks:

1. Add the exact base superellipse function.
2. Add the exact base refraction curve.
3. Add shape-local centered coordinates.
4. Add the production rounded-rectangle distance adapter.
5. Use the real rounded window boundary in production.
6. Add the exact parity noise path.
7. Add the exact parity angular glow path.
8. Keep material extensions at identity for parity tests.
9. Remove the rejected mapping.
10. Add a parity capture that disables all non-base extensions and keeps centered-mapping strength at `1.0`.
11. Compare the parity capture with the CPU and source oracles.
12. Add the required OverShifted MIT notice for copied implementation text.

Exit condition:

The centered mapping in the parity state matches the CPU oracle.

### Phase 5: Add Snell Bezel and Rim

Read only:

- New centered mapping in `src/Shaders.hpp`
- New typed settings in `src/PluginConfig.*`
- New Phase 1 Snell and rim oracles

Tasks:

1. Add rounded-rectangle edge distance and normal calculations.
2. Add the convex surface function.
3. Add the Snell direction calculation.
4. Add the signed edge correction.
5. Add the narrow independent rim mask.
6. Add rim saturation.
7. Add the dual-lobe white specular.
8. Add the opposing inner shadow.
9. Add finite centered guards and standalone Snell-prefix Jacobian guards.

Exit condition:

The Snell and rim tests pass while tests use the centered mapping.

### Phase 6: Add the Geometry Server

Read only:

- `src/main.cpp` plugin lifecycle sections
- `src/Globals.hpp`
- `src/GlassLayerSurface.*` damage and lookup sections
- `Makefile`

Expected new files:

- `src/SemanticGeometry.hpp`
- `src/SemanticGeometry.cpp`
- `src/GeometrySocket.hpp`
- `src/GeometrySocket.cpp`

Tasks:

1. Implement typed immutable snapshots.
2. Implement the bounded protocol parser.
3. Implement the Unix server lifecycle.
4. Integrate the server with the compositor event loop.
5. Validate peer credentials.
6. Commit transactions atomically.
7. Damage old and new bounds.
8. Clear snapshots during unload.
9. Add parser tests without a compositor.

Exit condition:

Protocol tests show atomic replacement and safe disconnect behavior.

### Phase 7: Publish Quickshell Geometry

Read only:

- Relevant geometry in `/home/orhun/Documents/dotfiles/.config/quickshell/ControlCenter.qml`
- `/home/orhun/Documents/dotfiles/.config/quickshell/Theme.qml`
- Current Quickshell production tests 40 through 48

Suggested new file:

`/home/orhun/Documents/dotfiles/.config/quickshell/GlassGeometryPublisher.qml`

Tasks:

1. Connect to the plugin socket.
2. Publish eight semantic shapes when the menu is absent.
3. Publish nine semantic shapes when the menu height is positive.
4. Publish the two required reveal clips.
5. Use live item geometry.
6. Coalesce each update cycle.
7. Send both namespaces in one transaction.
8. Resend after a reconnect.
9. Preserve all current QML interactions.

Exit condition:

Production service tests pass with the publisher active.

### Phase 8: Integrate Semantic Shapes

Read only:

- `src/GlassLayerSurface.cpp` composite section
- `src/GlassRenderer.*` shape upload section
- `src/Shaders.hpp` shape selection section
- `tests/nested/49-quickshell-glass-on-glass.sh`
- `tests/nested/54-green-optics-mapping.sh`
- `tests/nested/quickshell-optics/shell.qml`
- `/home/orhun/Documents/dotfiles/modules/home/linux/_hyprland/hyprland.nix`
- `/home/orhun/.config/hypr/hyprglass.lua` only for final production checking

Tasks:

1. Select semantic shapes by namespace, surface ID, and mapping generation.
2. Upload complete canonical geometry.
3. Apply clips after shape calculations.
4. Keep centers fixed when only an ancestor reveal clip changes.
5. Preserve the parent and child render order.
6. Remove the JFA lens from production control-center settings.
7. Add stale-geometry and reconnect tests.
8. Replace the production `edge_thickness` values `0.002` and `0.0025` in `hyprland.nix` before the first production capture. Map each value to its namespace. Use the configured Snell bezel width for that namespace from First Production Candidates.

Do not modify the hand-owned runtime override during nested development.

Exit condition:

The control center keeps stable centered optics through all animations.

### Phase 9: Tune and Accept

The user approved expanding this phase to update isolated capture tooling and read its build and test helpers. Use `tests/visual/capture-production-review.sh` to capture the production presets without modifying the live compositor or hand-owned configuration. Do not treat unsynchronized animation probes as frame-accurate evidence.

Read only:

- New production captures
- `/home/orhun/Documents/control_center_ref_images/`
- Material reports from `tests/visual/`
- `/home/orhun/Documents/dotfiles/modules/home/linux/_hyprland/hyprland.nix`

Tasks:

1. Tune the parent material first.
2. Tune the child centered mapping second.
3. Tune Snell strength third.
4. Tune inner shadow and rim saturation fourth.
5. Tune white specular fifth.
6. Tune opacity last.
7. Capture normal wallpaper and terminal backgrounds.
8. Request explicit user approval.

Exit condition:

The user approves the production appearance.

### Phase 10: Package and Deploy

Read only:

- `/home/orhun/Documents/dotfiles/pkgs/hyprglass.nix`
- Current patch files in that directory
- The final source diff

Current patch order:

1. `hyprglass-regions.patch`
2. `hyprglass-pill-corners.patch`
3. `hyprglass-background-field.patch`
4. `hyprglass-pill-optics.patch`

Tasks:

1. Restrict package metadata to `x86_64-linux` while required Hyprland function hooks remain x86-64-only.
2. Preserve the original regions patch.
3. Replace superseded later patches only after acceptance.
4. Build the complete NixOS package stack.
5. Run nested tests against the packaged plugin.
6. Activate the NixOS system closure only after packaged tests pass.

Exit condition:

The packaged plugin reproduces the approved nested capture.

## Test Requirements

The Mathematical Checks and Blur Checks exist since Phases 1 and 3.

The Geometry Checks exist since Phase 6.

The current Glass-on-Glass and Optical Mapping checks exist. Their semantic-geometry extensions remain open through Phase 8.

Production QML tests 40 through 48 exist. Geometry-publisher coverage remains open through Phase 8.

### Tier Zero

Run these tests after each shader or parser phase:

```sh
make test-tier0
make test-optics-oracle
make test-visual-analyzer
```

The shader test can obtain `glslangValidator` through Nix.

The workspace has no project flake or shell file.

Direct build dependencies might not exist in `PATH`.

Use the existing test helpers before you create another environment.

### Mathematical Checks

Add these checks:

- Zero displacement at each semantic center.
- Symmetric centered displacement on equivalent axes.
- Correct diagonal behavior.
- Finite and bounded centered output with exact edge inversion preserved.
- Finite Snell output over the complete bezel.
- No center crossing.
- Positive standalone Snell Jacobian over every certified strength prefix.
- Combined centered-plus-Snell Jacobian diagnostics without a rejection gate.
- No exterior sample displacement.
- Independent centered-mapping and rim widths.
- Stable deterministic noise.

### Blur Checks

Add these checks:

- Exact impulse support.
- Horizontal and vertical symmetry for the selected pass behavior.
- Correct half-size output.
- Correct zero-radius behavior.
- No black sample strip.
- No extra blur variants for one material.

### Geometry Checks

Add these checks:

- Full snapshot after connect.
- Atomic two-namespace commit.
- Duplicate-ID rejection.
- Invalid-number rejection.
- Count mismatch rejection.
- Oversize transaction rejection.
- Old-bounds damage after movement.
- Old-bounds damage after disconnect.
- Stable center during panel reveal.
- Center follows the complete live menu bounds during menu resize.
- Center follows the complete live power bounds during power resize.
- Correct lower-control movement during menu animation.
- Correct power-card height during expansion.

### Glass-on-Glass Checks

Keep `tests/nested/49-quickshell-glass-on-glass.sh`.

Extend the glass-on-glass test for semantic geometry.

Keep these conditions:

- Parent-only output differs from raw output.
- Child-only output differs inside child shapes.
- Child-only output leaves parent gaps raw.
- Stacked output preserves exposed parent areas.
- Stacked child areas differ from each single-material endpoint.
- Both carriers remain `416x956`.
- The child samples the current parent result.

### Optical Mapping Checks

Extend `tests/nested/54-green-optics-mapping.sh`.

The prior optics-mapping fixture requires `pills.lens` and tests the rejected mapping.

Replace that fixture instead of extending its JFA-lens assertions.

Done in Phase 8: Updated `tests/nested/quickshell-optics/shell.qml` to publish semantic geometry.

Done in Phase 4: Replace the old expected magnifications `1.12` and `1.18` with Phase 1 CPU-oracle values.

Keep the phase encoding, affine fit, composition check, and exterior check.

Done in Phase 2: Rewrite test 51 to validate rejection and atomic retention for typed optics objects.

Done in Phase 2: Do not keep `pills.lens` as a capability probe.

Keep the current phase encoding:

```text
R = 0.5 + 0.25*cos(theta)
G = 0.5 + 0.25*cos(theta + 2*pi/3)
B = 0.5 + 0.25*cos(theta + 4*pi/3)
period = 64 px
```

Keep these current tolerances.

| Check | Limit |
|---|---:|
| Flat repeat p95 | `0.20 px` |
| Affine fit RMS | `0.25 px` |
| Magnification error | `0.03` |
| Composition p95 | `0.35 px` |
| Composition maximum | `0.75 px` |
| Exterior p95 | `0.15 px` |

Do not weaken a tolerance only to pass the new implementation.

Change a tolerance only when the Phase 1 CPU analyzer shows that the fixture encodes the wrong quantity and the user approves the change.

### Production QML Checks

Keep tests 40 through 48.

Tests 40 through 48 cover these services:

- Shell lifecycle.
- Brightness.
- Audio.
- Do Not Disturb.
- Power.
- USB.
- Bluetooth.
- Wi-Fi.
- Wi-Fi password transitions.

The geometry publisher must not change service behavior.

## Visual Acceptance Procedure

Use a fixed 1600x900 nested output at scale 1.

Capture these states:

1. Raw background.
2. Parent only.
3. Child only.
4. Parent and child stacked.
5. Menu expanding.
6. Menu expanded.
7. Menu collapsing.
8. Power expanding.
9. Wi-Fi password transition.

Use at least these backgrounds:

- An eight-pixel checkerboard for diagnostics.
- A phase pattern for displacement recovery.
- A terminal with high-contrast text.
- A normal wallpaper with broad color regions.
- A normal wallpaper with fine detail.

Synthetic patterns are diagnostic tools only.

The user must approve normal desktop captures.

## Acceptance Gates

The implementation is complete only when all gates pass.

### Gate 1: Base Parity

The centered mapping matches the CPU oracle.

The exact centered edge inversion remains present and does not require a bypass setting.

The blur, parity noise, and angular glow match the OverShifted source oracle.

Snell, tint, tone, chromatic, rim, and specular extensions are neutral.

### Gate 2: Snell Safety

The convex correction matches the CPU oracle.

All accepted centered settings remain finite, bounded, symmetric, and do not cross the component center.

All accepted standalone Snell mappings remain finite and monotonic over the complete configured strength prefix.

Combined centered-plus-Snell Jacobians are diagnostic and do not reject the exact centered source behavior.

### Gate 3: Semantic Stability

An ancestor reveal does not change a semantic shape center.

A real material resize updates bounds and center in the same snapshot.

No stale optical shape remains after movement or removal.

### Gate 4: Composition

Parent and child materials compose through the existing surface order.

Text and icons remain above their own glass.

### Gate 5: Performance

The implementation adds no per-frame CPU map generation.

The implementation adds no GPU readback and no displacement texture.

Record GPU frame time before and after the change.

Measure at least 300 stable stacked frames for each build.

Require the new p95 GPU frame time to increase by no more than `1.0 ms` and `10 percent`.

If either limit fails, optimize the implementation or request explicit user approval.

### Gate 6: Visual Approval

The user approves the final production captures.

Do not package or deploy before this approval.

## Main File Map

Use this table to avoid broad source searches.

| File | Reason to read it |
|---|---|
| `src/Shaders.hpp` | Glass, blur, JFA, and composition shaders. |
| `src/GlassRenderer.cpp` | Background capture, blur passes, uniforms, and draws. |
| `src/GlassRenderer.hpp` | Framebuffer contracts and shader data structures. |
| `src/GlassLayerSurface.cpp` | Layer cache, masks, regions, JFA, and composition. |
| `src/GlassLayerSurface.hpp` | Layer-owned framebuffers and cache state. |
| `src/GlassDecoration.cpp` | Window sample and render path. |
| `src/ShaderManager.cpp` | Shader compilation and uniform locations. |
| `src/ShaderManager.hpp` | Uniform structures and shader ownership. |
| `src/PluginConfig.hpp` | Configuration types and semantic values. |
| `src/PluginConfig.cpp` | Config registration, parsing, and validation. |
| `src/BuiltInPresets.hpp` | Current default and preset values. |
| `src/OpticalConfig.hpp` | Typed optical values, errors, overrides, diagnostics, and cache interfaces. |
| `src/OpticalConfig.cpp` | Optical parsing, safety checks, diagnostics, caching, and override application. |
| `src/PresetConfig.hpp` | Immutable preset snapshots, typed overrides, and registry interfaces. |
| `src/PresetConfig.cpp` | Preset merging, optical resolution, and atomic registry commits. |
| `src/MaterialIdentity.hpp` | Stable FNV-1a material hashes and shader seeds. |
| `src/BlurVariantPlan.hpp` | Atomic deduplication and limits for blur-radius variants. |
| `src/SemanticGeometry.hpp` | Semantic snapshot types, protocol limits, lookup, and damage interfaces. |
| `src/SemanticGeometry.cpp` | Bounded protocol parsing, validation, binding, snapshots, and damage calculation. |
| `src/GeometrySocket.hpp` | Geometry server creation, callbacks, paths, and lifecycle interface. |
| `src/GeometrySocket.cpp` | Secure nonblocking Unix socket and Wayland event-loop lifecycle. |
| `src/Globals.hpp` | Global maps, caches, and plugin-owned services. |
| `src/main.cpp` | Plugin lifecycle and layer render hook. |
| `tests/visual/analyze-optics.sh` | Physical displacement recovery. |
| `tests/visual/optics-manifest.json` | Current optical probes and limits. |
| `tests/visual/optics-oracle.py` | Centered safety, Snell-prefix safety, combined diagnostics, and CPU blur model. |
| `tests/visual/optics-reference.c` | Independent C99 transcription for normal-test spot checks. |
| `tests/visual/source-oracle-status.json` | Durable pinned-source oracle provenance and comparison result. |
| `tests/visual/source-oracle-capture.sh` | Reproducible bounded capture harness for the pinned source executable. |
| `tests/tier0/optical-config.cpp` | Typed optics, safety validators, caches, merging, and atomic reload tests. |
| `tests/tier0/semantic-geometry.cpp` | Bounded semantic parser, snapshot, binding, and damage tests. |
| `tests/tier0/11-semantic-geometry.sh` | Sanitized semantic parser test runner. |
| `tests/tier0/geometry-socket.cpp` | Socket framing, credentials, ownership, and lifecycle tests. |
| `tests/tier0/12-geometry-socket.sh` | Sanitized geometry socket test runner. |
| `tests/nested/49-quickshell-glass-on-glass.sh` | Parent and child integration. |
| `tests/nested/50-green-typed-optics-config.sh` | Valid typed objects, replacement, inheritance, and legacy-rim integration. |
| `tests/nested/51-red-optical-config.sh` | Invalid typed optics, snapshot retention, and valid recovery. |
| `tests/nested/52-green-exact-blur.sh` | Exact blur resampling, transitions, clamping, and target restoration. |
| `tests/nested/53-red-blur-cache-state.sh` | Blur cache invalidation, deduplication, overflow, and fallback behavior. |
| `tests/nested/54-green-optics-mapping.sh` | Nested phase-map capture. |
| `tests/nested/55-green-snell-rim.sh` | Nested Snell, rim, aliases, composition, and neutrality checks. |
| `tests/nested/56-green-legacy-runtime-optics.sh` | Runs only with `HG_NESTED_LEGACY_CONFIG=1`. Checks legacy keyword changes and restoration. |
| `tests/nested/57-green-semantic-geometry-socket.sh` | Nested valid, malformed, and reconnect geometry streams. |
| `/home/orhun/Documents/dotfiles/.config/quickshell/ControlCenter.qml` | Live control geometry and animation. |
| `/home/orhun/Documents/dotfiles/.config/quickshell/Theme.qml` | Production dimensions, radii, and colors. |
| `/home/orhun/Documents/dotfiles/modules/home/linux/_hyprland/hyprland.nix` | Production parent and child Hyprglass settings. |
| `/home/orhun/.config/hypr/hyprglass.lua` | Hand-owned runtime override for final production checking. |
| `/home/orhun/Documents/dotfiles/pkgs/hyprglass.nix` | Package source and patch order. |

## Known Pitfalls

Do not confuse the unused base shader `blur13()` with the active blur path.

Do not use shader declaration defaults instead of runtime defaults.

Do not calculate semantic centers from visible clip intersections.

Do not treat a panel reveal edge as a material edge.

Do not add JFA magnification again.

Do not combine centered and Snell offsets without diagnostic Jacobian tests.

Do not apply the standalone Snell monotonicity gate to the exact centered mapping.

Do not use the article SVG quantization in the compositor.

Do not copy the article progressive blur into Hyprglass.

Do not merge the parent and child layer surfaces.

Do not composite QML content more than once.

Do not reuse a parent sample framebuffer for a child surface.

Do not truncate semantic shapes when a transaction is too large.

Do not reload or activate the user's compositor during early development.

Do not use passing checkerboard tests as visual approval.

Do not read a production `edge_thickness` value below `1` as a Snell bezel width. That value uses the old normalized meaning.

## Non-Goals for the First Implementation

Do not implement these features in the first delivery:

- Concave Snell surfaces.
- Lip surfaces.
- Same-surface nested glass for icon circles.
- Glass slider thumbs.
- Glass menu rows.
- Moving light sources.
- Animated glare.
- Per-control material presets.
- Unbounded semantic shape counts.
- Dynamic sample padding.
- A generic public geometry protocol for other applications.

The protocol can grow after the control-center result passes acceptance.

## Definition of Done

All following statements must be true to complete the work:

- The rejected optics no longer drive production rendering.
- The base engine has reproducible CPU and source-oracle comparisons.
- The exact preblur path passes its tests.
- Semantic controls use complete centers and bounds.
- The convex Snell bezel is active and safe.
- The narrow dual-lobe rim is independent from the centered mapping.
- Parent and child glass compose correctly.
- All existing production QML service tests pass.
- All optical thresholds pass.
- Normal desktop captures show broad depth and a narrow contour.
- The user explicitly approves the result.
- The packaged plugin reproduces the user-approved production captures.
