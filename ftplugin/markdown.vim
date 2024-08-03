if exists("g:loaded_vim_markdown_indent")
  finish
endif

let g:vim_markdown_indent_version = '1.1.0'
let g:vim_markdown_indent_depth = 100
let g:vim_markdown_num_empty_to_reset = 2


fun! MarkdownMatch(line)
  let line = a:line
  let m=matchstr(line,'^ *[-+*] ')
  if len(m)>0
    let r = {'t':'list', 'bullet':m[-2:-1], 'i':len(m), 'pi':len(m)-2}
    return  r
  endif
  let m=matchstr(line,'^ *[0-9]\+\. ')
  if len(m)>0
    let npos = match(m,'[0-9]\+')
    let num = str2nr(m[npos:len(m)-1])
    let r = {'t':'enum', 'number':num, 'i':len(m), 'pi':npos}
    return r
  endif
  if len(line)==0
    let r = {'t':'empty', 'i':0}
  else
    let m = matchstr(line,'^ *')
    let r = {'t':'text', 'i':len(m)}
  endif
  return r
endfun

fun! MarkdownMatchDeep(start_lnum, depth)
  let i = a:start_lnum
  let pline = getline(i)
  " echomsg 'deep-scanning line ' . string(i) . ': '.pline
  let m = MarkdownMatch(pline)
  " echomsg '             m  ' . string(m)
  if ! (m.t == 'text' || m.t == 'empty')
    return m
  endif
  let num_empty = 0
  let i = i - 1
  while i>0 && (a:start_lnum-i)<a:depth
    let pline = getline(i)
    " echomsg 'deep-scanning line ' . string(i) . ': '.pline
    let m2 = MarkdownMatch(pline)
    " echomsg '             m2 ' . string(m2)
    if m2.t == 'empty'
      " Empty line
      let num_empty = num_empty + 1
      if num_empty >= g:vim_markdown_num_empty_to_reset - 1
        return m " Too many empty lines
      endif
    else
      " Non-empty line
      let num_empty = 0
      if m.t == 'empty'
        " But initial line was empty
        let m = m2
      endif
      " Found text
      if m.t == 'text' && m2.t == 'text' && m2.i < m.i
        let m = m2
      endif
      " Found non-text
      if m2.t != 'text'
        if m2.i <= m.i
          " Enum dominates text
          return m2
        else
          " Text dominates enum
          return m
        endif
      endif
    endif
    let i = i - 1
  endwhile
  return m
endfun


fun! MarkdownIndent(lnum) abort
  let l:curr_line = getline(a:lnum)
  let l:prev_lnum = a:lnum - 1
  if l:prev_lnum <= 0 | return -1 | endif
  let l:prev_line = getline(l:prev_lnum)
  let pm=MarkdownMatchDeep(l:prev_lnum, g:vim_markdown_indent_depth)
  " echomsg pm
  let cm=MarkdownMatch(l:curr_line)
  " echomsg cm
  if pm.t=='list' && cm.t=='list'
    if pm.bullet == cm.bullet
      return pm.pi
    else
      return cm.pi
    endif
  elseif (pm.t=='list' || pm.t=='enum') && (cm.t=='text' || cm.t=='empty')
    if len(l:curr_line)>0 && (l:curr_line[0]=='#')
      return -1
    else
      return pm.i
    endif
  elseif pm.t=='enum' && cm.t=='enum'
    if cm.number != '1'
      return pm.pi
    else
      return cm.pi
    endif
  elseif (pm.t=='text' || pm.t=='empty') && cm.t=='enum'
    return pm.i - (cm.i - cm.pi)
  endif
  return -1
endfun

fun! GetMarkdownIndent()
  return MarkdownIndent(v:lnum)
endfun

setlocal indentexpr=GetMarkdownIndent()
setlocal indentkeys=!^F,=\ ,o,O,=\*\ ,=\-\ ,=\+\ 
let b:did_indent = 1 " To prevent vim-markdown from loading its indent
let g:loaded_vim_markdown_indent = 1

