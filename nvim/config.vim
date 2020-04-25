set nocompatible
syntax on
filetype plugin indent on
if (has("termguicolors"))
  set termguicolors
endif
colorscheme palenight
highlight NonText ctermfg=bg guifg=bg cterm=NONE gui=NONE

" force sync syntax highlighting in those nasty, large .vue files
autocmd BufEnter *.vue :syntax sync fromstart

" use bash aliases from noninteractive shell
let $BASH_ENV="~/.bash_aliases"

""" Configuration
set path=$PWD/**
set number        " Shows line numbers
set tabstop=2     " Sets tabs to be two spaces
set shiftwidth=2  " Sets how many columns are indented when you re-indent
set expandtab     " Expand tabs into spaces
set autoindent    " Enable auto-indent
set smartindent   " C-like autoindenting when starting a new line
set mouse=a       " Enable mouse
set noswapfile    " Disables making temporary backup files (.swp)
set autowrite     " Automatically :write before running commands
set autoread      " Reload files changed outside vim
set scrolloff=8   " Start scrolling when we're 8 lines away from margins
set sidescrolloff=15
set sidescroll=1  " Auto resize Vim splits to active split
set wildmenu        " Command line completion enhanced
set wildignore+=**/node_modules/**
set wildignore+=**/bower_components/**
set wildignore+=**/dump/**
set wildignore+=*/.git/*,*/.hg/*,*/.svn/*
set backspace=indent,eol,start  " Make backspace key work as expected
set complete-=i   " Remove included files from auto completion
set showmatch     " Brief visual feedback when you match a pair (ex. parentheses)
set noshowmode    " Hide mode at bottom of the screen (since I use airline)
set smarttab      " Tab smarter
set nrformats-=octal " Remove octals when using C-a or C-x
set shiftround       " Rounds indent to multiple of shiftwidth
set ttimeout         " Timeout to wait for compound commands
set ttimeoutlen=50   " Sets timeout length for timeout commands
set timeoutlen=350
set incsearch        " Show pattern matches as search is typed
set laststatus=2     " Always show a status line
set noruler          " Hide col/line number (handled by airline)
set showcmd          " Shows partial command in the last line
set encoding=utf-8   " Natch
set list             " Show whitespace characters
set listchars=tab:▒░,trail:▓
set hlsearch        " Highlight previous search pattern
set hidden          " Allows switching buffers without saving changes
set nobackup        " Don't create backup files - live on the wild side
set nowritebackup   " Changes the save behavior of vim to write directly to buffer - danger is my middle name
set fileformats=unix,dos,mac            " Used of EOL formats
set completeopt=menuone,longest,preview " Options for insert mode completion
" set completeopt-=preview                " tern_for_vim - turn off the preview window
set guioptions-=r   " Remove right-hand scrollbar
set guioptions-=L   " Remove left-hand scrollbar
set lazyredraw      " Don't redraw sometimes
