#!/usr/bin/env bash
# shellcheck disable=2153,2154

firstboot() {
    declare -r rootfs="${MOUNTDIR}"
    declare -r locale="${LOCALE}"
    declare -r timezone="${TIMEZONE}"
    declare -r hostname="${NODENAME}"
    declare -r keymap="${KEYMAP}"
    declare -r shell="${DEFAULT_SHELL}"
    declare -r hashfile="${SCRIPTDIR}/arin.roothash"
    # declare -r cmdline="rd.luks.name=${luks_uuid}=root root=UUID=${root_uuid} rw ${CMDLINE_EXTRA}"

    if [[ ! -f "${hashfile}" ]]; then
        err 3 "\`${hashfile}' does not exists"
    fi

    systemd-firstboot \
        --force \
        --root "${rootfs}" \
        --root-password-hashed="$(cat "${hashfile}")" \
        --locale="${locale}" \
        --root-shell="${shell}" \
        --timezone="${timezone}" \
        --hostname="${hostname}" \
        --keymap="${keymap}"
}
