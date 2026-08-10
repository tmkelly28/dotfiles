#!/usr/bin/env bash
# fzf switcher listing every live Claude instance; Enter jumps to its pane.
# Jumping does NOT exit -- flipping back to wherever this is running shows
# the list again, freshly rebuilt. Esc/Ctrl-C (empty fzf selection) is the
# only way out.
#
# Usage: claude-switcher.sh [--own-window]
#   --own-window  This is running in a dedicated window claude-switcher-open.sh
#                 created just for it (the invoking pane was busy), so on exit
#                 kill that window too. Without it (the common case: it's
#                 running inline in a pane that was already idle) exit just
#                 returns control to that pane's normal shell -- nothing to
#                 clean up.

own_window=0
[ "${1:-}" = "--own-window" ] && own_window=1

dir="$HOME/.claude/status"
panes_helper="$HOME/dotfiles/scripts/claude-live-panes.sh"
WORKING_MARK='esc to interrupt'

FZF=fzf
command -v fzf >/dev/null 2>&1 || FZF="$HOME/.fzf/bin/fzf"   # fallback path; adjust if needed

pane_working() { tmux capture-pane -p -t "$1" 2>/dev/null | awk 'NF{l=$0} END{print l}' | grep -q "$WORKING_MARK"; }

build_rows() {
  local now dir_f n=0 pane bi bts k st ts pn cw sid loc proj status emoji age when
  now="$(date +%s)"

  A_STATE=(); A_TS=(); A_PANE=(); A_CWD=(); A_SID=()
  shopt -s nullglob
  for dir_f in "$dir"/*; do
    IFS='|' read -r st ts pn cw < "$dir_f"
    A_STATE[$n]="$st"; A_TS[$n]="${ts:-0}"; A_PANE[$n]="$pn"; A_CWD[$n]="$cw"; A_SID[$n]="$(basename "$dir_f")"
    n=$((n + 1))
  done

  for pane in $(bash "$panes_helper" 2>/dev/null); do
    bi=-1; bts=-1; k=0
    while [ "$k" -lt "$n" ]; do
      if [ "${A_PANE[$k]}" = "$pane" ] && [ "${A_TS[$k]}" -gt "$bts" ]; then bts="${A_TS[$k]}"; bi="$k"; fi
      k=$((k + 1))
    done
    if [ "$bi" -ge 0 ]; then st="${A_STATE[$bi]}"; ts="${A_TS[$bi]}"; cw="${A_CWD[$bi]}"; sid="${A_SID[$bi]}"
    else st="idle"; ts=0; cw=""; sid=""; fi

    if pane_working "$pane"; then
      emoji="●"; status="working"
    else
      case "$st" in
        permission) emoji="✋"; status="needs approval" ;;
        done)       if [ -n "$sid" ] && [ -f "$dir/.viewed-$sid" ]; then emoji="🌙"; status="idle"; else emoji="✅"; status="done"; fi ;;
        *)          emoji="🌙"; status="idle" ;;
      esac
    fi

    loc="$(tmux display-message -p -t "$pane" '#{session_name}:#{window_index}.#{pane_index}' 2>/dev/null)"
    [ -n "$loc" ] || loc="$pane"
    if [ -n "$cw" ]; then proj="$(basename "$cw")"
    else proj="$(basename "$(tmux display-message -p -t "$pane" '#{pane_current_path}' 2>/dev/null)")"; fi
    [ -n "$proj" ] && [ "$proj" != "." ] || proj="—"

    if [ "$status" != "working" ] && [ "$ts" -gt 0 ]; then
      age=$(( now - ts ))
      if   [ "$age" -lt 60 ];   then when="${age}s ago"
      elif [ "$age" -lt 3600 ]; then when="$((age / 60))m ago"
      else                           when="$((age / 3600))h ago"; fi
    else when="$status"; fi

    printf '%s\t%s  %s  %s  %s\n' "$pane" "$emoji" "$loc" "$proj" "$when"
  done
}

while true; do
  rows="$(build_rows)"
  [ -n "$rows" ] || rows=$'\t(no live Claude instances -- Esc to close)'

  sel="$(printf '%s' "$rows" | "$FZF" \
    --ansi --delimiter='\t' --with-nth=2.. --prompt='claude ▸ ' \
    --preview 'tmux capture-pane -pe -J -t {1}' --preview-window=right:60%)"

  [ -n "$sel" ] || break   # Esc / Ctrl-C -- explicit cancel, close the window

  pane="$(printf '%s' "$sel" | cut -f1)"
  [ -n "$pane" ] || continue
  sess="$(tmux display-message -p -t "$pane" '#{session_name}' 2>/dev/null)"
  [ -n "$sess" ] || continue
  tmux switch-client -t "$sess" \; select-window -t "$pane" \; select-pane -t "$pane"
  # Loop back around -- this stays alive in the background so flipping back
  # to it (prefix + a again, or just navigating back to the pane) shows a
  # freshly rebuilt list.
done

if [ "$own_window" = "1" ]; then
  self_win="$(tmux display-message -p '#{window_id}' 2>/dev/null)"
  [ -n "$self_win" ] && tmux kill-window -t "$self_win" 2>/dev/null
fi
exit 0
