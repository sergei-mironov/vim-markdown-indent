if exists("g:loaded_vim_markdown_indent")
  finish
endif

let g:vim_markdown_indent_version = '1.0.0'
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
  let m=matchstr(line,'^ *')
  let r = {'t':'text', 'i':len(m)}
  return r
endfun


fun! MarkdownMatchDeep(start_lnum, m_initial, depth)
  let m = a:m_initial
  if a:start_lnum<=0
    return m
  endif
  let i = a:start_lnum
  let num_empty = 0
  while i>0 && (a:start_lnum-i)<a:depth
    let pline = getline(i)
    if len(pline)==0
      let num_empty = num_empty + 1
    endif
    if num_empty >= g:vim_markdown_num_empty_to_reset
      return m
    endif
    let m2 = MarkdownMatch(pline)
    if m2.t != 'text' " || m2.i != m.i
      return m2
    endif
    let i = i-1
  endwhile
  return m
endfun


fun! MarkdownIndent(lnum) abort
  let l:curr_line = getline(a:lnum)
  let l:prev_lnum = a:lnum - 1
  if l:prev_lnum <= 0 | return -1 | endif
  let l:prev_line = getline(l:prev_lnum)
  let cm=MarkdownMatch(l:curr_line)
  let pm=MarkdownMatchDeep(l:prev_lnum, cm, g:vim_markdown_indent_depth)
  if pm.t=='list' && cm.t=='list'
    if pm.bullet == cm.bullet
      return pm.pi
    else
      return cm.pi
    endif
  elseif (pm.t=='list' || pm.t=='enum') && cm.t=='text'
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
  elseif pm.t=='text' && cm.t=='enum'
    return pm.i - (cm.i - cm.pi)
  endif
  return -1
endfun

fun GetMarkdownIndent()
  return MarkdownIndent(v:lnum)
endfun

setlocal indentexpr=GetMarkdownIndent()
setlocal indentkeys=!^F,=\ ,o,O,=\*\ ,=\-\ ,=\+\ 
let b:did_indent = 1 " To prevent vim-markdown from loading its indent
let g:loaded_vim_markdown_indent = 1

