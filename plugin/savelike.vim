command! -nargs=1 -complete=customlist,<SID>CommandCompletion -bang SaveLike :call <SID>SaveLike(<f-args>, "<bang>")

" Return a path relative to the current buffer's path
function! s:SaveLike(path, bang)
  let new_path = tlib#file#Join(tlib#file#Split(s:BufferPath()) + [a:path])

  if a:bang ==# '!'
    execute "saveas! " . new_path
  else
    execute "saveas " . new_path
  endif
endfunction

" Return the path of the current buffer
function! s:BufferPath()
  return tlib#file#Join(tlib#file#Split(@%)[:-2])
endfunction

" returns a completion list
function! s:CommandCompletion(arg_lead, cmd_line, cursor_pos)
  let buffer_path = s:BufferPath()
  let paths = split(globpath(buffer_path, a:arg_lead . '*'), "\n")
  call map(paths, "tlib#file#Relative(v:val, buffer_path)")
  return paths
endfunction

" TODO: maybe this command should be called :saverel ?
