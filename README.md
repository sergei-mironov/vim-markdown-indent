Vim-markdown-indent
===================

A vim plugin to setup the indent expression for the Markdown files in Vim, and
that is it.

``` markdown
1. Numbered list, press enter ...
   . `<--` cursor goes here.
2. Press enter and then continue the list by typing `3. ` ...
3. The plugin adjusts the indentation by shifting the line to the left.
   1. But if we type `1.` the plugin would treat it as a nested list.
   2. So we can continue.

* The same works for itemized lists. Typing `*` in the next line instructs
  plugin to shift the line to the left.
* But typing the list bullet other than the current one, say `-`, ...
  - makes a nested list start.
  - All the above works for
    multi
    line
  - list items

```


References
----------

* [vim-kramdown-tab](https://github.com/mzlogin/vim-kramdown-tab)
