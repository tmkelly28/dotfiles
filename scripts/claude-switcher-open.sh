#!/usr/bin/env bash
# Bound to prefix + a. If the pane you're in is just sitting at an idle shell
# prompt (nothing running), run the switcher right there in place -- Enter
# jumps elsewhere without closing it, and Esc/Ctrl-C just drops you back at
# the prompt, no window churn.
#
# If something else is running in this pane (vim, ssh, another program), we
# don't want to clobber it -- fall back to the persistent "claude-switcher"
# window instead: focus it if one already exists, else create it.

pane="$(tmux display-message -p '#{pane_id}' 2>/dev/null)"
cmd="$(tmux display-message -p -t "$pane" '#{pane_current_command}' 2>/dev/null)"

case "$cmd" in
  zsh|-zsh|bash|-bash|fish|-fish|sh|-sh)
    # Idle shell prompt. C-u clears any partially-typed, un-submitted line
    # first so we don't append onto it.
    tmux send-keys -t "$pane" C-u "$HOME/dotfiles/scripts/claude-switcher.sh" Enter
    exit 0
    ;;
esac

win="$(tmux list-windows -a -F '#{window_id} #{window_name}' 2>/dev/null | awk '$2=="claude-switcher"{print $1; exit}')"

if [ -z "$win" ]; then
  tmux new-window -n claude-switcher "$HOME/dotfiles/scripts/claude-switcher.sh --own-window"
  exit 0
fi

sess="$(tmux display-message -p -t "$win" '#{session_name}' 2>/dev/null)"
tmux switch-client -t "$sess" \; select-window -t "$win"
