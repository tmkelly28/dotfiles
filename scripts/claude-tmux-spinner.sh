#!/usr/bin/env bash
# Animate a spinner on the tmux window containing this Claude Code session.
# Toggled by Claude Code hooks via the @claude_working window option.
# Usage: claude-tmux-spinner.sh <start|stop>

[ -z "$TMUX" ] && exit 0

win=$(tmux display-message -p -t "${TMUX_PANE:-}" '#{window_id}' 2>/dev/null) || exit 0
[ -z "$win" ] && exit 0

pidfile="${TMPDIR:-/tmp}/claude-spinner-${win//[^A-Za-z0-9]/_}.pid"

kill_existing() {
  [ -f "$pidfile" ] || return 0
  local pid
  pid=$(cat "$pidfile" 2>/dev/null)
  [ -n "$pid" ] && kill "$pid" 2>/dev/null
  rm -f "$pidfile"
}

case "${1:-stop}" in
  start)
    kill_existing
    (
      trap 'tmux set-option -w -t "'"$win"'" @claude_working "" 2>/dev/null; tmux refresh-client -S 2>/dev/null; exit 0' TERM INT
      frames=(⠋ ⠙ ⠹ ⠸ ⠼ ⠴ ⠦ ⠧ ⠇ ⠏)
      while :; do
        for f in "${frames[@]}"; do
          tmux set-option -w -t "$win" @claude_working "$f" 2>/dev/null || exit 0
          tmux refresh-client -S 2>/dev/null
          sleep 0.12
        done
      done
    ) </dev/null >/dev/null 2>&1 &
    echo $! > "$pidfile"
    disown 2>/dev/null || true
    ;;
  stop)
    kill_existing
    tmux set-option -w -t "$win" @claude_working "" 2>/dev/null
    tmux refresh-client -S 2>/dev/null
    ;;
esac
