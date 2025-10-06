#!/usr/bin/env bash

# Dynamic Brightness Slider with Waybar-style theming
# This script creates a popup brightness slider that updates in real-time

# Check if brightness slider is already open
if hyprctl clients -j | jq -e '.[] | select(.title == "Brightness Control")' > /dev/null; then
    # If open, close it (toggle behavior)
    pkill -f "yad.*Brightness Control"
    exit 0
fi

# Create temporary CSS file with embedded styles
CSS_FILE=$(mktemp --suffix=.css)
cat > "$CSS_FILE" << 'EOF'
/* GTK CSS for brightness slider matching Waybar/Dracula theme */

window {
    background-color: rgba(21, 22, 29, 0.80);
    border: 1px solid rgba(68, 71, 90, 0.6);
    border-radius: 3px;
    padding: 0px;
}

* {
    color: #f8f8f2;
    font-family: "MonaspiceNe Nerd Font Mono";
    font-size: 14px;
}

box {
    padding: 0px;
    margin: 0px;
    margin-left: -1px;
    margin-right: -1px;
    margin-top: -10px;
    margin-bottom: -1px;
}

scale {
    min-width: 300px;
    min-height: 10px;
    margin: 0px;
}

scale trough {
    background-color: #44475a;
    border-radius: 3px;
    min-height: 5px;
    max-height: 5px;
}

scale highlight {
    background-color: #bd93f9;
    border-radius: 3px;
}

scale slider {
    background-color: #bd93f9;
    border: 2px solid #6272a4;
    border-radius: 4px;
    min-width: 12px;
    min-height: 12px;
    margin: -4px;
    box-shadow: none;
    background-image: none;
    -gtk-icon-source: none;
}

scale value {
    margin-bottom: 5px;
    min-width: 30px;
    color: transparent;
}


scale slider:hover {
    background-color: #8be9fd;
    border-color: #bd93f9;
}

scale mark {
    color: #6272a4;
    font-size: 10px;
    padding-top: 4px;
}
EOF

# Get current brightness (get actual percentage value)
current_brightness=$(brightnessctl get)
max_brightness=$(brightnessctl max)
current_percentage=$((current_brightness * 100 / max_brightness))

# Apply custom GTK theme
export GTK_THEME="Adwaita:dark"

WAYBAR_INFO=$(hyprctl layers -j | jq -r '.[].levels[][] | select(.namespace == "waybar")')
WAYBAR_HEIGHT=$(echo "$WAYBAR_INFO" | jq -r '.h')
if [ -z "$WAYBAR_HEIGHT" ] || [ "$WAYBAR_HEIGHT" == "null" ]; then
    WAYBAR_HEIGHT=40
fi
Y_POSITION=$((WAYBAR_HEIGHT + 7))

WAYBAR_X=$(echo "$WAYBAR_INFO" | jq -r '.w')
X_POSITION=$((WAYBAR_X - 340 + 3))

hyprctl keyword windowrulev2 "move ${X_POSITION} ${Y_POSITION}, title:^(Brightness Control)$"

# Launch yad slider - Hyprland window rules will handle positioning
yad --scale \
    --title="Brightness Control" \
    --value="$current_percentage" \
    --min-value=1 \
    --max-value=100 \
    --step=1 \
    --width=340 \
    --height=15 \
    --undecorated \
    --skip-taskbar \
    --no-grab \
    --on-top \
    --no-buttons \
    --close-on-unfocus \
    --print-partial \
    --gtkrc="$CSS_FILE" 2>/dev/null | while read -r value; do
        [ -n "$value" ] && brightnessctl set "${value}%"
    done &

wait

# Cleanup
rm -f "$CSS_FILE"
