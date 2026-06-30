# kiro-dwl — Claude project instructions

## Overview
Package for the **Kiro dwl edition** — the suckless "dwm-for-Wayland" member of the KIROTUX Wayland
line, the Wayland sibling of ohmychadwm/chadwm. Public, open-core, shipped via `nemesis_repo`. Full
research + decisions live in the internal `Kiro-HQ/Kirotux/study-of-dwl.md`.

## ⚠ This edition is structurally different — it ships a BINARY, not dotfiles
dwl is suckless: config is **compiled into the binary** (`config.h`). So unlike kiro-hyprland/niri/
wayfire/sway/river (skel-config packages), `kiro-dwl`:
- **builds** a patched dwl + a Kiro-configured dwlb from source, into `nemesis_repo` (the line's
  first compile); `arch=('x86_64')`, not `any`.
- is recorded as an **ADR** (the create-wayland-twm command needs a dwl-shaped Steps 3–4 variant).

## Edition spec (the WM-variable matrix)
- **Compositor:** dwl (codeberg), patched with **ipc** (`dwl-ipc-unstable-v2`, mandatory for any
  tag-aware bar) + **vanitygaps**, Kiro `config.h` baked in.
- **Config:** `config.h` (compile-time C). Edit + `kiro-dwl-rebuild` to recompile (chadwm workflow).
- **Bar:** **dwlb** (kolunmi), `ipc=true` for clickable tags; `status.sh` feeds clock/volume.
- **Launcher:** **bemenu** (`BEMENU_BACKEND=wayland`, set in `kiro-dwl-session`).
- **Autostart:** `dwl -s ~/.config/dwl/autostart.sh` — dwl's single hook (the run.sh analogue).
- **Theming:** **static C `#define`s, Tokyo Night — NO pywal** (the suckless bargain; the one
  edition that breaks the line's pywal default, deliberately).
- **Lock/idle:** hyprlock + hypridle (line-consistent).
- **Gaps:** on (vanitygaps).

## ⚠ First-build alignment gate (the load-bearing risk)
The build is **not compiled here**. On first chroot build, align
**{`_dwlver` (dwl tag) ↔ the vendored `patches/ipc.patch` ↔ the wlroots in [extra]}**:
- the **ipc patch is version-sensitive** (study §6) — the vendored one may need bumping to match
  the chosen dwl tag (upstream HEAD is 0.8-dev/wlroots-0.19; the maintained ipc patches in
  `~/Public/dwl-patches-codeberg` / nephitejnf's `ipc-v2-fixed.patch` target ~0.5);
- dwl's `config.mk` pins a specific `wlroots-0.NN` — set the `wlroots` dep/makedepend to match;
- `config.h` symbols (function names, struct fields) shift between dwl releases — validate against
  the pinned tag, not blog posts.
Erik (a chadwm patcher) resolves this on first build — it's the dwl bargain, not a defect.

## Patterns / gotchas
- **config.h / dwlb-config.def.h are include-fragments** — clang/LSP will flag `Rule`/`Layout`/
  `pixman_color_t` as undeclared; that's expected (they're `#include`d mid-`dwl.c`/`dwlb.c`).
- **Tags, not workspaces**; **no per-window opacity** (no transparent terminal).
- **To rebind you recompile** — document loudly; `keybindings.txt` must track `config.h`.

## Build / delivery
- `../KIROTUX-PKG-BUILD/kiro-dwl/build.sh` (chroot build → `~/EDU/nemesis_repo/`). The recipe clones
  dwl + dwlb, patches, compiles. After editing `config.h`/configs here: rebuild the package, then the
  ISO. See [../CLAUDE.md](../CLAUDE.md) for the full KIROTUX delivery architecture.
