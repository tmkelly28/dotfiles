#!/usr/bin/env bash
# Marks finished ('done') Claude sessions as "viewed" once you actually focus
# their pane, so they collapse from the named list into the 🌙 counter.
#
# Invoked (backgrounded) by tmux focus/navigation hooks in ~/dotfiles/.tmux.conf:
#   after-select-pane, after-select-window, client-session-changed,
#   client-attached, client-focus-in.
# Using client-focus-in means "viewed" only counts when the terminal itself
# has OS focus -- a task finishing while the terminal is backgrounded is NOT hidden.

dir="$HOME/.claude/status"
[ -d "$dir" ] || exit 0

# Focused pane(s): the active pane of the active window of each attached session.
focused=" $(tmux list-panes -a \
  -f '#{&&:#{pane_active},#{&&:#{window_active},#{session_attached}}}' \
  -F '#{pane_id}' 2>/dev/null | tr '\n' ' ') "

changed=0
shopt -s nullglob
for f in "$dir"/*; do
  IFS='|' read -r state ts pane cwd < "$f"
  [ -n "$pane" ] || continue
  case "$focused" in *" $pane "*) ;; *) continue ;; esac
  sid="$(basename "$f")"

  [ "$state" = "done" ] && { marker="$dir/.viewed-$sid"; [ -f "$marker" ] || { touch "$marker"; changed=1; }; }

  # Looking at the pane means you've seen it, so retract its persistent alert.
  # It's manual-dismiss and would otherwise pile up until clicked. .notify-<sid>
  # doubles as "an alert is currently posted", so this fires once and only when
  # there's one to pull down. Applies to `permission` too: the ✋ in the bar is
  # the standing reminder.
  if [ -f "$dir/.notify-$sid" ]; then
    "$HOME/dotfiles/scripts/claude-notify-clear.sh" "$sid"
    rm -f "$dir/.notify-$sid"
  fi
done

# Only force a redraw when something actually changed.
[ "$changed" -eq 1 ] && tmux refresh-client -S 2>/dev/null
exit 0
