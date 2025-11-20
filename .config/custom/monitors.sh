#!/bin/bash

# if present, use HDMI-1 only
notification_body="something went wrong"
if xrandr | grep -q "HDMI-1 connected"; then
    # Look inside the HDMI-1 section, pick the first mode line with ~60 Hz
    hdmi_section=$(xrandr | sed -n '/^HDMI-1 connected/,/^[^[:space:]]/p' | sed '1d;$d')
    mode_line=$(echo "$hdmi_section" | awk '/^ +[0-9]+x[0-9]+/ && $0 ~ /59\.[0-9]|60\.[0-9]|61\.[0-9]/ {print $1, $2; exit}')
    if [ -n "$mode_line" ]; then
        res=$(echo "$mode_line" | awk '{print $1}')
        rate=$(echo "$mode_line" | awk '{print $2}' | tr -d '*+')
        xrandr --output HDMI-1 --mode "$res" --rate "$rate" --primary --output eDP-1 --off
        notification_body="HDMI-1 (${res} @ ${rate} Hz)"
    # if not present set the mode "auto"
    else
        xrandr --output HDMI-1 --auto --primary --output eDP-1 --off
        notification_body="HDMI: (auto)"
    fi
# Use eDP-1 only
else
    xrandr --output eDP-1 --auto --primary --output HDMI-1 --off
    notification_body="Primary: (auto)"
fi
notify-send "Display setup" "$notification_body"

# background
feh --bg-fill ~/.config/assets/bg11.png
