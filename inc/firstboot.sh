#!/usr/bin/env bash
# shellcheck disable=2153,2154

firstboot() {
    declare -r rootfs="${MOUNTDIR}"
    declare -r locale="${LOCALE}"
    declare -r timezone="${TIMEZONE}"
    declare -r keymap="${KEYMAP}"
    declare -r shell="${DEFAULT_SHELL}"
    declare -r hash="$(cat ${SCRIPTDIR}/arin.roothash)"
    # declare -r cmdline="rd.luks.name=${luks_uuid}=root root=UUID=${root_uuid} rw ${CMDLINE_EXTRA}"
    if [[ ! -f "${SCRIPTDIR}/arin.roothash" ]]; then
        err 3 "\`arin.roothash' does not exists"
    fi

    systemd-firstboot \
        --force \
        --root="${rootfs}" \
        --root-password-hashed="${hash}" \
        --locale="${locale}" \
        --root-shell="${shell}" \
        --timezone="${timezone}" \
        --keymap="${keymap}"
    # --hostname="${hostname}" \
}
