#!/usr/bin/env bash

function install_bootloader() {
    declare -r rootfs="${1:-${MOUNTDIR}}"

    bootctl --root "${rootfs}" --esp-path=/efi --install-source=image install

    systemd-nspawn -D "${rootfs}" bootctl list
}
