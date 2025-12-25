#!/usr/bin/env bash

# Define the base directory
BASE_DIR="$HOME/Pictures/Screenshots"

# Create date-based subfolders: Year/Month/Day
DIR_PATH="$BASE_DIR/$(date +%Y/%m/%d)"
mkdir -p "$DIR_PATH"

# Generate filename with timestamp
FILENAME="Shot_$(date +%H%M%S).png"

# Execute hyprshot with the dynamic path
# $1 is the mode passed from the keybind (region, window, or output)
hyprshot -m "$1" -o "$DIR_PATH" -f "$FILENAME" --post "notify-send 'Screenshot Saved' 'Stored in $DIR_PATH/$FILENAME'"
