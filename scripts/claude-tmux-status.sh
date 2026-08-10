#!/usr/bin/env bash
# Prints the one-line Claude status summary for tmux status-right.
#   1. Which instances exist   -> claude-live-panes.sh (TTY -> pane).
#   2. Is it working right now -> the pane footer shows "esc to interrupt".
#   3. Other states            -> hook state files ~/.claude/status/<sid>.
# Layout: ●N 🌙M ✋<perm names> ✅<done names, cap then ✅+K>   (counters lead).
# Written for macOS's stock bash 3.2.

dir="$HOME/.claude/status"
panes_helper="$HOME/dotfiles/scripts/claude-live-panes.sh"
DONE_CAP=4
WORKING_MARK='esc to interrupt'   # Claude's footer shows this only while processing

live_panes=" $(tmux list-panes -a -F '#{pane_id}' 2>/dev/null | tr '\n' ' ') "

# Load state files into arrays; prune files whose pane is truly gone.
n=0
shopt -s nullglob
for f in "$dir"/*; do
  IFS='|' read -r st ts pn cw < "$f"
  sid="$(basename "$f")"
  if [ -n "$pn" ]; then
    case "$live_panes" in
      *" $pn "*) : ;;
      *) rm -f "$f" "$dir/.viewed-$sid" "$dir/.notify-$sid"; continue ;;
    esac
  fi
  A_STATE[$n]="$st"; A_TS[$n]="${ts:-0}"; A_PANE[$n]="$pn"; A_SID[$n]="$sid"
  n=$((n + 1))
done

running=0; viewed=0; done_count=0; perm_l=""; done_l=""

pane_working() {  # 0 (true) if the pane's footer shows Claude is processing
  tmux capture-pane -p -t "$1" 2>/dev/null | awk 'NF{l=$0} END{print l}' | grep -q "$WORKING_MARK"
}

classify_idle() {  # state sid label -- for a pane that is NOT actively working
  local state="$1" sid="$2" label="$3"
  case "$state" in
    permission) perm_l="$perm_l #[fg=colour208,bold]✋${label}#[default]" ;;
    done)
      if [ -n "$sid" ] && [ -f "$dir/.viewed-$sid" ]; then
        viewed=$((viewed + 1))
      else
        done_count=$((done_count + 1))
        [ "$done_count" -le "$DONE_CAP" ] && done_l="$done_l #[fg=colour46,bold]✅${label}#[default]"
      fi ;;
    *)          viewed=$((viewed + 1)) ;;   # idle / stuck-running / waiting / untracked
  esac
}

for pane in $(bash "$panes_helper" 2>/dev/null); do
  label="$(tmux display-message -p -t "$pane" '#{session_name}' 2>/dev/null)"
  [ -n "$label" ] || label="claude"

  if pane_working "$pane"; then
    running=$((running + 1)); continue
  fi

  bi=-1; bts=-1; k=0
  while [ "$k" -lt "$n" ]; do
    if [ "${A_PANE[$k]}" = "$pane" ] && [ "${A_TS[$k]}" -gt "$bts" ]; then bts="${A_TS[$k]}"; bi="$k"; fi
    k=$((k + 1))
  done
  if [ "$bi" -ge 0 ]; then classify_idle "${A_STATE[$bi]}" "${A_SID[$bi]}" "$label"
  else classify_idle "idle" "" "$label"; fi
done

if [ "$done_count" -gt "$DONE_CAP" ]; then
  done_l="$done_l #[fg=colour46,bold]✅ +$((done_count - DONE_CAP))#[default]"
fi

out=""
[ "$running" -gt 0 ] && out="$out #[fg=colour39]● ${running}#[default]"
[ "$viewed" -gt 0 ]  && out="$out #[fg=colour244]🌙 ${viewed}#[default]"
out="$out$perm_l$done_l"

if [ -n "$out" ]; then printf '%s' "${out# }"
else printf '#[fg=colour240]· claude idle#[default]'; fi
