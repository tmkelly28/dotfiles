" fzf
set rtp+=/usr/local/opt/fzf
nnoremap F :Files<CR>
nnoremap <C-p> :FZF<CR>
command! -bang -nargs=* GGrep
  \ call fzf#vim#grep(
  \   'git grep --line-number -- '.shellescape(<q-args>), 0,
  \   fzf#vim#with_preview({'dir': systemlist('git rev-parse --show-toplevel')[0]}), <bang>0)

" NerdTree
autocmd StdinReadPre * let s:std_in=1

" Open NERDTREE when vim opens
autocmd VimEnter *
            \   if !argc()
            \ |   Startify
            \ |   NERDTree
            \ |   wincmd w
            \ | endif
"autocmd vimenter * if @% !~# '.vimrc' && @% !~# '.tmux.conf' && @% !~# '.bash_profile' && @% !~# '.bashrc' && @% !~# '.eslintrc.json' && @% !~# '.todo'| NERDTree | endif

" Close vim if only NERDTree is open
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

" Navigation shortcuts
nnoremap <S-n> :NERDTreeToggle<CR>
let NERDTreeShowHidden=1
let NERDTreeIgnore=['.git$','.DS_Store', 'tags$', '__pycache__']

" Vim-Airline
let g:airline#extensions#tabline#enabled=1
let g:airline_powerline_fonts=1

" The Silver Searcher
if executable('ag')
  " Use ag over grep
  set grepprg=ag\ --nogroup\ --nocolor
  " Use ag in CtrlP for listing files. Lightning fast and respects .gitignore
  let g:ctrlp_user_command = 'ag %s -l --nocolor -g ""'
  " ag is fast enough that CtrlP doesn't need to cache
  let g:ctrlp_use_caching = 0
endif

" bind \ (backward slash) to grep shortcut
command! -nargs=+ -complete=file -bar Ag silent! grep! <args>|cwindow|redraw!
nnoremap \ :GGrep<SPACE>
" bind K to grep word under cursor
nnoremap K :grep! "\b<C-R><C-W>\b"<CR>:cw<CR>

" ale
let g:ale_linters = {
      \ 'javascript': ['eslint'],
      \ 'vue': ['eslint'],
      \ 'ruby': ['rubocop'],
      \ 'bash': ['shellcheck'],
      \ }

" ultisnips
" let g:UltiSnipsExpandTrigger="<c-b>"
" let g:UltiSnipsJumpForwardTrigger="<c-b>"
" let g:UltiSnipsJumpBackwardTrigger="<c-z>"

" markdown
let g:markdown_fenced_languages = ['html', 'css', 'javascript', 'json', 'ruby', 'python']

" language client
"
" ruby:
"   install solargraph globally using `gem install solargraph`
"   confirm local installation path
" javascript:
"   install language server: `npm i -g javascript-typescript-langserver`
"   This should create a symlink for /usr/local/bin/javascript-typescript-stdio
" vuejs
"   install language server: `npm i -g vls`
"   This should create a symlink for /usr/local/bin/vls
let g:LanguageClient_serverCommands = {
    \ 'ruby': ['~/.rvm/gems/ruby-2.6.5/bin/solargraph', 'stdio'],
    \ 'javascript': ['javascript-typescript-stdio'],
    \ 'vue': ['vls']
    \ }
let g:coc_global_extensions = ['coc-solargraph']

" Remap keys for gotos
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Highlight symbol under cursor on CursorHold
autocmd CursorHold * silent call CocActionAsync('highlight')
" Better display for messages
set cmdheight=2

" You will have bad experience for diagnostic messages when it's default 4000.
set updatetime=300

" don't give |ins-completion-menu| messages.
set shortmess+=c

" always show signcolumns
set signcolumn=yes

" Use K to show documentation in preview window
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

" Formatting selected code.
xmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)

inoremap <expr> <Tab> coc#pum#visible() ? coc#pum#next(1) : "\<Tab>"
inoremap <expr> <S-Tab> coc#pum#visible() ? coc#pum#prev(1) : "\<S-Tab>"
" Select the first completion item and confirm the completion when no item has been selected
inoremap <silent><expr> <cr> coc#pum#visible() ? coc#_select_confirm() : "\<C-g>u\<CR>"

let g:ascii = [
      \ '              .--~~,__  ',
      \ ' :-....,-------`~~`._.` ',
      \ '  `-,,,  ,_      ;`~U`  ',
      \ '   _,-` ,``-__; `--.    ',
      \ '  (_/`~~      ````(;    ',
      \ '                        '
      \]

let g:startify_custom_header =
      \ 'startify#pad(g:ascii + startify#fortune#boxed())'

" Gutentags
" https://www.reddit.com/r/vim/comments/d77t6j/guide_how_to_setup_ctags_with_gutentags_properly/
let g:gutentags_generate_on_new = 1
let g:gutentags_generate_on_missing = 1
let g:gutentags_generate_on_write = 1
let g:gutentags_generate_on_empty_buffer = 0

" https://stackoverflow.com/questions/43666122/ctags-and-ruby-modules-in-vim
" https://github.com/ludovicchabant/vim-gutentags/issues/87
" let g:gutentags_ctags_executable_ruby = 'ripper-tags'
" let g:gutentags_ctags_extra_args = ['--ignore-unsupported-options', '--recursive', '--extra=1']


let g:gutentags_ctags_extra_args = [
      \ '--tag-relative=yes',
      \ '--fields=+ailmnS',
      \ '--extras=+q',
      \ ]

let g:gutentags_ctags_exclude = [
      \ '*.git', '*.svg', '*.hg',
      \ '*/tests/*',
      \ 'build',
      \ 'dist',
      \ '*sites/*/files/*',
      \ 'bin',
      \ 'node_modules',
      \ 'bower_components',
      \ 'cache',
      \ 'compiled',
      \ 'docs',
      \ 'docs.json',
      \ 'example',
      \ 'bundle',
      \ 'vendor',
      \ '*.md',
      \ '*-lock.json',
      \ '*.lock',
      \ '*bundle*.js',
      \ '*build*.js',
      \ '.*rc*',
      \ '*.json',
      \ '*.min.*',
      \ '*.map',
      \ '*.bak',
      \ '*.zip',
      \ '*.pyc',
      \ '*.class',
      \ '*.sln',
      \ '*.Master',
      \ '*.csproj',
      \ '*.tmp',
      \ '*.csproj.user',
      \ '*.cache',
      \ '*.pdb',
      \ 'tags*',
      \ 'cscope.*',
      \ '*.css',
      \ '*.less',
      \ '*.scss',
      \ '*.exe', '*.dll',
      \ '*.mp3', '*.ogg', '*.flac',
      \ '*.swp', '*.swo',
      \ '*.bmp', '*.gif', '*.ico', '*.jpg', '*.png',
      \ '*.rar', '*.zip', '*.tar', '*.tar.gz', '*.tar.xz', '*.tar.bz2',
      \ '*.pdf', '*.doc', '*.docx', '*.ppt', '*.pptx',
      \ ]
