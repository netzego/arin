#!/usr/bin/env bash
# shellcheck disable=2154

function configure_initrd() {
    declare -r rootfs="${1:-${MOUNTDIR}}"
    declare -r hooks=(
        base
        systemd
        autodetect
        modconf
        kms
        keyboard
        sd-vconsole
        block
        sd-encrypt
        filesystems
        fsck
    )

    log "\$HOOKS" "${hooks[*]}"

    # configure HOOKS array to boot an luks encrypted rootfs
    sed -i "s%^HOOKS=.*$%HOOKS=(${hooks[*]})%" "${rootfs}/etc/mkinitcpio.conf"

    # MODULES=(virtio virtio_blk virtio_pci virtio_net)
    sed -i "s%^MODULES=.*$%MODULES=(virtio virtio_blk virtio_pci virtio_net)%" "${rootfs}/etc/mkinitcpio.conf"

    # logs the HOOKS array
    grep "^HOOKS=" "${rootfs}/etc/mkinitcpio.conf"

    # Enable the unified lernel image generation. this simplifies greatly
    # the boot hassle.
    sed -i 's@^#default_uki@default_uki@' "${rootfs}/etc/mkinitcpio.d/linux-lts.preset"

    # comment out fallback image, this got me into trouble on a machine with
    # few ram (2G). mkinitcpio do not finished on this machine. TODO: find a
    # way to maintain this inside the prefix. Probably via a direct call to
    # minitcpio without the -p or -P parameter. see mkinicpio(8).
    #sed -i 's%^fallback%#fallback%' "${rootfs}/etc/mkinitcpio.d/linux-lts.preset"

    # logs the .preset file
    cat "${rootfs}/etc/mkinitcpio.d/linux-lts.preset"
}
