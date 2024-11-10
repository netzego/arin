#!/usr/bin/env bash

function copy_sshkeys() {
    declare -r pubkey="${1:-${SCRIPTDIR}/arin.pubkey}"
    declare -r rootfs="${2:-${MOUNTPOINT}}"

    if [[ -f "${pubkey}" ]]; then
        cp -v "${pubkey}" "${rootfs}/root/.ssh/authorized_keys"
    fi
}
