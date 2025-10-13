#!/usr/bin/env bash

layout=$(hyprctl devices | grep -A 3 'asus-keyboard' | grep -m 1 "active keymap: " | awk -F': ' '{print $2}')
echo "$layout"
