#!/usr/bin/env bash
# Battery monitor emitting waybar JSON with a state class for CSS styling.

get_battery_info() {
    # Check if battery exists, exit silently if not
    if [[ ! -d "/sys/class/power_supply/BAT1" ]]; then
        return
    fi

    local capacity=$(cat /sys/class/power_supply/BAT1/capacity 2>/dev/null || echo "0")
    local status=$(cat /sys/class/power_supply/BAT1/status 2>/dev/null || echo "Unknown")

    # Choose icon based on status and capacity
    local icon=""
    case "$status" in
        "Charging")
            icon="󰂄"
            ;;
        "Discharging")
            if [[ $capacity -ge 80 ]]; then
                icon="󰂂"
            elif [[ $capacity -ge 60 ]]; then
                icon="󰂀"
            elif [[ $capacity -ge 40 ]]; then
                icon="󰁾"
            elif [[ $capacity -ge 20 ]]; then
                icon="󰁼"
            else
                icon="󰁺"
            fi
            ;;
        "Full")
            icon="󰁹"
            ;;
        *)
            icon="󰂑"
            ;;
    esac

    local class=""
    if [[ "$status" == "Charging" ]]; then
        class="charging"
    elif [[ $capacity -le 10 ]]; then
        class="critical"
    elif [[ $capacity -le 20 ]]; then
        class="warning"
    fi

    printf '{"text": "%s %s%%", "class": "%s"}\n' "$icon" "$capacity" "$class"
}

get_battery_info
