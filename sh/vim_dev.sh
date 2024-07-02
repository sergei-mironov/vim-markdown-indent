#!/bin/sh

# This is a small shell wrapper which adds vim-markdown-indent plugin from the current
# repository to the VIM's runtime path.

set +e

if ! test -f "$REPO_ROOT/ftplugin/markdown.vim" ; then
  echo "'ftplugin/markdown.vim' is not in the REPO_ROOT ($REPO_ROOT)." >&2
  exit 1
fi
vim -c "
if exists('g:loaded_vim_markdown_indent')
  unlet g:loaded_vim_markdown_indent
endif
let &runtimepath = '$REPO_ROOT,'.&runtimepath
" "$@"

exit 0


