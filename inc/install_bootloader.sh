#!/usr/bin/env bash

function install_bootloader() {
    # --no-variables
    # --random-seed=no
    # --install-source=image
    declare -r rootfs="${1:-${MOUNTDIR}}"
    bootctl --root="${rootfs}" --esp-path=/efi --install-source=image --random-seed=no install
    bootctl --root="${rootfs}" status
    bootctl --root="${rootfs}" list
}
