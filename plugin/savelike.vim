command! -nargs=1 -complete=file SaveLike :echom <SID>SaveLike(@%, <f-args>)

function! s:SaveLike(relative_to_path, new_path)
  return tlib#file#Join(tlib#file#Split(a:relative_to_path)[:-2] + [a:new_path])
endfunction
