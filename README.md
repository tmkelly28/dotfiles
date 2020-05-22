# My Dotfiles

Hi - my name's Tom, and these are my dotfiles. Feel free to dive in and see if there's anything you might want to duplicate or riff on in your own setup!

## Main

- OS: MacOS
- Shell: [zsh](https://en.wikipedia.org/wiki/Z_shell)
- Terminal Emulator: [iTerm2](https://www.iterm2.com/)
  - But also, sometimes [Kitty](https://sw.kovidgoyal.net/kitty/)
- Editor: [nvim](https://neovim.io/)
- Multiplexer: [tmux](https://github.com/tmux/tmux)

## Dependencies

On a brand new machine, certain external dependencies will need to be resolved.

- [Homebrew](https://brew.sh/)
  - `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"`
- [Oh My Zsh!](https://ohmyz.sh/)
  - `sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"`
- [Vim Plug](https://github.com/junegunn/vim-plug)
  - `curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim`

## Other Manual Installs

- [Docker Desktop](https://www.docker.com/products/docker-desktop)
- [Node](https://nodejs.org/en/)
- [Postgres.app](https://postgresapp.com/)

## Usage

- Clone this repository to your home directory
- `brew bundle`
- `bundle install`
- Execute `init.sh`: this creates symlinks in the `~` and `~/.config` directories, where appropriate
  - This needs to be repeated whenever a new root dotfile is added.
- Open an `nvim` buffer
  - `:PlugInstall`

## Current Dotfiles
- `zsh`
- `nvim`
- `tmux`
- `gitignore_global`
- `agignore`
- `kitty`
- `psql`
- `bash_profile` _(deprecated)_

## Package Managers
- `brew`
- `bundle`
