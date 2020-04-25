#!/usr/bin/env bash

set -e

LOCAL_VIM_OVERRIDES=~/dotfiles/nvim/local.vim
if [[ ! -f "$LOCAL_VIM_OVERRIDES" ]]; then
  echo "Creating $LOCAL_VIM_OVERRIDES"
  touch $LOCAL_VIM_OVERRIDES
fi

rm ~/.bash_profile && ln -s ~/dotfiles/.bash_profile ~/.bash_profile
rm ~/.gitignore_global && ln -s ~/dotfiles/.gitignore_global ~/.gitignore_global
rm ~/.tmux.conf && ln -s ~/dotfiles/.tmux.conf ~/.tmux.conf
rm ~/.config/nvim/init.vim && ln -s ~/dotfiles/nvim/init.vim ~/.config/nvim/init.vim
