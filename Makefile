SHELL        := bash
.SHELLFLAGS  := -eu -o pipefail -c
MAKEFLAGS    += --warn-undefined-variables
MAKEFLAGS    += --no-builtin-rules
SCRIPTNAME   := arin.sh
BATS_OPTIONS := --verbose-run --show-output-of-passing-tests
BATS_GLOB    ?=
LOGFILE	     ?= logfile
IMAGE        ?= testfiles/test.img

.PHONY: \
	check \
	image \
	image_debug \
	test

check: $(SCRIPTNAME)
	shellcheck -x --enable=all $<

test: tests/
	@bats $(BATS_OPTIONS) -r tests/$(BATS_GLOB)

run: $(SCRIPTNAME)
	bash $< $(IMAGE) |& tee -p $(LOGFILE)

debug: $(SCRIPTNAME)
	bash -x $< $(IMAGE) |& tee -p $(LOGFILE)

arin.roothash:
	@mkpasswd -m yescrypt >$@
