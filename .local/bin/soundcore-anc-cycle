#!/bin/sh
# Cycle the ambient sound mode of the Soundcore P31i earbuds:
# NoiseCanceling -> Transparency -> Normal -> NoiseCanceling
MAC=A4:C1:39:6E:F7:D4
OPENSCQ30="$HOME/.local/bin/openscq30"

current=$("$OPENSCQ30" device -a "$MAC" setting -g ambientSoundMode -j | jq -r '.[0].value.value')

case "$current" in
    NoiseCanceling) next=Transparency ;;
    Transparency) next=Normal ;;
    *) next=NoiseCanceling ;;
esac

"$OPENSCQ30" device -a "$MAC" setting -s "ambientSoundMode=$next"
notify-send "Soundcore P31i" "Ambient sound mode: $next"
