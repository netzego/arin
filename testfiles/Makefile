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

.PHONY: \
	dist_clean \
	verify \
	qemu_install

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

qemu_install: $(IMAGE) $(OVMF_IMAGE) $(OVMF_VARS) $(ISO) verify
	qemu-system-x86_64 $(QARGS) \
		-nodefaults \
		-no-user-config \
		-nographic \
		-serial mon:stdio \
		-nic user,model=virtio-net-pci \
		-smbios "type=11,value=io.systemd.stub.kernel-cmdline-extra=console=ttyS0" \
		-drive if=pflash,format=raw,unit=0,readonly=on,file=$(OVMF_IMAGE) \
		-drive if=pflash,format=raw,unit=1,readonly=off,file=$(OVMF_VARS) \
		-drive id=iso,file=$(ISO),media=cdrom,readonly=on \
		-drive id=test,file=$(IMAGE),format=raw,if=virtio

keep.img:
	truncate -s$(IMAGE_SIZE) $@
	sgdisk -Z $@
	sgdisk --new=0:0:+$(ESP_SIZE) --typecode=1:ef00 $@
	sgdisk --new=0:0:+100M --typecode=1:8304 $@
	sgdisk --new=0:0:0 --typecode=1:8304 $@
	sgdisk -p $@
	partprobe $@
	sync
