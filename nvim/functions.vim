function! Quotes()
  execute "%s/\"/\'/g"
endfunction

function! Replace(a1, a2)
  let s1 = a:a1
  let s2 = a:a2
  execute '%s/' . s1 . '/' . s2 . '/g'
endfunction

function! Fix()
  execute "ALEFix eslint"
endfunction

function! JSON()
  execute '%!python3 -m json.tool'
endfunction

function! Test()
  if &filetype == 'ruby'
    call TestRails()
  elseif &filetype == 'python'
    call TestPython()
  endif
endfunction

function! TestRails()
  let path = expand('%:r')
  let path = substitute(path, '^app', 'spec', '')
  if path[-4:-1] == 'spec'
    let path = '"./bin/rspec' . ' ' . path . '.rb"'
  else
    let path = '"./bin/rspec' . ' ' . path . '_spec.rb"'
  endif
  execute '!tmux send-keys -t 1 ' . path . ' Enter'
endfunction

function! TestPython()
  let path = split(expand('%:r'), '/')
  let is_test = path[0] == 'tests'
  if is_test
    let path = join(path, '/')
    " if we are already in a test file
    let path = '"etltest' . ' ./' . path . '.py"'
  else
    " if we are in the source file
    let path[-1] = 'test_' . path[-1]
    let path = join(path, '/')
    let path = '"etltest' . ' ./tests/' . path . '.py"'
  endif
  execute '!tmux send-keys -t 1 ' . path . ' Enter'
endfunction

function! TestLineInSpec()
  let path = expand('%:r')
  let path = substitute(path, '^app', 'spec', '')
  let lineno = line(".")
  if path[-4:-1] == 'spec'
    let path = '"./bin/rspec' . ' ' . path . '.rb:"' . lineno
  else
    let path = '"./bin/rspec' . ' ' . path . '_spec.rb:"' . lineno
  endif
  execute '!tmux send-keys -t 1 ' . path . ' Enter'
endfunction

function! MakeSpec()
  let path = expand('%:r')
  let path = substitute(path, '^app', 'spec', '')
  let path = path . '_spec.rb'
  execute '!touch ' . path
endfunction

function! ExecuteCFile()
  let path = expand('%:r')
  let cmd = '"cc' . ' ./' . path . '.c ' . '&&' . ' ./' . 'a.out"'
  execute '!tmux send-keys -t 1 ' . cmd . ' Enter'
endfunction

function! ExecuteScript()
  let path = expand('%:f')
  let prog = &filetype
  let cmd = '"' . prog .  ' ./' . path . '"'
  echo cmd
  execute '!tmux send-keys -t 1 ' . cmd . ' Enter'
endfunction

function! SendRubocop()
  let path = expand('%:r')
  let cmd = '"rubocop -A ' . ' ./' . path . '.rb"'
  execute '!tmux send-keys -t 1 ' . cmd . ' Enter'
endfunction
