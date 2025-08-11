#!/bin/sh
export DISPLAY=:0
export XAUTHORITY=/run/user/1000/gdm/Xauthority

DIR="$HOME/Pictures/Screenshots"
mkdir -p "$DIR"
TS=$(date +%Y-%m-%d-%H%M%S)

if [ "$1" = "select" ]; then
    scrot -s "$DIR/screenshot_${TS}.png"
else
    scrot "$DIR/screenshot_${TS}.png"
fi

# Get the last created screenshot file
IMG=$(ls -1t "$DIR"/screenshot_*.png | head -n1)

# Wait a bit to ensure the file is written
sleep 0.2

# Copy to clipboard
xclip -selection clipboard -t image/png -i "$IMG"
