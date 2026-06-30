# Changelog

All notable changes to **kiro-dwl** are documented here.
Format: one dated entry per day (`YYYY.MM.DD`), newest first.

## 2026.06.30

### What Changed
- **Build fix: added `tllist` to `makedepends`.** `fcft.pc` declares `Requires: tllist`, so
  compiling dwlb against fcft failed with `Package 'tllist', required by 'fcft', not found`.
- **Build fix: declared `monoclegaps` in `config.h`.** The `vanitygaps.patch` (part 2/2) adds
  `monoclegaps` to dwl's `config.def.h` and uses it in `monocle()`, but the PKGBUILD overwrites
  `config.h` with Kiro's baked copy — which lacked the declaration — so `dwl.c:1883` failed with
  `'monoclegaps' undeclared`. Added the var to both `config.h` and the skel golden copy
  (`etc/skel/.config/dwl/config.h`) so the package build and `kiro-dwl-rebuild` both compile.
- **Moved shared dotfiles into the new `kiro-wayland-dotfiles` base** — mako, hyprlock/hypridle,
  and the waybar `colors.css`/`style.css` now come from that package (resolves the cross-edition
  file conflict, e.g. kiro-hyprland ↔ kiro-river both owning `~/.config/mako/config`). This edition
  now ships only its `waybar/config-<wm>.jsonc` and launches `waybar -c` against it.
- **Initial package** for the Kiro dwl edition — the suckless "dwm-for-Wayland" member of the
  KIROTUX Wayland line, the Wayland sibling of ohmychadwm/chadwm.
- **First KIROTUX edition that ships a compiled binary, not dotfiles.** dwl is configured at
  compile time (`config.h`), so the recipe builds a **patched dwl** (`ipc` + `vanitygaps`, Kiro
  `config.h`) and a Kiro-configured **dwlb** bar from source, into `nemesis_repo` — a new packaging
  model recorded as an ADR.
- **Static Tokyo Night theming (no pywal)** — the deliberate suckless bargain; colours are C
  `#define`s in `config.h`/dwlb config, not a runtime palette.
- **Hackable** — ships an editable `config.h` + `kiro-dwl-rebuild` so users recompile dwl the
  chadwm way.

### Technical Details
- `config.h` — dwm/chadwm master-stack grammar (Mod+j/k focus, Mod+i/d master count, Mod+h/l mfact,
  Mod+Ctrl+Return zoom, Mod+Shift+t/f/m layouts, tags), with Kiro's SUPER scheme layered on
  (CTRL+ALT launchers, SUPER+F1..F12, session binds) and vanitygaps. MODKEY = Logo (Super);
  layout `be,us`, Caps = Compose; Tokyo Night borders.
- Recipe `KIROTUX-PKG-BUILD/kiro-dwl/PKGBUILD` clones dwl (pinned `_dwlver`) + dwlb, applies the
  vendored `patches/{ipc,vanitygaps}.patch`, drops the Kiro configs, compiles both, and installs
  `/usr/bin/{dwl,dwlb,kiro-dwl-session}` + the session desktop + the skel + a golden copy (incl. the
  patched dwl source for the rebuild helper). `arch=('x86_64')` — it compiles.
- Session: `kiro-dwl-session` execs `dwl -s ~/.config/dwl/autostart.sh` (dwl's single autostart
  hook), setting `BEMENU_BACKEND=wayland` + the Wayland env. `autostart.sh` launches dwlb + status,
  swaybg, mako, hypridle, polkit, nm-applet.
- Bar: **dwlb** with `ipc=true` (live, clickable tags via `dwl-ipc-unstable-v2`); `status.sh`
  feeds the clock/volume/battery.
- Lock = hyprlock + hypridle (line-consistent); launcher = bemenu; gaps on (vanitygaps).

### Files
- `config.h`, `dwlb-config.def.h`, `patches/{ipc,vanitygaps}.patch`
- `bin/kiro-dwl-session`, `usr/share/wayland-sessions/dwl.desktop`
- `etc/skel/.config/dwl/{autostart.sh,status.sh,config.h,keybindings.txt,bg/kiro.jpg,scripts/{kiro-dwl-rebuild,import-gsettings.sh}}`
- `etc/skel/.config/{mako/config,hypr/{hyprlock,hypridle}.conf}`
- `README.md`, `CLAUDE.md`, `up.sh`, `setup.sh`, `.gitignore`, `kiro.jpg`

### Not yet verified — the first-build alignment gate (inherent to suckless)
- **The build is NOT compiled/validated here.** On the first chroot build you must align
  **{dwl tag `_dwlver` ↔ the vendored ipc patch ↔ the wlroots in [extra]}**: the ipc patch is
  version-sensitive (study §6), dwl's `config.mk` pins a specific wlroots, and `config.h` symbols
  shift between dwl releases. Expect to bump `_dwlver` / the ipc patch on first build — this is the
  dwl bargain, and the chadwm-patcher workflow.
- The dwlb `status.sh` feed (ipc vs `-status-stdin`) and the `config.h`↔patch symbol match are
  first-boot verification items.
- `kiro-keybindings` / `/kiro-create-keybindings` still need **dwl** in their WM-detection table.
