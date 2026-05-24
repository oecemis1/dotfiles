#!/usr/bin/env bash

layout=$(hyprctl devices -j | jq -r '.keyboards[0].active_keymap')
echo "$layout"
