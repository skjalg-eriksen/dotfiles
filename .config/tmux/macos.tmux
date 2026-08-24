
# macos tmux configuration

#set -s set-clipboard on
set -g default-command "reattach-to-user-namespace -l ${SHELL}"
set-option -g default-command "reattach-to-user-namespace -l zsh"
bind-key -T copy-mode-vi y send -X copy-pipe-and-cancel "pbcopy"
bind-key -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-pipe-and-cancel "pbcopy"
