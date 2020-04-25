" fzf
set rtp+=/usr/local/opt/fzf
nnoremap F :FZF<CR>
nnoremap <C-p> :FZF<CR>
" NerdTree
autocmd StdinReadPre * let s:std_in=1

" Open NERDTREE when vim opens
" autocmd vimenter * if @% !~# '.vimrc' && @% !~# '.tmux.conf' && @% !~# '.bash_profile' && @% !~# '.bashrc' && @% !~# '.eslintrc.json' && @% !~# '.todo'| NERDTree | endif

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
nnoremap \ :Ag<SPACE>
" bind K to grep word under cursor
nnoremap K :grep! "\b<C-R><C-W>\b"<CR>:cw<CR>

" ale
let g:ale_linters = {
      \ 'javascript': ['eslint'],
      \ 'vue': ['eslint'],
      \ }

" ultisnips
let g:UltiSnipsExpandTrigger="<c-b>"
let g:UltiSnipsJumpForwardTrigger="<c-b>"
let g:UltiSnipsJumpBackwardTrigger="<c-z>"

" deoplete
let g:deoplete#enable_at_startup = 0 " disabled for now; migrating to coc
inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

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
"   install language server: `npm i -g vue-language-server`
"   This should create a symlink for /usr/local/bin/vls
let g:LanguageClient_serverCommands = {
    \ 'ruby': ['~/.rvm/gems/ruby-2.5.1/bin/solargraph', 'stdio'],
    \ 'javascript': ['javascript-typescript-stdio'],
    \ 'vue': ['vls']
    \ }

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
