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

image: $(SCRIPTNAME) $(IMAGE)
	bash $< $(IMAGE) |& tee -p $(LOGFILE)

image_debug: $(SCRIPTNAME) $(IMAGE)
	bash -x $< $(IMAGE) |& tee -p $(LOGFILE)

.FORCE:

$(IMAGE):
	truncate -s4G $@

arin.roothash: .FORCE
	@mkpasswd -m yescrypt >$@
	@chmod 400 $@

arin.keyfile: .FORCE
	@systemd-ask-password -n >$@
	@chmod 400 $@
