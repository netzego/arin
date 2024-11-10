SHELL          := bash
.SHELLFLAGS    := -eu -o pipefail -c
MAKEFLAGS      += --warn-undefined-variables
MAKEFLAGS      += --no-builtin-rules

OVMF_IMAGE := OVMF_CODE.4m.fd
OVMF_VARS := OVMF_VARS.4m.fd
ISO := archlinux-x86_64.iso

IMAGE      := test.img
TESTIMAGE_SIZE := 4G

IMAGE_SIZE        := 1G
ESP_SIZE          := 32M
ROOT_SIZE         := 0
WIN_DATE_SIZE     := 6400M
WIN_RESUCE_SIZE   := 512M
WIN_RESERVED_SIZE := 1M

$(IMAGE):
	truncate -s$(TESTIMAGE_SIZE) $@

null.img:
	touch $@

empty.img:
	truncate -s1G $@

keep.img:
	truncate -s$(IMAGE_SIZE) $@
	sgdisk -Z $@
	sgdisk --new=0:0:+$(ESP_SIZE) --typecode=1:ef00 $@
	sgdisk --new=0:0:+100M --typecode=1:8304 $@
	sgdisk --new=0:0:0 --typecode=1:8304 $@
	sgdisk -p $@
	partprobe $@
	sync

$(ISO):
	curl -LO https://geo.mirror.pkgbuild.com/iso/latest/$@
	curl -LO https://geo.mirror.pkgbuild.com/iso/latest/$@.sig

verify:
	gpg \
		--keyserver-options auto-key-retrieve \
		--verify $(ISO).sig $(ISO)

$(OVMF_IMAGE):
	cp /usr/share/edk2-ovmf/x64/$@ .

$(OVMF_VARS):
	cp /usr/share/edk2-ovmf/x64/$@ .

qemu-install: $(OVMF_IMAGE) $(OVMF_VARS) $(ISO)
	qemu-system-x86_64 \
		-M q35 \
		-enable-kvm \
		-cpu host \
		-m 4G \
		-smp 4 \
		-nodefaults \
		-no-user-config \
		-device bochs-display \
		-drive if=pflash,format=raw,unit=0,readonly=on,file=$(OVMF_IMAGE) \
		-drive if=pflash,format=raw,unit=1,readonly=off,file=$(OVMF_VARS) \
		-drive id=iso,file=$(ISO),media=cdrom,readonly=on \
		-drive id=test,file=$(IMAGE),format=raw,if=virtio \
		-virtfs local,path=./test,mount_tag=host0,security_model=passthrough,readonly=on
	# -nographic \
	# -serial stdio \

.PHONY: \
	verify \
	qemu-install
