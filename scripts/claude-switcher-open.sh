#!/usr/bin/env bash
# Toggle for the persistent claude-switcher window (bound to prefix + a):
# focus it if one is already running anywhere on this tmux server, else
# create it. The window closes itself (see claude-switcher.sh) on Esc/Ctrl-C.

win="$(tmux list-windows -a -F '#{window_id} #{window_name}' 2>/dev/null | awk '$2=="claude-switcher"{print $1; exit}')"

if [ -z "$win" ]; then
  tmux new-window -n claude-switcher "$HOME/dotfiles/scripts/claude-switcher.sh"
  exit 0
fi

sess="$(tmux display-message -p -t "$win" '#{session_name}' 2>/dev/null)"
tmux switch-client -t "$sess" \; select-window -t "$win"
