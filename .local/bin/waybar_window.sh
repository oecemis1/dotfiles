#!/usr/bin/env bash
# Dynamic window title with resolution-based max-length

get_window_title() {
    # Get window title using hyprctl, fallback to "Desktop" if empty
    # This part remains the same as it's already efficient with hyprctl and jq.
    hyprctl activewindow -j | jq -r '.title // "Desktop"' 2>/dev/null || echo "Desktop"
}

get_max_length() {
    # Get screen width from hyprctl monitors -j, fallback to a default if not found
    local width=$(hyprctl monitors -j | jq -r '(.[] | select(.focused == true) | .width) // 0' 2>/dev/null)

    # If width is still 0 or empty (e.g., hyprctl failed), provide a sensible default
    if [[ -z "$width" || "$width" -eq 0 ]]; then
        # Default to a standard laptop resolution if hyprctl fails completely
        width=1920
    fi

    # Set max-length based on screen width
    if [[ $width -ge 3840 ]]; then
        echo 150  # Ultrawide
    elif [[ $width -ge 2560 ]]; then
        echo 70  # Higher than standard
    else
        echo 30  # Standard/laptop (< standard)
    fi
}

truncate_title() {
    local title="$1"
    local max_length="$2"

    if [[ ${#title} -gt $max_length ]]; then
        echo "${title:0:$max_length}..."
    else
        echo "$title"
    fi
}

# Main execution
window_title=$(get_window_title)
max_length=$(get_max_length)
truncated_title=$(truncate_title "$window_title" "$max_length")

echo "$truncated_title"
