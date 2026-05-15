#!/usr/bin/env bash
# Toggle the @claude_waiting flag on the tmux window containing this Claude Code session.
# Usage: claude-tmux-waiting.sh <0|1>

arg="${1:-0}"

[ -z "$TMUX" ] && exit 0

info=$(tmux display-message -p -t "${TMUX_PANE:-}" '#{window_id} #{window_active}' 2>/dev/null) || exit 0
[ -z "$info" ] && exit 0
win="${info% *}"
active="${info#* }"

# Don't flag the window if the user is already looking at it.
if [ "$arg" = "1" ] && [ "$active" = "1" ]; then
  exit 0
fi

tmux set-option -w -t "$win" @claude_waiting "$arg"
tmux refresh-client -S 2>/dev/null
