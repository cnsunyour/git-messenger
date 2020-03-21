.PHONY : clean distclean lint test version

EMACS ?= emacs
CASK ?= cask

LOADPATH = -L .

ELPA_DIR = $(shell EMACS=$(EMACS) $(CASK) package-directory)
AUTOLOADS = $(wildcard *-autoloads.el*)
ELS = $(filter-out $(AUTOLOADS),$(wildcard *.el))
OBJECTS = $(ELS:.el=.elc)
BACKUPS = $(ELS:.el=.el~)

version: elpa
	$(CASK) exec $(EMACS) --version

lint: elpa
	$(CASK) exec $(EMACS) -Q --batch \
	    --exec "(require 'package)" \
	    --exec "(add-to-list 'package-archives '(\"gnu\" . \"https://elpa.gnu.org/packages\") t)" \
	    --exec "(add-to-list 'package-archives '(\"melpa\" . \"https://melpa.org/packages\") t)" \
	    --exec "(package-initialize)" \
	    --exec "(require 'elisp-lint)" \
	    -f elisp-lint-files-batch \
	    --no-checkdoc \
	    --no-package-lint \
	    $(ELS)

test: elpa
	$(CASK) exec $(EMACS) -Q -batch $(LOADPATH) \
		-l test/test.el \
		-f ert-run-tests-batch-and-exit

elpa: $(ELPA_DIR)
$(ELPA_DIR): Cask
	$(CASK) install
	touch $@

clean:
	rm -rf $(OBJECTS) $(BACKUPS) $(AUTOLOADS)

distclean:
	rm -rf .cask
