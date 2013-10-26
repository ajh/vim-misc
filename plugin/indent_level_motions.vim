if exists('g:loaded_misc_indent_level_motions')
  finish
endif
let g:loaded_misc_indent_level_motions = 1

function! s:CursorIndentLevel()
  let unsaved = @"
  normal! yy
  let spaces_count = matchend(@", '\v^\s+')
  let @" = unsaved
  return spaces_count / shiftwidth()
endfunction

" Move cursor to a line at another indent level.
"
" is_forward - can be true to search forward, false to search backward
"
" less_more_or_either -  'less' searching for a line with less indenting,
" 'more' for a line with more indenting, or 'either' for a line with a
" different indent level than the current line.
"
" TODO: what happens when 'more' search fails? ignore?
function! s:IndentMotion(less_more_or_either, is_forward)
  let cursor_level = s:CursorIndentLevel()

  if a:less_more_or_either == 'less' || a:less_more_or_either == 'more'
    if a:less_more_or_either == 'less'
      let regex_range = '{,' . max([cursor_level - 1, 0]) * shiftwidth() . '}'
    elseif a:less_more_or_either == 'more'
      let regex_range = '{' . (cursor_level + 1) * shiftwidth() . ',}'
    end

    let pattern = '(^\s' . regex_range . '\S)'

  elseif a:less_more_or_either == 'either'
    if cursor_level == 0
      let pattern = '(^\s{' . shiftwidth() . ',}\S)'
    else
      let spaces_count = cursor_level * shiftwidth()
      let pattern = '(^\s{,' . (spaces_count - 1) .  '}\S)|(^\s{' . (spaces_count + 1) . ',}\S)'
    end
  end

  echom pattern

  let old_search = @/
  execute "normal! " . (a:is_forward ? '/' : '?') . '\v' . pattern . "\<CR>^"
  let @/ = old_search
endfunction

nnoremap [call :i <SID>IndentMotion('less', 0)<CR>
nnoremap ]i :call <SID>IndentMotion('less', 1)<CR>
nnoremap [I :call <SID>IndentMotion('more', 0)<CR>
nnoremap ]I :call <SID>IndentMotion('more', 1)<CR>
