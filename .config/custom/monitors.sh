#!/bin/bash

# Get HDMI-1 monitor name from EDID
get_hdmi_monitor_name() {
    local edid
    edid=$(xrandr --verbose | sed -n '/^HDMI-1/,/^[A-Z]/p' | grep -A256 'EDID:' | grep -oP '\t\t\K[0-9a-f]+' | tr -d '\n')
    [ -z "$edid" ] && return
    local raw
    raw=$(echo "$edid" | sed 's/../\\x&/g')
    # Find monitor name descriptor (tag 0xfc) at byte offsets 54,72,90,108
    for offset in 54 72 90 108; do
        local hex_offset=$((offset * 2))
        local tag_hex=${edid:$((hex_offset + 6)):2}
        local prefix=${edid:$hex_offset:6}
        if [ "$prefix" = "000000" ] && [ "$tag_hex" = "fc" ]; then
            local name_hex=${edid:$((hex_offset + 10)):26}
            printf '%b' "$(echo "$name_hex" | sed 's/../\\x&/g')" | tr -d '\n\r' | sed 's/ *$//'
            return
        fi
    done
}

if xrandr | grep -q "HDMI-1 connected"; then
    MONITOR_NAME=$(get_hdmi_monitor_name)

    if [ "$MONITOR_NAME" = "LG HDR 4K" ]; then
        # Custom config for LG HDR 4K
        HDMI_MODE="2560x1440"
        HDMI_RATE=60

        # Get dimensions for bottom-alignment
        HDMI_W=$(echo "$HDMI_MODE" | cut -dx -f1)
        HDMI_H=$(echo "$HDMI_MODE" | cut -dx -f2)
        # Get eDP-1 preferred resolution height
        EDP_H=$(xrandr | sed -n '/^eDP-1/,/^[^ ]/p' | grep -oP '\d+x\d+' | head -1 | cut -dx -f2)

        # Bottom-align: offset eDP-1 so bottoms match
        Y_OFFSET=$(( HDMI_H - EDP_H ))
        xrandr --output HDMI-1 --mode "$HDMI_MODE" --rate "$HDMI_RATE" --primary --pos 0x0 \
               --output eDP-1 --auto --pos "${HDMI_W}x${Y_OFFSET}"
    else
        # Default: auto-detect for any other HDMI monitor
        xrandr --output HDMI-1 --auto --primary --output eDP-1 --auto --right-of HDMI-1
    fi
else
    xrandr --output eDP-1 --auto --primary --output HDMI-1 --off
fi

# background
feh --bg-fill ~/.config/assets/bg1.jpg
