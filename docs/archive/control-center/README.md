# Control Center Archive

This directory contains retired implementation snapshots and acceptance records for the control center. These files are historical evidence, not operative implementation instructions. Current dotfiles source and package configuration are authoritative.

## Final Accepted Record

`hyprglass/LIQUID_GLASS_IMPLEMENTATION_HANDOFF.md` is a verbatim copy of the final Liquid Glass implementation and acceptance record. It records the accepted dense material, corrected root-owned expansion timing, the explicit repeated-block performance exception, packaging, activation, and live geometry verification.

The activated system was:

```text
/nix/store/piq165p15sl1pj12n651h912h30g0i2m-nixos-system-odyssey-26.11.20260809.279b4a8
```

The final live checks found the plugin and service healthy, an empty Hyprland configuration-error list, a connected geometry publisher, and deployed QML matching the approved source.

`hyprglass/source-oracle-status.json` is supporting source-parity evidence. It is not a human visual-acceptance record.

## Rejected And Superseded History

- `CONTROL_CENTER_BLUR_HANDOFF.md` records the rejected screenshot-backdrop prototype.
- `hyprglass/HYPRGLASS_TRANSFER_REPORT.md` records a tested but explicitly rejected visual result.
- `hyprglass/PILL_DEPTH_PLAN.md` records the superseded nearest-boundary pill-optics direction.
- The other `CONTROL_CENTER_*_HANDOFF.md` files record superseded implementation plans and progress. They can contain accepted migration milestones, but they predate the final Liquid Glass acceptance.
- `hyprglass/HANDOFF_TIDY_PROCEDURE.md` is a completed documentation-maintenance procedure.
- `superseded-patches/` preserves the old incremental patch chain for reconstruction only. These patches are not active package inputs.

The archived files preserve their original bytes. Absolute paths and instructions inside them describe their original context and can be stale. Do not execute an archived deployment, patch-generation, or live-compositor instruction without checking current source.

## Current Package Boundary

`pkgs/hyprglass.nix` fetches pinned upstream Hyprglass `v0.7.0` and applies only:

1. `pkgs/hyprglass-regions.patch`
2. `pkgs/hyprglass-liquid-glass.patch`

The package does not depend on the local `/home/orhun/Documents/hyprglass` checkout. Do not move or alter the active regions patch, Liquid Glass patch, project README, legal notices, or project-agent instructions as part of archive maintenance.

## Archived File Inventory

| Original path | Archived path | SHA-256 |
|---|---|---|
| `/home/orhun/Documents/dotfiles/CONTROL_CENTER_BLUR_HANDOFF.md` | `CONTROL_CENTER_BLUR_HANDOFF.md` | `8eaf01e812cfba6ed6b299aba3930ff062e1ec4a033a2cd5b1cee272f5ce6c20` |
| `/home/orhun/Documents/dotfiles/CONTROL_CENTER_HYPRGLASS_HANDOFF.md` | `CONTROL_CENTER_HYPRGLASS_HANDOFF.md` | `f3d1ad4a80805bcd24296041a680cc97d8732fc0ba6f4135b7d90e0e9076c470` |
| `/home/orhun/Documents/dotfiles/CONTROL_CENTER_IMPLEMENTATION_HANDOFF.md` | `CONTROL_CENTER_IMPLEMENTATION_HANDOFF.md` | `03e8ec50643bb549914b1518642ba874ca91c9c0d8e58a5e5d61fe51458d1cae` |
| `/home/orhun/Documents/dotfiles/CONTROL_CENTER_PROGRESS_HANDOFF.md` | `CONTROL_CENTER_PROGRESS_HANDOFF.md` | `44b1881cbe4088347331a829b842be5bd591a95fd4132012960c074ff31788f1` |
| `/home/orhun/Documents/dotfiles/CONTROL_CENTER_QUICKSHELL_HANDOFF.md` | `CONTROL_CENTER_QUICKSHELL_HANDOFF.md` | `c05050fd97bba0338b8cdba0ae4ffbe43e64c3de4c9481c11b5c718b85c7128c` |
| `/home/orhun/Documents/dotfiles/CONTROL_CENTER_TEST_DEPLOY_HANDOFF.md` | `CONTROL_CENTER_TEST_DEPLOY_HANDOFF.md` | `5afaaf94469a64a7c4cb1ec0f7d5c26def9d56cbdd7fd9fa57b81b533a3a1e2e` |
| `/home/orhun/Documents/hyprglass/LIQUID_GLASS_IMPLEMENTATION_HANDOFF.md` | `hyprglass/LIQUID_GLASS_IMPLEMENTATION_HANDOFF.md` | `9772e81cb1751a4298e1d72bea42cbb7761d8160450f58ecc30dd961e11890d1` |
| `/home/orhun/Documents/hyprglass/HYPRGLASS_TRANSFER_REPORT.md` | `hyprglass/HYPRGLASS_TRANSFER_REPORT.md` | `7da82c3584fea65deeb14eafe1290f20d217d137d0aff8493c83d32cc6c8901c` |
| `/home/orhun/Documents/hyprglass/PILL_DEPTH_PLAN.md` | `hyprglass/PILL_DEPTH_PLAN.md` | `90e7f9e8b10adaa7eb9c7b1866148632577064e1a220bba670061f9c839b3437` |
| `/home/orhun/Documents/hyprglass/HANDOFF_TIDY_PROCEDURE.md` | `hyprglass/HANDOFF_TIDY_PROCEDURE.md` | `72f4f462b95bf9ec21e7ae28529daf0e144e547d8f389caba4d904f07026a040` |
| `/home/orhun/Documents/hyprglass/tests/visual/source-oracle-status.json` | `hyprglass/source-oracle-status.json` | `a98dcadc9b6c85103b36eb34aec8b4661e5d91d80f668242356d3b58ca1b2571` |
| `/home/orhun/Documents/dotfiles/pkgs/hyprglass-pill-corners.patch` | `superseded-patches/hyprglass-pill-corners.patch` | `9a6ca2f264cc6a81e8634d2b51cc32cc37b0434fec394a888442e7f67b20c3fb` |
| `/home/orhun/Documents/dotfiles/pkgs/hyprglass-background-field.patch` | `superseded-patches/hyprglass-background-field.patch` | `21167e49f115aaf4a16fd86bca53aeed08d80d8f293e60e1c7aa19c5f9c6eaa2` |
| `/home/orhun/Documents/dotfiles/pkgs/hyprglass-pill-optics.patch` | `superseded-patches/hyprglass-pill-optics.patch` | `e14d3978cb6d91c25ed69ab6ab9f656b976b704432abb5e9c80fba0383b5ff63` |

Each SHA-256 value was recorded at the original path before retirement and matched the archived file after transfer.

## Maintenance

Keep archived snapshots byte-identical. Add new explanations to this README instead of rewriting historical records.

Nix flakes include tracked source. After a new package patch has been reviewed, tracked, and committed through the normal workflow, build the system from the dotfiles root with:

```sh
nix build .#nixosConfigurations.odyssey.config.system.build.toplevel
```

Do not stage, commit, activate, or change the live compositor merely to maintain this archive.
