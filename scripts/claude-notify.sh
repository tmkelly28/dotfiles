#!/usr/bin/env bash
# Fire a macOS notification when Claude Code needs attention.
# Skips if the user is already looking at the Claude tmux window.
# Usage: claude-notify.sh "message"

msg="${1:-Claude is ready}"

if [ -n "$TMUX" ]; then
  active=$(tmux display-message -p -t "${TMUX_PANE:-}" '#{window_active}' 2>/dev/null)
  [ "$active" = "1" ] && exit 0
fi

alerter=$(command -v alerter || echo /opt/homebrew/bin/alerter)
"$alerter" \
  --title "Claude Code" \
  --message "$msg" \
  --sound default \
  --timeout 5 \
  >/dev/null 2>&1 &
disown 2>/dev/null || true
