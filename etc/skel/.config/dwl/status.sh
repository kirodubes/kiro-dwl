#!/bin/sh
#####################################################################
# Author    : Erik Dubois
# Website   : https://kiroproject.be
#####################################################################
#   DO NOT JUST RUN THIS. EXAMINE AND JUDGE. RUN AT YOUR OWN RISK.
#
# Purpose:
#   dwmblocks-style status feed for dwlb — pushes clock + volume + battery
#   into the bar's status area every few seconds.
# Why:
#   dwl/dwlb ship no status content; this is the suckless slstatus/someblocks
#   equivalent, kept tiny and editable.
#
# NOTE: with dwlb ipc enabled, status text is set via the `dwlb -status`
#   command form (a second dwlb invocation talks to the running bar). Verify
#   on a real boot; if your dwlb build wants stdin instead, pipe this into
#   `dwlb -status-stdin all` from autostart.sh.
#####################################################################

while true; do
    vol="$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null | awk '{printf "%d%%", $2*100}')"
    bat="$(cat /sys/class/power_supply/BAT0/capacity 2>/dev/null)"
    [ -n "$bat" ] && bat=" $bat%" || bat=""
    clk="$(date +'%a %d %b  %H:%M')"
    dwlb -status all "  ${vol}${bat}   ${clk}  " 2>/dev/null || true
    sleep 5
done
