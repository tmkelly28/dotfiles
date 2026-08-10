#!/usr/bin/env bash
# Records this Claude session's status for the tmux indicator, and fires a
# persistent macOS alert (via `alerter`) when the session goes idle/blocked
# while the terminal isn't frontmost.
# Usage: claude-status.sh <running|permission|done|clear>
# Hook JSON (with .session_id and .cwd) is read from stdin.

state="${1:-}"
dir="$HOME/.claude/status"
mkdir -p "$dir"

input="$(cat)"
sid="$(printf '%s' "$input" | jq -r '.session_id // empty' 2>/dev/null)"
[ -n "$sid" ] || sid="unknown"
file="$dir/$sid"
notif_marker="$dir/.notify-$sid"
viewed_marker="$dir/.viewed-$sid"
cwd="$(printf '%s' "$input" | jq -r '.cwd // empty' 2>/dev/null)"

# An alert from the last idle may still be on screen (manual-dismiss). Work
# resuming or the session ending makes it moot, so retract it. Gated on the
# marker existing, since `running` fires on every tool call and must not
# shell out to alerter each time.
case "$state" in
  running|clear)
    [ -f "$notif_marker" ] && "$HOME/dotfiles/scripts/claude-notify-clear.sh" "$sid"
    ;;
esac

# --- write / clear state for the tmux status bar ---
if [ "$state" = "clear" ]; then
  rm -f "$file" "$notif_marker" "$viewed_marker"
else
  # state | epoch | tmux pane (empty when not in tmux) | cwd -- written atomically
  # so the renderer / mark-viewed hook never see a half-written line.
  printf '%s|%s|%s|%s\n' "$state" "$(date +%s)" "${TMUX_PANE:-}" "$cwd" > "$file.tmp" \
    && mv -f "$file.tmp" "$file"
fi

# New work resumes: reset the notify marker (so the next idle notifies again) and
# drop the viewed marker (a fresh cycle should re-show, not stay collapsed).
[ "$state" = "running" ] && rm -f "$notif_marker" "$viewed_marker"

# ============ notify when idle/blocked and you're not looking ============
TERMINAL_APP="iterm2"   # System Events process name of YOUR terminal (case-insensitive)
ALERTER_BIN="$(command -v alerter || echo /opt/homebrew/bin/alerter)"

notify() {
  local title="$1" msg="$2"
  [ -x "$ALERTER_BIN" ] || return 0
  # alerter blocks until the alert is dismissed or times out (default
  # --timeout 0 = never), so it must always run backgrounded + disowned,
  # never in the foreground of a hook.
  ( "$ALERTER_BIN" --title "$title" --message "$msg" --group "claude-$sid" \
      >/dev/null 2>&1 & disown ) 2>/dev/null
}

# Returns 0 when you ARE looking at the terminal (it's frontmost) -> suppress notify.
user_is_looking() {
  local front
  front="$(osascript -e 'tell application "System Events" to get name of first application process whose frontmost is true' 2>/dev/null)"
  if [ -n "$front" ]; then
    [ "$(printf '%s' "$front" | tr '[:upper:]' '[:lower:]')" = "$(printf '%s' "$TERMINAL_APP" | tr '[:upper:]' '[:lower:]')" ]
    return
  fi
  # Frontmost unknown (e.g. Automation permission denied) -> fall back to tmux clients.
  if [ -n "$TMUX" ]; then
    local clients; clients="$(tmux list-clients 2>/dev/null | wc -l | tr -d ' ')"
    [ "${clients:-0}" -gt 0 ]; return
  fi
  return 1
}

case "$state" in
  done|permission)
    # Notify only when you're NOT looking at the terminal, and dedupe on state change.
    last="$(cat "$notif_marker" 2>/dev/null || true)"
    if ! user_is_looking && [ "$state" != "$last" ]; then
      proj="$(basename "$cwd" 2>/dev/null)"
      [ -n "$proj" ] && [ "$proj" != "." ] || proj="claude"
      if [ "$state" = "permission" ]; then
        notify "Claude · needs approval" "✋ $proj needs your approval"
      else
        notify "Claude · done" "✅ $proj finished — your turn"
      fi
      printf '%s' "$state" > "$notif_marker"
    fi
    ;;
esac

# Redraw the tmux status bar immediately (server-wide, best-effort).
tmux refresh-client -S 2>/dev/null || true
exit 0
