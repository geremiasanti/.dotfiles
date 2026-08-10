#!/bin/sh
# Cycle the ambient sound mode of the Soundcore earbuds:
# NoiseCanceling -> Transparency -> Normal -> NoiseCanceling
OPENSCQ30="$HOME/.local/bin/openscq30"

# first device registered in openscq30 (see `openscq30 paired-devices`)
MAC=$("$OPENSCQ30" paired-devices list -j | jq -r '.[0].macAddress')

current=$("$OPENSCQ30" device -a "$MAC" setting -g ambientSoundMode -j | jq -r '.[0].value.value')

case "$current" in
    NoiseCanceling) next=Transparency ;;
    Transparency) next=Normal ;;
    *) next=NoiseCanceling ;;
esac

"$OPENSCQ30" device -a "$MAC" setting -s "ambientSoundMode=$next"
notify-send "Soundcore" "Ambient sound mode: $next"
