#!/usr/bin/env bash

TODO_FILE="$HOME/Desktop/state/scratchpads/todo.txt"

# Create directory if it doesn't exist
mkdir -p "$(dirname "$TODO_FILE")"

# Create file if it doesn't exist
if [ ! -f "$TODO_FILE" ]; then
    touch "$TODO_FILE"
fi

# Launch todotxttui
todotxttui "$TODO_FILE"
