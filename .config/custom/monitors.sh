#!/bin/bash

# Check if HDMI-1 is connected
if xrandr | grep -q "HDMI-1 connected"; then
    # Determine HDMI-1 mode and resolution
    if xrandr | sed -n '/^HDMI-1/,/^[^ ]/p' | grep -q '3840x2160.*60'; then
        HDMI_MODE="3840x2160"
        HDMI_RATE=60
    elif xrandr | sed -n '/^HDMI-1/,/^[^ ]/p' | grep -q '2560x1440.*59\.95\|2560x1440.*60'; then
        HDMI_MODE="2560x1440"
        HDMI_RATE=60
    else
        HDMI_MODE=""
    fi

    # Get dimensions for bottom-alignment
    HDMI_W=$(echo "$HDMI_MODE" | cut -dx -f1)
    HDMI_H=$(echo "$HDMI_MODE" | cut -dx -f2)
    # Get eDP-1 preferred resolution height
    EDP_H=$(xrandr | sed -n '/^eDP-1/,/^[^ ]/p' | grep -oP '\d+x\d+' | head -1 | cut -dx -f2)

    if [ -n "$HDMI_MODE" ]; then
        # Bottom-align: offset eDP-1 so bottoms match
        Y_OFFSET=$(( HDMI_H - EDP_H ))
        xrandr --output HDMI-1 --mode "$HDMI_MODE" --rate "$HDMI_RATE" --primary --pos 0x0 \
               --output eDP-1 --auto --pos "${HDMI_W}x${Y_OFFSET}"
    else
        # Fallback: auto mode, still try bottom-align
        HDMI_H=$(xrandr | sed -n '/^HDMI-1/,/^[^ ]/p' | grep -oP '\d+x\d+' | head -1 | cut -dx -f2)
        HDMI_W=$(xrandr | sed -n '/^HDMI-1/,/^[^ ]/p' | grep -oP '\d+x\d+' | head -1 | cut -dx -f1)
        Y_OFFSET=$(( HDMI_H - EDP_H ))
        xrandr --output HDMI-1 --auto --primary --pos 0x0 \
               --output eDP-1 --auto --pos "${HDMI_W}x${Y_OFFSET}"
    fi
else
    xrandr --output eDP-1 --auto --primary --output HDMI-1 --off
fi

# background
feh --bg-fill ~/.config/assets/bg1.jpg
