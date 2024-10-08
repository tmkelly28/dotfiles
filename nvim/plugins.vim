call plug#begin('~/.local/share/nvim/plugged')

" Navigation
Plug 'christoomey/vim-tmux-navigator'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
Plug 'moll/vim-bbye'
Plug 'scrooloose/nerdtree'

" Appearance
Plug 'cocopon/iceberg.vim'
Plug 'drewtempelmeyer/palenight.vim'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'mhinz/vim-startify'
" Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}

" Language
Plug 'ElmCast/elm-vim'
Plug 'ap/vim-css-color'
Plug 'leafgarland/typescript-vim'
Plug 'moll/vim-node'
Plug 'mxw/vim-jsx'
Plug 'neovimhaskell/haskell-vim'
Plug 'othree/javascript-libraries-syntax.vim'
Plug 'pangloss/vim-javascript'
Plug 'posva/vim-vue'
Plug 'tpope/vim-markdown'
Plug 'tpope/vim-rails'
Plug 'tpope/vim-bundler'
Plug 'tpope/vim-rbenv'
Plug 'tpope/vim-dadbod'
Plug 'kristijanhusak/vim-dadbod-ui'
Plug 'vim-ruby/vim-ruby'
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
Plug 'hashivim/vim-terraform'

" Utilities
Plug 'Raimondi/delimitMate'
" Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
" Plug 'SirVer/ultisnips'
Plug 'airblade/vim-gitgutter'
Plug 'jiangmiao/auto-pairs'
Plug 'ludovicchabant/vim-gutentags'
Plug 'ngmy/vim-rubocop'
Plug 'tomtom/tcomment_vim'
Plug 'tpope/vim-endwise'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-rhubarb'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-unimpaired'
Plug 'andrewradev/splitjoin.vim'
Plug 'dense-analysis/ale'
Plug 'dbeniamine/cheat.sh-vim'
Plug 'github/copilot.vim'

" Coc
" After installing coc for the first time, you need to install the
" various language plugins:
" :CocInstall coc-tsserver coc-json coc-html coc-css coc-solargraph coc-vetur
Plug 'neoclide/coc.nvim', {
      \ 'branch': 'release',
      \ }
" Plug 'autozimu/LanguageClient-neovim', {
"       \ 'branch': 'next',
"       \ 'do': 'bash install.sh',
"       \ }

call plug#end()
