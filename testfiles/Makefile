SHELL       := bash
.SHELLFLAGS := -eu -o pipefail -c
MAKEFLAGS   += --warn-undefined-variables
MAKEFLAGS   += --no-builtin-rules
OVMF_IMAGE  := OVMF_CODE.4m.fd
OVMF_VARS   := OVMF_VARS.4m.fd
ISO         := archlinux-x86_64.iso
IMAGE       ?= test.img
IMAGE_SIZE  := 4G
QARGS       := -M q35 -enable-kvm -cpu host -m 4G -smp 4 -nodefaults -no-user-config

$(IMAGE):
	truncate -s$(IMAGE_SIZE) $@

null.img:
	touch $@

empty.img:
	truncate -s1G $@

$(IMAGE):
	truncate -s$(IMAGE_SIZE) $@

$(ISO):
	curl -LO https://geo.mirror.pkgbuild.com/iso/latest/$@
	curl -LO https://geo.mirror.pkgbuild.com/iso/latest/$@.sig

verify: $(ISO)
	gpg --keyserver-options auto-key-retrieve --verify $<.sig $<

$(OVMF_IMAGE):
	cp /usr/share/edk2-ovmf/x64/$@ .

$(OVMF_VARS):
	cp /usr/share/edk2-ovmf/x64/$@ .

dist_clean:
	rm -fr $(IMAGE)
	rm -fr $(OVMF_IMAGE)
	rm -fr $(OVMF_VARS)
	rm -fr $(ISO)
	rm -fr $(ISO).sig
	qemu-system-x86_64 $(QARGS) \
		-device bochs-display \
		-drive if=pflash,format=raw,unit=0,readonly=on,file=$(OVMF_IMAGE) \
		-drive if=pflash,format=raw,unit=1,readonly=off,file=$(OVMF_VARS) \
		-drive id=iso,file=$(ISO),media=cdrom,readonly=on \
		-drive id=test,file=$(IMAGE),format=raw,if=virtio

boot: $(OVMF_IMAGE) $(OVMF_VARS) $(ISO)
	qemu-system-x86_64 $(QARGS) \
		-device bochs-display \
		-drive if=pflash,format=raw,unit=0,readonly=on,file=$(OVMF_IMAGE) \
		-drive if=pflash,format=raw,unit=1,readonly=off,file=$(OVMF_VARS) \
		-drive id=test,file=$(IMAGE),format=raw,if=virtio

nogra: $(OVMF_IMAGE) $(OVMF_VARS) $(ISO)
	qemu-system-x86_64 $(QARGS) \
		-nographic \
		-serial mon:stdio \
		-drive if=pflash,format=raw,unit=0,readonly=on,file=$(OVMF_IMAGE) \
		-drive if=pflash,format=raw,unit=1,readonly=off,file=$(OVMF_VARS) \
		-drive id=test,file=$(IMAGE),format=raw,if=virtio

.PHONY: \
	boot \
	nogra \
	verify \
	install
