VIM = $(shell find -name '*\.vim')
VERSION = $(shell ex +"source indent/markdown.vim | redir>>/dev/stdout | echon g:vim_markdown_indent_version | redir END" -scq!)
TARGZ = _dist/vim-markdown-indent-$(VERSION).tar.gz

.PHONY: all
all: pack

.PHONY: pack
pack: $(TARGZ)

$(TARGZ): $(VIM)
	mkdir -p $$(dirname $(TARGZ)) || true
	tar -czvf $@ indent

.PHONY: targets
targets:
	@echo VIM = $(VIM)
	@echo VERSION = $(VERSION)
	@echo TARGZ = $(TARGZ)
