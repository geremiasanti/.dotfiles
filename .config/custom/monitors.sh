#!/bin/bash

# Check if HDMI-1 is connected
if xrandr | grep -q "HDMI-1 connected"; then
    # If 4K monitor can't do 60Hz, use 1440p@60Hz instead
    if xrandr | sed -n '/^HDMI-1/,/^[^ ]/p' | grep -q '3840x2160.*60'; then
        xrandr --output HDMI-1 --auto --rate 60 --primary --output eDP-1 --auto --right-of HDMI-1
    elif xrandr | sed -n '/^HDMI-1/,/^[^ ]/p' | grep -q '2560x1440.*59\.95\|2560x1440.*60'; then
        xrandr --output HDMI-1 --mode 2560x1440 --rate 60 --primary --output eDP-1 --auto --right-of HDMI-1
    else
        xrandr --output HDMI-1 --auto --primary --output eDP-1 --auto --right-of HDMI-1
    fi
else
    xrandr --output eDP-1 --auto --primary --output HDMI-1 --off
fi

# background
feh --bg-fill ~/.config/assets/bg1.jpg
