#!/usr/bin/env bash

function install_bootloader() {
    declare -r rootfs="${1:-${MOUNTDIR}}"

    # this complains about
    # bootctl --root "${rootfs}" --esp-path=/efi --boot-path=/boot --install-source=image install
    bootctl --root "${rootfs}" --esp-path=/efi --boot-path=/boot install

    # systemd-nspawn -D "${rootfs}" bootctl --esp-path=/efi --boot-path=/boot install
    systemd-nspawn -D "${rootfs}" bootctl status
    systemd-nspawn -D "${rootfs}" bootctl list
}
