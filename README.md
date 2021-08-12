# My Dotfiles

Hi - my name's Tom, and these are my dotfiles. Feel free to dive in and see if there's anything you might want to duplicate or riff on in your own setup!

## Main

- OS: MacOS
- Shell: [zsh](https://en.wikipedia.org/wiki/Z_shell)
- Terminal Emulator: [iTerm2](https://www.iterm2.com/)
  - But also, sometimes [Kitty](https://sw.kovidgoyal.net/kitty/)
- Editor: [nvim](https://neovim.io/)
- Multiplexer: [tmux](https://github.com/tmux/tmux)

## Github
- On a brand new machine, [generate a new ssh key and add it to Github](https://docs.github.com/en/enterprise-server@3.0/github/authenticating-to-github/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent)
- create a .ssh/config

```
Host *
 AddKeysToAgent yes
 UseKeychain yes
 IdentityFile ~/.ssh/<id_whatever>
```

## Manual Installs
- [GPG Tools](https://gpgtools.org/)
- [Homebrew](https://brew.sh/)
- [Oh My Zsh!](https://ohmyz.sh/)
- [Vim Plug](https://github.com/junegunn/vim-plug)
- [RVM](https://rvm.io/)
- [Java](https://www.java.com/en/)
- [Docker Desktop](https://www.docker.com/products/docker-desktop)
- [Node](https://nodejs.org/en/)
- [Go](https://golang.org/)
- [Postgres.app](https://postgresapp.com/)
- [Postico](https://eggerapps.at/postico/)

## Usage

- Clone this repository to your home directory
- `brew bundle`
- `bundle install`
- Execute `init.sh`: this creates symlinks in the `~` and `~/.config` directories, where appropriate
  - This needs to be repeated whenever a new root dotfile is added.
- `npm install -g vls typescript-language-server
- `python3 -m pip install --user --upgrade pynvim`
- `python2 -m pip install --user --upgrade pynvim`
- Open an `nvim` buffer
  - `:PlugInstall`
  - `:CocInstall coc-tsserver coc-json coc-html coc-css coc-solargraph coc-vetur`

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
