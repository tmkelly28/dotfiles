#!/usr/bin/env bash

set -e

LOCAL_VIM_OVERRIDES=~/dotfiles/nvim/local.vim
LOCAL_TMUX_OVERRIDES=~/dotfiles/.tmux-local.conf
LOCAL_ZSH_OVERRIDES=~/dotfiles/.zsh-local.zsh
if [[ ! -f "$LOCAL_VIM_OVERRIDES" ]]; then
  echo "Creating $LOCAL_VIM_OVERRIDES"
  touch $LOCAL_VIM_OVERRIDES
fi
if [[ ! -f "$LOCAL_TMUX_OVERRIDES" ]]; then
  echo "Creating $LOCAL_TMUX_OVERRIDES"
  touch $LOCAL_TMUX_OVERRIDES
fi
if [[ ! -f "$LOCAL_ZSH_OVERRIDES" ]]; then
  echo "Creating $LOCAL_ZSH_OVERRIDES"
  touch $LOCAL_ZSH_OVERRIDES
fi

HOME_FILES=(\
  ".bash_profile" \
  ".gitignore_global" \
  ".agignore" \
  ".zshrc" \
  ".psqlrc" \
  ".tmux.conf")

for f in ${HOME_FILES[@]}; do
  TARGET="$HOME/$f"
  SOURCE="$HOME/dotfiles/$f"

  if [[ -f "$TARGET" ]]; then
    rm $TARGET
  fi

  ln -s $SOURCE $TARGET
done

CONFIG_FILES=(\
  "kitty/kitty.conf" \
  "kitty/palenight.conf" \
  "kitty/iceberg.conf" \
  "nvim/init.vim")

for f in ${CONFIG_FILES[@]}; do
  TARGET="$HOME/.config/$f"
  SOURCE="$HOME/dotfiles/$f"

  if [[ -f "$TARGET" ]]; then
    rm $TARGET
  fi

  ln -s $SOURCE $TARGET
done
