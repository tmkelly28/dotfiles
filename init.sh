#!/usr/bin/env bash

set -e

LOCAL_VIM_OVERRIDES=~/dotfiles/nvim/local.vim
if [[ ! -f "$LOCAL_VIM_OVERRIDES" ]]; then
  echo "Creating $LOCAL_VIM_OVERRIDES"
  touch $LOCAL_VIM_OVERRIDES
fi

HOME_FILES=(\
  ".bash_profile" \
  ".gitignore_global" \
  ".agignore" \
  ".zshrc" \
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
  "nvim/init.vim")

for f in ${CONFIG_FILES[@]}; do
  TARGET="$HOME/.config/$f"
  SOURCE="$HOME/dotfiles/$f"

  if [[ -f "$TARGET" ]]; then
    rm $TARGET
  fi

  ln -s $SOURCE $TARGET
done
