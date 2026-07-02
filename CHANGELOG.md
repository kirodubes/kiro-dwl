# Changelog

All notable changes to **kiro-dwl** are documented here.
Format: one dated entry per day (`YYYY.MM.DD`), newest first.

## 2026.07.02

### What Changed
- **Moved `/etc/dconf/profile/user` + `/etc/dconf/db/local.d/00-kiro.conf` to
  `kiro-wayland-dotfiles`.** All 9 Kiro Wayland editions had shipped identical copies of these
  files, which conflicted in pacman whenever two editions were installed on the same machine.
  Settings unchanged — now owned once in the shared package (already a dependency here).

### Files Modified
- `etc/dconf/` (removed, moved to `kiro-wayland-dotfiles`)

## 2026.07.01

### What Changed
- **Added Variety wallpaper-rotator autostart + keybinds.** `variety` (configured by
  `kiro-variety-config`) now autostarts alongside the existing static `swaybg` wallpaper. Ported
  the ohmychadwm `keybindings.txt` scheme (alt+N/P/T/F/arrows/Up/Down/W): next/previous/trash/
  favorite/pause/resume/selector. No pywal-recolor combos — this edition keeps static Tokyo Night
  colours (no pywal), so there's nothing to recolor. `variety` + `kiro-variety-config` added to
  `depends=()`.
- **Fixed: dwlb never appeared on boot (no bar at all).** Found live on `picard`. Root cause:
  dwl's `-s` autostart mechanism wires the *whole script's* stdin to dwl's own raw status pipe
  (dwl holds the write end open for its process lifetime). Every backgrounded child that doesn't
  redirect stdin inherits that pipe, and `dwlb` — built without ipc support on this box, since the
  vendored `patches/ipc.patch` didn't apply to the pinned `_dwlver=0.7` (the documented
  "first-build alignment gate") — reads its own stdin unconditionally whenever ipc is compiled
  off. Either dwl's raw protocol bytes or an EOF on that inherited pipe killed dwlb via a silent
  clean exit: no DIE() message, no signal, no trace, just gone. Fixed by giving dwlb its own
  always-open, empty stdin (`< <(exec tail -f /dev/null)`) so it never touches dwl's pipe.
  Confirmed live on picard (bar renders, `status.sh`'s clock/volume feed works over the control
  socket) — tags are visible but **not clickable**, since ipc is still compiled off; that's a
  separate, already-documented gap (see the alignment-gate note in `CLAUDE.md`), not something
  this fix addresses.
- Bumped `autostart.sh`'s shebang from `#!/bin/sh` to `#!/bin/bash` — the stdin fix uses bash
  process substitution (`<(...)`), not POSIX sh. `/bin/sh` happens to be bash on Arch so the old
  shebang wasn't broken, but the script now genuinely needs bash, so it says so.

### Technical Details
- Baked into `config.h` (compile-time) — both the root `config.h` and the golden `etc/skel`
  copy updated in lockstep, matching the existing `monoclegaps` fix pattern in this file. Requires
  `kiro-dwl-rebuild` (or a fresh package build) to take effect — a config.h edit alone does nothing
  on an already-compiled dwl binary.
- Verified no existing bare-Alt binds collided with alt+n/p/t/f/w/arrows before adding (only
  `CTRL+ALT` combos existed on those letters).
- dwlb root-caused by reading its own source (`~/Public/dwl-bar-dwlb-kolunmi/dwlb.c`): `!ipc`
  unconditionally adds `STDIN_FILENO` to the `select()` set and calls `read_stdin()`, independent
  of whether `-status-stdin` was ever requested. Confirmed via live SSH testing on picard: dwlb
  survives indefinitely with a live-but-silent stdin (a held-open FIFO / `tail -f /dev/null`), but
  dies immediately and silently whenever its stdin is EOF'd or fed unrelated data — matching dwl's
  raw printstatus() pipe exactly. `autostart.sh` is applied and live on picard now (patched
  directly over SSH); the canonical repo copy here was written to match, byte-for-byte on the
  fixed block.
- **Re-vendored `patches/ipc.patch` to actually apply to `dwl 0.7`.** The shipped patch (choc's
  `dwl-ipc-unstable-v2`, commit `6c6d655b`) predates 0.7 and failed 1 of 12 hunks —
  `printstatus()` — because 0.7 added a NULL-safe title/appid fallback (`broken`) the old patch's
  context didn't know about. Hand-ported that one hunk (same intent: replace the body with
  `wl_list_for_each(m, &mons, link) dwl_ipc_output_printstatus(m);`); the other 11 hunks were
  unchanged, just regenerated as a clean diff against `dwl 0.7` + `vanitygaps` so `patch -p1`
  applies with **zero fuzz, zero offset**. Two other candidates were dead ends: `~/Public/dwl-
  nephitejnf-rice/patches/ipc-v2-fixed.patch` targets a divergent fork (not a clean-tag patch) and
  `~/Public/dwl-patches-codeberg/stale-patches/ipc/ipc.patch` is byte-identical to the one that was
  already failing. Verified the new patch's bundled protocol XML matches `dwlb`'s own vendored
  copy (`~/Public/dwl-bar-dwlb-kolunmi`) — same interfaces, same version 2, diff is upstream typo
  fixes only (proccess→process, recieve→receive) — so the wayland-protocol contract lines up on
  both sides of the wire.
  **Not yet built or tested.** `patch -p1 --dry-run` passing is a textual/structural guarantee,
  not a compile guarantee — the chroot build (`KIROTUX-PKG-BUILD/kiro-dwl/build.sh`) needs an
  interactive `sudo` password, which has to be run by Erik. Once built: reinstall on `picard`,
  confirm `dwl` boots clean, and confirm tags are actually clickable (not just visible).

### Files Modified
- [config.h](config.h)
- [etc/skel/.config/dwl/config.h](etc/skel/.config/dwl/config.h)
- [etc/skel/.config/dwl/autostart.sh](etc/skel/.config/dwl/autostart.sh)
- [etc/skel/.config/dwl/keybindings.txt](etc/skel/.config/dwl/keybindings.txt)
- [patches/ipc.patch](patches/ipc.patch) — re-vendored for `dwl 0.7`
- [../KIROTUX-PKG-BUILD/kiro-dwl/PKGBUILD](../KIROTUX-PKG-BUILD/kiro-dwl/PKGBUILD)
- picard (live, `~/.config/dwl/autostart.sh`, out-of-band SSH patch — not part of this repo)

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
