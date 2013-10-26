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

nnoremap [i :call <SID>IndentMotion('less', 0)<CR>
nnoremap ]i :call <SID>IndentMotion('less', 1)<CR>
nnoremap [I :call <SID>IndentMotion('more', 0)<CR>
nnoremap ]I :call <SID>IndentMotion('more', 1)<CR>

" found this here: http://vim.wikia.com/wiki/Move_to_next/previous_line_with_same_indentation

" Jump to the next or previous line that has the same level or a lower
" level of indentation than the current line.
"
" exclusive (bool): true: Motion is exclusive
" false: Motion is inclusive
" fwd (bool): true: Go to next line
" false: Go to previous line
" lowerlevel (bool): true: Go to line with lower indentation level
" false: Go to line with the same indentation level
" skipblanks (bool): true: Skip blank lines
" false: Don't skip blank lines
function! NextIndent(exclusive, fwd, lowerlevel, skipblanks)
  let line = line('.')
  let column = col('.')
  let lastline = line('$')
  let indent = indent(line)
  let stepvalue = a:fwd ? 1 : -1
  while (line > 0 && line <= lastline)
    let line = line + stepvalue
    if ( ! a:lowerlevel && indent(line) == indent ||
          \ a:lowerlevel && indent(line) < indent)
      if (! a:skipblanks || strlen(getline(line)) > 0)
        if (a:exclusive)
          let line = line - stepvalue
        endif
        exe line
        exe "normal " column . "|"
        return
      endif
    endif
  endwhile
endfunction

" Moving back and forth between lines of same or lower indentation.
nnoremap <silent> [l :call NextIndent(0, 0, 0, 1)<CR>
nnoremap <silent> ]l :call NextIndent(0, 1, 0, 1)<CR>
nnoremap <silent> [L :call NextIndent(0, 0, 1, 1)<CR>
nnoremap <silent> ]L :call NextIndent(0, 1, 1, 1)<CR>
vnoremap <silent> [l <Esc>:call NextIndent(0, 0, 0, 1)<CR>m'gv''
vnoremap <silent> ]l <Esc>:call NextIndent(0, 1, 0, 1)<CR>m'gv''
vnoremap <silent> [L <Esc>:call NextIndent(0, 0, 1, 1)<CR>m'gv''
vnoremap <silent> ]L <Esc>:call NextIndent(0, 1, 1, 1)<CR>m'gv''
onoremap <silent> [l :call NextIndent(0, 0, 0, 1)<CR>
onoremap <silent> ]l :call NextIndent(0, 1, 0, 1)<CR>
onoremap <silent> [L :call NextIndent(1, 0, 1, 1)<CR>
onoremap <silent> ]L :call NextIndent(1, 1, 1, 1)<CR>
