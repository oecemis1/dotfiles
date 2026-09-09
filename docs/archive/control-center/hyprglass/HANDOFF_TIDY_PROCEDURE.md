# Tidy Procedure for the Liquid Glass Handoff

## Purpose

This document lists corrections for `LIQUID_GLASS_IMPLEMENTATION_HANDOFF.md`.

The corrections come from a review of that document on 2026-09-05.

The handoff is the target document. This file is the procedure.

Complete this procedure after Phase 6 passes its exit condition.

Complete this procedure before Phase 7 starts.

## Start Conditions

Check all of these conditions before you start:

1. The Phase Progress row for Phase 6 in the target document says `Complete`.
2. `git status --short --branch` shows the branch `regions`.
3. No other process is editing the target document.

Stop and report to the user when a condition fails.

## Rules

1. Edit only the target document and this document.
2. Do not edit a source file, a test file, or a build file.
3. Do not edit a configuration file in the dotfiles repository or in `~/.config`.
4. Do not change an equation, a constant, a numeric range, a tolerance, or a limit.
5. Do not change the meaning of a rule. Change only the words that state the rule.
6. Do not add a fact that you did not confirm from the code or from a file.
7. Do not delete a scope condition or an exception to make a sentence shorter.
8. Do not run a destructive Git command.
9. Do not commit unless Section K applies.
10. Locate text with the exact quoted strings in this document. Do not rely on line numbers.
11. Do not change text inside a fenced code block unless a step names that block.
12. Do not change a quoted identifier, a file name, or a protocol token.

## Terms

| Term | Meaning |
|---|---|
| Target document | `LIQUID_GLASS_IMPLEMENTATION_HANDOFF.md` |
| Prose | Text outside fenced code blocks. Table cells are prose. |
| Evidence list | A bulleted list under a `### Phase N Evidence` heading. |
| Slash construct | Two words joined by `/`. Paths, URLs, fractions, and test counts are not slash constructs. |
| Durable path | A path inside this repository that Git tracks. |
| Local path | A path under `/tmp`, `/nix/store`, or `tests/out`. |
| Actor | The person, tool, test, or component that performs an action. |

## Section A: Status Sections

A1. In `## Current Status`, delete these two sentences:

```text
No new engine code exists yet.
```

```text
This handoff is the only file that this planning session added.
```

A2. In their place, add these sentences:

```text
Phases 0 through 6 are complete. See Phase Progress.

All Phase 1 through Phase 6 work is uncommitted in the worktree.

The last commit before this work is `ec9a104`, dated 2026-08-28.

Commit only when the user approves a commit.
```

A3. When Section K commits the work, replace the second and third sentences of A2 with the commit hash.

## Section B: Phase Progress Evidence

B1. Under the Phase Progress table, add one heading for each completed phase. Use this form:

```text
### Phase 0 Evidence
```

B2. Move the text of each `Evidence` cell into the evidence list for that phase.

B3. Replace each moved cell with `See Phase N Evidence.`

B4. Write each bullet as one sentence of 25 words or fewer.

B5. Do not use a semicolon in a bullet.

B6. Start each bullet with the actor or the artifact. Examples:

```text
- Tier 0 passed 10 of 10 checks in `tests/out/20260905T185920Z` (local only).
- The C99 oracle passed 230 checks in 360.221 s.
```

B7. Replace each slash construct in the moved text. Use these replacements:

| Find | Replace with |
|---|---|
| `native/transformed` | `native and transformed` |
| `offline/full` | `offline and full` |
| `CPU/C99` | `CPU and C99` |
| `C++/Phase 1` | `C++ and Phase 1` |
| `configuration/reload` | `configuration and reload` |
| `typed/rejection/Snell/rim` | `typed, rejection, Snell, and rim` |
| `mapping/composition/exterior/physical-displacement/local-noise` | `mapping, composition, exterior, physical-displacement, and local-noise` |

B8. Write each test count in the form `10 of 10`.

B9. For each review claim, name the reviewer type. Write `A human review found` only when the user confirms a human review. Otherwise write `An agent review found`.

B10. In the Phase 5 evidence, delete the phrase `code exit condition`. Write exactly one of these sentences:

```text
Phase 5 met its exit condition.
```

```text
Phase 5 has this open item: <item>.
```

Confirm which sentence is true from the Phase 5 exit condition text and the recorded test results.

B11. Replace this local path with the durable path `tests/visual/source-oracle-status.json`:

```text
/tmp/opencode/hyprglass-source-oracle-phase5/runs/20260905T184712Z-4049298/source-oracle-report.json
```

Keep the run ID `20260905T184712Z-4049298` in the bullet.

B12. Add the words `(local only)` after each remaining local path in an evidence list.

B13. These phrases appear in evidence cells and have no definition:

- `legacy keyword refresh`
- `legacy-parser keyword smoke`
- `advisory-only rejection`
- `atomic variant-planning`
- `source-identity enforcement`

For each phrase, do one of these:

- Add a row to the `## Terms` table. Use the test file that implements the behavior as the source of the definition.
- Replace the phrase with plain words that state the behavior.

B14. Write the Phase 6 evidence in the same form.

## Section C: Flat `edge_thickness` Mapping

C1. Read `src/PluginConfig.cpp` at the text `if (key == "edge_thickness")`.

C2. Read `src/PluginConfig.cpp` at the text `cannot be combined with flat edge_thickness`.

C3. Read the preset merge code in `src/OpticalConfig.cpp` near the text `legacyFresnelStrength`.

C4. Confirm these three facts from the code:

1. The flat `edge_thickness` key sets the Snell bezel width in logical pixels. The range is `0.0` through `48.0`.
2. The flat key does not set thickness, refractive index, or strength.
3. A preset layer that contains both `snell` and `edge_thickness` is rejected.

C5. Confirm from the code where thickness, refractive index, and strength come from when a layer sets only the flat key.

C6. In `## Optics to Remove or Replace`, find:

```text
- The old `edge_thickness` behavior.
```

Replace with:

```text
- The old normalized meaning of `edge_thickness`.
```

C7. In `### Public Capability Mapping`, find the table row that starts with `| Edge width |`. Replace the first cell with `` `edge_thickness` ``. Keep the second cell.

C8. In `## Typed Configuration Model`, find:

```text
A complete nested `rim` object in a later preset layer replaces the rim value inherited from an earlier layer.
```

After that sentence, add:

```text
When a preset omits `snell`, map the flat `edge_thickness` field to the Snell bezel width in logical pixels.

The flat field sets only the bezel width. <Write the confirmed source of thickness, refractive index, and strength from step C5.>

Reject a `hyprglass.preset()` call when the same Lua table contains `snell` and `edge_thickness`.
```

Replace the angle-bracket text with one sentence that states the fact from step C5.

C9. Confirm from the code whether a complete nested `snell` object in a later layer replaces inherited Snell values. When true, add this sentence after the C8 text:

```text
A complete nested `snell` object in a later preset layer replaces the Snell values inherited from an earlier layer.
```

C10. The production configuration still uses the old normalized meaning:

| File | Text |
|---|---|
| `/home/orhun/Documents/dotfiles/modules/home/linux/_hyprland/hyprland.nix` | `edge_thickness = 0.002,` and `edge_thickness = 0.0025,` |
| `/home/orhun/.config/hypr/hyprglass.lua` | `edge_thickness = 0.002,` and `edge_thickness = 0.0025,` |

Do not edit these files.

C11. In `### Phase 8: Integrate Semantic Shapes`, add this task after task 7:

```text
8. Replace the production `edge_thickness` values `0.002` and `0.0025` in `hyprland.nix` before the first production capture. Map each value to its namespace. Use the configured Snell bezel width for that namespace from First Production Candidates.
```

C12. In `## Known Pitfalls`, add:

```text
Do not read a production `edge_thickness` value below `1` as a Snell bezel width. That value uses the old normalized meaning.
```

## Section D: Geometry Socket Lifecycle

D1. Identify the file that Phase 6 created for the socket server. The handoff expects `src/GeometrySocket.cpp`. Confirm the name.

D2. Read the server lifecycle in that file.

D3. In `### Socket Path`, find these four sentences:

```text
Remove only the socket path that the plugin created.
```

```text
Hold an exclusive nonblocking `flock` on the lock file for the server lifetime.
```

```text
Remove the path only when connection returns `ECONNREFUSED`.
```

```text
Bind the listener before the plugin releases or closes the lock.
```

The first and third sentences conflict. The stale path from a dead instance is a path this plugin did not create. The second and fourth sentences conflict. One says hold the lock for the lifetime. The other implies release after bind.

D4. Replace the four sentences with one numbered list in this form:

```text
Use this server lifecycle:

1. Open the lock file. Acquire an exclusive nonblocking `flock`.
2. When the lock is unavailable, do not remove any socket path. Send one notification. Stop the server start.
3. Try one client connection to the existing socket path.
4. Remove the existing path only when the connection returns `ECONNREFUSED`.
5. Bind the listener while the plugin holds the lock.
6. Hold the lock until the plugin unloads.
7. During unload, close the listener. Remove the socket path that this process created. Release the lock.
```

D5. Compare each step with the code. When the code differs from a step, write the code behavior in that step.

D6. Report each difference to the user as a deviation. Do not change the code.

D7. Keep the other sentences in `### Socket Path` unchanged.

## Section E: Single-Sentence Corrections

For each item, find the exact text and replace it.

E1. Find:

```text
`Refraction power` is the exponent inside the OverShifted curve.
```

Replace with:

```text
`Refraction power` is the exponent applied to the output of the OverShifted curve `f(distance)`.
```

E2. Find and delete this sentence in `### Production Shape Adapter`. The `### Effective Optical Values` code block already defines `minDimension`.

```text
`minDimension` means `min(width, height)` in the stated coordinate units.
```

E3. Find:

```text
It does not substitute a default, range endpoint, or parity value for a parsed value.
```

Confirm from `src/OpticalConfig.cpp` that both validators use parsed values only. Then replace with:

```text
Neither validator substitutes a default, a range endpoint, or a parity value for a parsed value.
```

E4. Find:

```text
Reject more than 16 clips or four surfaces in protocol version 1.
```

Confirm both limits in the Phase 6 parser. Then replace with:

```text
Reject more than 16 clips in protocol version 1.

Reject more than four surfaces in protocol version 1.
```

E5. Find:

```text
Direct build dependencies may not exist in `PATH`.
```

Replace with:

```text
Direct build dependencies might not exist in `PATH`.
```

E6. Find:

```text
3. Do not regenerate `hyprglass-regions.patch`.
```

Replace with:

```text
3. Do not regenerate `/home/orhun/Documents/dotfiles/pkgs/hyprglass-regions.patch`.
```

E7. Find these two Phase 2 tasks:

```text
4. Remove the new use of `lens_distortion`.
5. Remove the new use of `pills.lens`.
```

Run this command:

```sh
grep -rn 'lens_distortion\|pills\.lens' src tests
```

Replace the two tasks with two sentences that state the confirmed current state. Use this form:

```text
4. `lens_distortion` has no use in `src`. Tests keep it only as <confirmed role>.
5. `pills.lens` has no use in `src`. Tests keep it only as <confirmed role>.
```

Replace each angle-bracket text with the confirmed role.

E8. Find:

```text
Do not add a public or internal parity-bypass boolean.
```

After that sentence, add:

```text
A parity-bypass boolean is a configuration option or code flag that selects the parity boundary from user configuration or skips the centered-mapping acceptance rule.

The internal boundary-kind enumeration in `src/GlassRenderer.cpp` is not a parity-bypass boolean.
```

Confirm that `tests/tier0/08-centered-mapping.sh` rejects a public parity option before you add the text.

E9. Find:

```text
Otherwise report a value as `minimum_sampled_determinant` or a detected `first_failure`; do not label traversal-dependent values as global minima.
```

Replace with:

```text
Otherwise report the value as `minimum_sampled_determinant` or as a detected `first_failure`.

Do not label a traversal-dependent value as a global minimum.
```

E10. Find the sentence that starts with:

```text
The `64x64`, radius `32`, bezel `48`, thickness `64`, IOR `2` regression must fail because
```

Replace the complete sentence with:

```text
The `64x64`, radius `32`, bezel `48`, thickness `64`, IOR `2` regression must fail.

Its strength-`1` endpoint recovers above `0.05` on that geometry.

Lower strengths in the prefix are unsafe.
```

E11. Find the sentence that starts with:

```text
For the CPU identity state, use centered-mapping strength `0.0`,
```

Replace the complete sentence with this text:

```text
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
```

Confirm each value against the original sentence before you delete it. The original says `zero rim strengths`. The last three rows state that phrase as values.

## Section F: Test Instruction Status

F1. In `### Optical Mapping Checks`, these instructions describe work that a completed phase may have done:

```text
Update `tests/nested/quickshell-optics/shell.qml` to publish semantic geometry.
```

```text
Replace the old expected magnifications `1.12` and `1.18` with values generated by the Phase 1 CPU mapping oracle.
```

```text
Rewrite test 51 to validate the new typed optics objects.
```

```text
Do not keep `pills.lens` as a capability probe.
```

F2. For each instruction, read the named test file. Decide whether the work is done.

F3. Prefix each done instruction with `Done in Phase N:`. Use the phase whose evidence covers it.

F4. Prefix each open instruction with `Open, Phase N:`. Use the phase that owns the work. Semantic geometry in the QML fixture belongs to Phase 8.

F5. Under `## Test Requirements`, add one paragraph that states which check lists exist and which are open. Confirm each statement from the test files. Use this form:

```text
The Mathematical Checks and Blur Checks exist since Phases 1 and 3.

The Geometry Checks exist since Phase 6.

The Glass-on-Glass Checks, Optical Mapping Checks, and Production QML Checks are open until Phase 8.
```

## Section G: Terms Table Additions

G1. Add these rows to `## Terms`:

| Term | Meaning |
|---|---|
| Check | A test assertion. |
| Validate | Parser or transaction acceptance of an input. |
| Certify | The conservative interval-subdivision proof for a Snell strength prefix. |
| Parity-bypass boolean | See Section E8. Copy that definition here. |
| Legacy parser | Define from `tests/nested/56-green-legacy-runtime-optics.sh`. |

G2. Add the rows that Section B13 requires.

## Section H: Main File Map Additions

H1. Add one row for each of these files. Write one reason of 12 words or fewer.

- `src/OpticalConfig.hpp`
- `src/OpticalConfig.cpp`
- `src/PresetConfig.hpp`
- `src/PresetConfig.cpp`
- `src/MaterialIdentity.hpp`
- `src/BlurVariantPlan.hpp`
- The Phase 6 server files. Confirm their names.
- `tests/tier0/optical-config.cpp`
- `tests/nested/50-green-typed-optics-config.sh`
- `tests/nested/51-red-optical-config.sh`
- `tests/nested/52-green-exact-blur.sh`
- `tests/nested/53-red-blur-cache-state.sh`
- `tests/nested/55-green-snell-rim.sh`
- `tests/nested/56-green-legacy-runtime-optics.sh`
- `tests/visual/source-oracle-status.json`
- `tests/visual/source-oracle-capture.sh`
- Each Phase 6 parser test file.

H2. Note that test 56 runs only when `HG_NESTED_LEGACY_CONFIG=1` is set.

## Section I: Style Pass

I1. Remove every semicolon in prose. Split the sentence at the semicolon.

I2. Replace each slash construct in prose with `and`, `or`, or a list.

I3. Split each prose sentence that has more than 25 words.

I4. Rewrite these noun clusters where they appear in prose:

| Find | Replace with |
|---|---|
| `half-size horizontal intermediate framebuffer` | `the half-size intermediate framebuffer for the horizontal pass` |
| `full-size raw sample framebuffer` | `the full-size framebuffer for the raw sample` |
| `half-size final blurred framebuffer` | `the half-size framebuffer for the final blurred sample` |
| `scale-correct logical pass bounds` | `logical pass bounds that are correct at each monitor scale` |
| `runtime optical snapshot replacement` | `replacement of the optical snapshot at runtime` |
| `fresh pinned source-executable capture` | `a new capture from the pinned source executable` |
| `same-background target restoration` | `restoration of the target framebuffer with the same background` |

I5. Apply the verb definitions from Section G1:

- Replace `verify`, `verifies`, and `verification` with `check`, `checks`, and `checking`.
- Replace `prove`, `proves`, and `proved` with `show`, `shows`, and `showed`.
- Keep `certify` only for the interval-subdivision proof.
- Do not change a verb inside a quoted identifier, a file name, or a code block.

I6. Rewrite each passive sentence that has no actor. Name the actor. Examples in evidence text include `are wired through`, `is covered`, and `was rejected`.

I7. Keep the sentence `It follows an ASD-STE100-inspired style.` in `## Document Purpose`.

## Section J: Verification

Python is not available in this environment. Use these shell commands.

J1. Semicolons in prose. Expected output: none.

```sh
F=LIQUID_GLASS_IMPLEMENTATION_HANDOFF.md
awk 'BEGIN{c=0} /^```/{c=!c; next} !c && /;/{print NR": "$0}' "$F"
```

J2. Prose sentences over 25 words. Expected output: none.

```sh
F=LIQUID_GLASS_IMPLEMENTATION_HANDOFF.md
awk 'BEGIN{c=0} /^```/{c=!c; next}
c || $0 ~ /^[ \t]*$/ || $0 ~ /^#/ {next}
{ t=$0; sub(/^[ \t]*([0-9]+\.|[-*])[ \t]+/,"",t); gsub(/\|/," ",t);
  n=split(t,s,/[.!?][ \t]+/);
  for(i=1;i<=n;i++){ w=split(s[i],ww,/[ \t]+/); if(w>25) printf "%d: %d words\n", NR, w } }' "$F"
```

J3. Slash constructs in prose. Review each hit. Paths, URLs, fractions, and test counts are allowed.

```sh
F=LIQUID_GLASS_IMPLEMENTATION_HANDOFF.md
awk 'BEGIN{c=0} /^```/{c=!c; next} !c' "$F" \
  | grep -nE '\b[A-Za-z][A-Za-z+-]*/[A-Za-z][A-Za-z+-]*\b' \
  | grep -vE 'https?://|/home/|/nix/|/tmp/|tests/|src/|app/|assets/|\.config/|/monitorScale'
```

J4. Modal check. Expected output: none.

```sh
grep -n 'may not' LIQUID_GLASS_IMPLEMENTATION_HANDOFF.md
```

J5. Replaced text check. Expected output: none.

```sh
F=LIQUID_GLASS_IMPLEMENTATION_HANDOFF.md
grep -nF -e 'No new engine code exists yet.' \
  -e 'This handoff is the only file that this planning session added.' \
  -e 'The old `edge_thickness` behavior.' \
  -e 'is the exponent inside the OverShifted curve' \
  -e 'It does not substitute a default' \
  -e 'Reject more than 16 clips or four surfaces' \
  -e 'Remove the new use of' \
  -e 'code exit condition' \
  -e 'Remove only the socket path that the plugin created.' \
  -e 'Bind the listener before the plugin releases or closes the lock.' \
  -e 'hyprglass-source-oracle-phase5/runs' "$F"
```

J6. Whitespace check. Expected output: none.

```sh
git diff --check
```

J7. Confirm that the target document still renders as Markdown. Open it and read the Phase Progress table and every new table.

Exit condition:

J1, J2, J4, J5, and J6 print nothing. J3 prints only allowed hits. J7 shows intact tables.

## Section K: Commit

Do Section K only when the user instruction that delivers this document contains the exact words `commit approved`.

Otherwise skip Section K and record `Skipped, not approved` in the checklist.

K1. Run `make test-tier0`. Stop and report when it fails.

K2. Stage these files:

- Every modified tracked file.
- Every untracked file under `src/`.
- Every untracked file under `tests/`.
- `THIRD_PARTY_NOTICES.md`
- `LIQUID_GLASS_IMPLEMENTATION_HANDOFF.md`
- `HANDOFF_TIDY_PROCEDURE.md`
- `AGENTS.md`

K3. Do not stage `PILL_DEPTH_PLAN.md` or `HYPRGLASS_TRANSFER_REPORT.md` unless the user names them.

K4. Do not stage a `*.so` file, a `build/` directory, or a `tests/out/` directory.

K5. Run `git status --short`. List every remaining untracked file in the report.

K6. Commit with a message in this form:

```text
feat(optics): add Liquid Glass engine phases 1 through 6

Phases: mathematical oracles, typed configuration, exact blur,
centered mapping, Snell bezel and rim, geometry server.
Handoff: LIQUID_GLASS_IMPLEMENTATION_HANDOFF.md
```

K7. Apply Section A3.

K8. Do not push.

## Section L: Report

Write a report to the user with these parts:

1. Each checklist item with its status.
2. Each deviation from Section D6.
3. Each fact you could not confirm. Name the step.
4. The output of J1 through J6.
5. The remaining untracked files from K5, when Section K ran.

After the report, start Phase 7 in the same turn. Do not wait for the user.

## Section M: Continuation Rule

M1. In the target document, find the Start Procedure step:

```text
7. Complete each phase before you start the next phase.
```

M2. After that step, add these steps:

```text
8. When a phase passes its exit condition, update its Phase Progress row and start the next incomplete phase in the same turn.
9. End your turn only when Phase 8 is complete, when a required test fails and you cannot fix it inside the phase file list, when a step needs a user decision, or when a tool permission was denied.
10. These steps need a user decision: Phase 9 step 8, Phase 10 step 6, a tolerance change, a commit, a file deletion, and any change to the live compositor of the user or to a hand-owned configuration file.
```

M3. Confirm that the text matches the Continuation Rule in `AGENTS.md`. When the two differ, make the target document match `AGENTS.md`.

## Checklist

Update the `Status` column as you work. Use `Open`, `Done`, `Skipped, not approved`, or `Blocked`.

| ID | Item | Status | Note |
|---|---|---|---|
| A | Status sections | Done | Updated current status and confirmed commit `ec9a104`. |
| B | Phase Progress evidence lists | Done | Added Phase 0 through Phase 6 evidence lists. |
| C | Flat `edge_thickness` mapping | Done | Confirmed width-only override and inherited base Snell values. |
| D | Geometry socket lifecycle | Done | Replaced conflicting text with the implemented lifecycle. |
| E | Single-sentence corrections | Done | Applied E1 through E11. |
| F | Test instruction status | Done | Recorded completed and open test instructions. |
| G | Terms table additions | Done | Added all required definitions and replaced undefined evidence phrases. |
| H | Main File Map additions | Done | Added typed optics, geometry server, oracle, and test files. |
| I | Style pass | Done | Controlled-language style checks pass. |
| J | Verification | Done | J1 through J6 printed nothing. J7 tables are intact. |
| K | Commit | Skipped, not approved | The instruction did not contain `commit approved`. |
| L | Report | Done | Reported checklist status, deviations, checks, and unconfirmed facts. |
| M | Continuation rule | Done | Added steps 8 through 10 to match `AGENTS.md`. |
