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
