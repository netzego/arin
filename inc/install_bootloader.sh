#!/usr/bin/env bash

function install_bootloader() {
    # - this needs tyo run after umounting and close the root and luks parts
    # - we have to enter the encryption password ...
    # bootctl --image="${VOLUME}" --esp-path=/efi --install-source=image install

    # efibootmgr --create --disk "${VOLUME}" --part 1 --loader '\EFI\systemd\systemd-bootx64.efi' --label "Linux Boot Manager" --unicode

    declare -r rootfs="${1:-${MOUNTDIR}}"
    bootctl --root="${rootfs}" --esp-path=/efi --install-source=image install

    # systemd-nspawn -D "${rootfs}" bootctl status
    # systemd-nspawn -D "${rootfs}" bootctl list
}
