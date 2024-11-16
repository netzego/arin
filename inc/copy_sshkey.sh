#!/usr/bin/env bash

function copy_sshkey() {
    declare -r pubkey="${1:-${SCRIPTDIR}/arin.sshkey}"
    declare -r rootfs="${2:-${MOUNTDIR}}"

    if [[ -f "${pubkey}" ]]; then
        cp -v "${pubkey}" "${rootfs}/root/.ssh/authorized_keys"
    fi
}
