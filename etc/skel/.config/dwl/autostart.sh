#!/bin/bash
#####################################################################
# Author    : Erik Dubois
# Website   : https://kiroproject.be
#####################################################################
#   DO NOT JUST RUN THIS. EXAMINE AND JUDGE. RUN AT YOUR OWN RISK.
#
# Purpose:
#   Session autostart for the Kiro dwl edition. dwl runs this once via its
#   `-s` flag (see the kiro-dwl-session launcher): the single session
#   entrypoint — the dwl analogue of Hyprland exec-once / ohmychadwm run.sh.
# Why:
#   dwl has no built-in bar or autostart; everything is launched from here.
#####################################################################

# Authentication agent + environment for portals/screensharing.
/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &
dbus-update-activation-environment --systemd --all
systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP

# Create XDG user dirs on first login (dwl runs no /etc/xdg/autostart).
xdg-user-dirs-update &

# Mirror GTK theme/icons/cursor/font into gsettings for GTK4/libadwaita apps.
"$HOME/.config/dwl/scripts/import-gsettings.sh" &

# Wallpaper, notifications, idle-lock daemon, network applet.
swaybg -m fill -i "$HOME/.config/dwl/bg/kiro.jpg" &
variety &
mako &
hypridle &
nm-applet --indicator &

# The bar — dwlb gets live tags from dwl over ipc; status.sh feeds the clock/volume.
# dwl's `-s` mechanism wires this WHOLE script's stdin to dwl's own raw status pipe (dwl
# holds the write end open for its lifetime, feeding it printstatus() protocol lines). Any
# backgrounded child that doesn't redirect stdin inherits that pipe. dwlb (built without ipc
# support when the vendored ipc.patch doesn't apply to the pinned dwl tag — see the kiro-dwl
# PKGBUILD "first-build alignment gate") reads its own stdin unconditionally when ipc is off,
# and either dwl's raw bytes or an EOF on that pipe kills it silently — no error, no bar, no
# trace. Give it its own always-open, empty stdin so it never touches dwl's pipe: `tail -f
# /dev/null` blocks forever without producing data or EOF.
dwlb -font "JetBrainsMono Nerd Font:size=12" < <(exec tail -f /dev/null) >/dev/null 2>&1 &
"$HOME/.config/dwl/status.sh" &

# Live ISO only: auto-launch the installer. kiro_final strips this line on install.
sh -c '[ -d /run/archiso/bootmnt ] && calamares_polkit -d -style kvantum' &
