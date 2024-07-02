#!/bin/sh

set -e -x

mktest() {
  rm -rf "$1" || true
  mkdir "$1"
  cd "$1"
}

test_1() {(
mktest "_test_1"

cat >input.md <<EOF
* list
  - list
    + list
EOF

vim_dev.sh -n >_vim.log 2>&1 <<"EOF"
:e! input.md
1G
:execute "normal o* new\<Esc>"
:w output1a.md

:e! input.md
1G
:execute "normal onew\<Esc>"
:w output1b.md

:e! input.md
2G
:execute "normal o- new\<Esc>"
:w output2a.md

:e! input.md
2G
:execute "normal onew\<Esc>"
:w output2b.md

:e! input.md
3G
:execute "normal o+ new\<Esc>"
:w output3a.md

:e! input.md
3G
:execute "normal onew\<Esc>"
:w output3b.md
EOF

diff -u output1a.md - <<EOF
* list
* new
  - list
    + list
EOF

diff -u output1b.md - <<EOF
* list
  new
  - list
    + list
EOF

diff -u output2a.md - <<EOF
* list
  - list
  - new
    + list
EOF

diff -u output2b.md - <<EOF
* list
  - list
    new
    + list
EOF

diff -u output3a.md - <<EOF
* list
  - list
    + list
    + new
EOF

diff -u output3b.md - <<EOF
* list
  - list
    + list
      new
EOF

)}

test_2() {(
mktest "_test_2"

cat >input.md <<EOF
* list


EOF

vim_dev.sh -n >_vim.log 2>&1 <<"EOF"
:redir > _vim_messages.log
:e! input.md
2G
:execute "normal onew\<Esc>"
:w output1.md

:e! input.md
3G
:execute "normal onew\<Esc>"
:w output2.md
EOF

diff -u output1.md - <<EOF
* list

  new

EOF

diff -u output2.md - <<EOF
* list


new
EOF

)}

test_3() {(
mktest "_test_3"

cat >input.md <<EOF
1. item
2. item
EOF

vim_dev.sh -n >_vim.log 2>&1 <<"EOF"
:redir > _vim_messages.log
:e! input.md
2G
:execute "normal onew\<Esc>"
:w output1.md

:e! input.md
2G
:execute "normal o1. new\<Esc>"
:w output2.md

:e! input.md
2G
:execute "normal o3. new\<Esc>"
:w output3.md
EOF

diff -u output1.md - <<EOF
1. item
2. item
   new
EOF

diff -u output2.md - <<EOF
1. item
2. item
   1. new
EOF

diff -u output3.md - <<EOF
1. item
2. item
3. new
EOF

)}

test_debug() {(
mktest "_test_debug"

cat >input.md <<EOF
* list
  - list
    + list
EOF

vim_dev.sh -n >_vim.log 2>&1 <<"EOF"
:redir > _vim_messages.log
:e! input.md
2G
:execute "normal onew\<Esc>"
:w output.md
EOF

)}

# :execute "normal o" . string(g:foooooo) . "\<Esc>"

export REPO_ROOT=`pwd`
export PATH="$REPO_ROOT/sh:$PATH"
test_1
test_2
test_3
echo OK
