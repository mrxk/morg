set isfname+=32
autocmd BufEnter * syntax on | set ft=markdown
imap <c-x><c-f> <c-r>=fzf#vim#complete#path("find . -path '*/\.*' -prune -o -type f -print -o -type l -print \| sed 's:^..::'",{'options': ['--layout=reverse','--info=hidden','--preview', 'mdless {}']})<cr>

function! HandleFZF(file)
    let l:file = substitute(a:file, '\\', '', 'g')
    execute('silent normal i[['.l:file.']]')
endfunction
command! -nargs=1 HandleFZF :call HandleFZF(<f-args>)
nnoremap <silent> gl :call fzf#run({'sink':'HandleFZF', 'options': ['--layout=reverse','--info=hidden','--preview', 'mdless {}']})<cr>

nnoremap <silent> gf :call <sid>open_file_or_create_new()<CR>
function! s:open_file_or_create_new() abort
  let l:path = expand('<cfile>')
  if empty(l:path)
    return
  endif
  execute('silent !rm -f /tmp/RELINK')
  let l:path = trim(l:path)
  if filereadable(l:path)
    let l:newtitle = execute('silent !/app/morg.sh edit "'.l:path.'"')
    execute('silent redraw!')
  else
    execute('silent !/app/morg.sh create "'.l:path.'"')
    execute('silent redraw!')
  endif
  if filereadable('/tmp/RELINK')
     let l:lines = readfile('/tmp/RELINK')
     execute('silent %s/\[\[ *'.l:path.' *\]\]/\[\['.l:lines[0].'\]\]/g')
  endif
endfunction
