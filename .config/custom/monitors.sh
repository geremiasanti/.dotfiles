#!/bin/bash

# Check if HDMI-1 is connected
if xrandr | grep "HDMI-1 connected"; then
    # Use HDMI-1 only
    xrandr --output HDMI-1 --auto --primary --output eDP-1 --off
else
    # Use eDP-1 only
    xrandr --output eDP-1 --auto --primary --output HDMI-1 --off
fi
