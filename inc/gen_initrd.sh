#!/usr/bin/env bash
# shellcheck disable=2154

function gen_initrd() {
    local rootfs="${1:-$MOUNTDIR}"
    local preset="${rootfs}/etc/mkinitcpio.d/linux-lts.preset"

    # TODO: do not use the -p or -P option. see: configure_initrd.bash.
    # BUG: this breaks on live environment with low ram configuration
    # systemd-nspawn -D "${rootfs}" \
    #     mkinitcpio --nocolor --verbose -p linux-lts

    if [[ ! -f "${preset}" ]]; then
        err 3 "\`${preset}' does not exists"
    fi

    # to run mkinitcpio without the -p or -P flag. we need some information
    # of the kernel version and locations (uki, vmlinuz and initrd) we about
    # to install. we can gather all from the /etc/mkinitcpio.d/*.preset
    # file. which is a bash
    source "${preset}"

    systemd-nspawn -D "${rootfs}" \
        mkinitcpio \
        --nocolor \
        --uki "${default_uki}" \
        --kernel "${ALL_kver}" \
        --kernelimage "${ALL_kver}"
}
