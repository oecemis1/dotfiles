#!/usr/bin/env bash
# Active keyboard layout for waybar. Event-driven via Hyprland's socket2;
# waybar's built-in hyprland/language module goes blank when switching
# between the us,tr layouts.

label() {
    case "$1" in
        "English (US)") echo "EN" ;;
        "Turkish"*) echo "TR" ;;
        *) echo "$1" ;;
    esac
}

current() {
    hyprctl devices -j |
        jq -r '[.keyboards[] | select(.main) | .active_keymap][0] // .keyboards[0].active_keymap // empty'
}

label "$(current)"

SOCK="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"
socat -u "UNIX-CONNECT:$SOCK" - 2>/dev/null | while IFS= read -r line; do
    case "$line" in
        activelayout*) label "$(current)" ;;
    esac
done
