
# Copy mode - use Wayland clipboard if available, fallback to xclip
bind-key -T copy-mode-vi y send -X copy-pipe-and-cancel \
  "sh -c 'if [ -n \"$WAYLAND_DISPLAY\" ] && command -v wl-copy >/dev/null 2>&1; then \
    wl-copy; \
  elif command -v xclip >/dev/null 2>&1; then \
    xclip -selection clipboard; \
  fi'"

# Mouse selection - same clipboard logic
bind-key -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-pipe-and-cancel \
  "sh -c 'if [ -n \"$WAYLAND_DISPLAY\" ] && command -v wl-copy >/dev/null 2>&1; then \
    wl-copy; \
  elif command -v xclip >/dev/null 2>&1; then \
    xclip -selection clipboard; \
  fi'"
