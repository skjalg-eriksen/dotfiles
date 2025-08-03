#!/bin/bash

timestamp=$(date '+%Y-%m-%d_%H-%M-%S')
screenshot_dir="$HOME/Pictures/Screenshots"
screenshot_path="$screenshot_dir/screenshot_${timestamp}.png"

mkdir -p "$screenshot_dir"

# Take the shot
grim -g "$(slurp)" "$screenshot_path" && wl-copy < "$screenshot_path"

