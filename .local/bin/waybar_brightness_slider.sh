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
    background-color: rgba(21, 22, 29, 0.85);
    border: 1px solid rgba(68, 71, 90, 0.6);
    border-radius: 12px;
}

* {
    color: #f8f8f2;
    font-family: "MonaspiceNe Nerd Font Mono";
    font-size: 14px;
}

label {
    color: #bd93f9;
    font-size: 15px;
    padding: 10px;
}

scale {
    min-width: 300px;
    min-height: 30px;
}

scale trough {
    background-color: #44475a;
    border-radius: 8px;
    min-height: 8px;
}

scale highlight {
    background-color: #bd93f9;
    border-radius: 8px;
}

scale slider {
    background-color: #bd93f9;
    border: 2px solid #6272a4;
    border-radius: 10px;
    min-width: 20px;
    min-height: 20px;
    margin: -6px;
}

scale slider:hover {
    background-color: #8be9fd;
    border-color: #bd93f9;
}

scale mark {
    color: #6272a4;
    font-size: 11px;
}
EOF

# Get current brightness (get actual percentage value)
current_brightness=$(brightnessctl get)
max_brightness=$(brightnessctl max)
current_percentage=$((current_brightness * 100 / max_brightness))

# Apply custom GTK theme
export GTK_THEME="Adwaita:dark"

# Launch yad slider - Hyprland window rules will handle positioning
yad --scale \
    --title="Brightness Control" \
    --text="󰃠  Adjust Screen Brightness" \
    --value="$current_percentage" \
    --min-value=0 \
    --max-value=100 \
    --step=1 \
    --width=400 \
    --height=100 \
    --undecorated \
    --skip-taskbar \
    --on-top \
    --no-buttons \
    --close-on-unfocus \
    --borders=20 \
    --print-partial \
    --mark="󰃞 :0" \
    --mark="󰃟 :25" \
    --mark="󰃠 :50" \
    --mark=" :75" \
    --mark=" :100" \
    --gtkrc="$CSS_FILE" 2>/dev/null | while read -r value; do
        # Update brightness in real-time
        [ -n "$value" ] && brightnessctl set "${value}%"
    done

# Cleanup
rm -f "$CSS_FILE"
