# kiro-dwl

The **suckless Wayland edition** of Kiro — dwl ("dwm for Wayland"), the Wayland sibling of Erik's
ohmychadwm/chadwm line (sibling to [kiro-hyprland](https://github.com/kirodubes/kiro-hyprland)).

## What it is

Unlike the other editions, dwl has **no runtime config** — keybinds, layouts, gaps, rules and
colours are all in `config.h`, **compiled into the binary**. So `kiro-dwl` is **not a skel of
dotfiles**: it is a **Kiro-built, pre-patched dwl binary** plus a Kiro-configured **dwlb** bar
(dwm-look, clickable tags over `dwl-ipc-unstable-v2`), built from source and shipped together with a
thin runtime layer. It's master/stack tiling with tags — the dwm muscle memory, in Wayland.

Theming is **static C** (`#define` colours, Tokyo Night) — the suckless bargain; there is no pywal
fan-out on this edition.

## What it ships

- **`/usr/bin/dwl`** — dwl patched with `ipc` + `vanitygaps`, Kiro's `config.h` baked in.
- **`/usr/bin/dwlb`** — the bar, Kiro Tokyo-Night config.
- **`/usr/bin/kiro-dwl-session`** + `wayland-sessions/dwl.desktop` — the session entry (`dwl -s`).
- `etc/skel/.config/dwl/` — `autostart.sh` (the single session entrypoint), `status.sh` (dwmblocks-
  style feed), `config.h` (editable copy), `keybindings.txt`, `bg/kiro.jpg`, and `scripts/`
  (`kiro-dwl-rebuild`, `import-gsettings.sh`).
- `etc/skel/.config/{mako,hypr}/` — notifications + the hyprlock/hypridle lock pipeline.

## Hackable (the suckless promise)

Edit `~/.config/dwl/config.h` and run `~/.config/dwl/scripts/kiro-dwl-rebuild` — it recompiles dwl
from the pristine Kiro source and installs your build to `~/.local/bin/dwl`. Exactly the
edit-config.h-and-recompile loop you know from chadwm.

## How to install

```sh
sudo pacman -S kiro-dwl
```

Pick **Kiro dwl** at the login greeter. Launcher is **bemenu** (Super+D); workspaces are **tags**
(Super+1..9), dwm-style. Press **Super+Ctrl+S** for the keybindings cheat sheet.

A pristine copy of the config + dwl source lives at `/usr/share/kiro/kiro-dwl/`.
