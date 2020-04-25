#!/usr/bin/env bash

set -e

rm ~/.bash_profile && ln -s ~/dotfiles/.bash_profile ~/.bash_profile
rm ~/.gitignore_global && ln -s ~/dotfiles/.gitignore_global ~/.gitignore_global
