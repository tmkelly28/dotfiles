#!/usr/bin/env bash
# Pulls down the persistent alerter notification(s) for the given session id(s).
# Usage: claude-notify-clear.sh <session-id> [session-id...]
#
# Alerts are manual-dismiss (alerter's default --timeout 0, i.e. never auto-close),
# so something has to retract them once they're moot. Callers:
#   * claude-mark-viewed.sh -- you focused that instance's pane, so you've seen it
#   * claude-status.sh      -- the session went `running` again, or ended (`clear`)
set -u

bin="$(command -v alerter || echo /opt/homebrew/bin/alerter)"
[ -x "$bin" ] || exit 0

for sid in "$@"; do
  [ -n "$sid" ] || continue
  "$bin" --remove "claude-$sid" >/dev/null 2>&1 || true
done
exit 0
