#!/usr/bin/env bash
# Outputs the tmux pane_id (one per line) of every live Claude Code CLI instance,
# by matching each `claude` process's TTY to a tmux pane's TTY. Authoritative and
# self-correcting: finds idle instances and ones with no state file.

# TTYs of live `claude` CLI processes. `$1 != "??"` drops the tty-less
# chrome-native-host helper; the basename check keeps only the real CLI.
ttys="$(ps -Ao tty,command 2>/dev/null | awk '
  $1 != "??" {
    n = split($2, p, "/")
    if (p[n] == "claude") print $1
  }
' | sort -u)"
[ -n "$ttys" ] || exit 0

# Emit the pane whose tty matches each claude tty (pane_tty is /dev/ttysNNN).
tmux list-panes -a -F '#{pane_tty} #{pane_id}' 2>/dev/null | while read -r ptty pid; do
  printf '%s\n' "$ttys" | grep -qxF "${ptty#/dev/}" && printf '%s\n' "$pid"
done
