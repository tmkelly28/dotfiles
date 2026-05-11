#!/usr/bin/env bash
# Toggle the @claude_waiting flag on the tmux window containing this Claude Code session.
# Usage: claude-tmux-waiting.sh <0|1>

[ -z "$TMUX" ] && exit 0

info=$(tmux display-message -p -t "${TMUX_PANE:-}" '#{window_id} #{window_active}' 2>/dev/null) || exit 0
win="${info% *}"
active="${info#* }"

# Don't flag the window if the user is already looking at it.
if [ "${1:-0}" = "1" ] && [ "$active" = "1" ]; then
  exit 0
fi

tmux set-option -w -t "$win" @claude_waiting "${1:-0}"
