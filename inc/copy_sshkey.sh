#!/usr/bin/env bash

function copy_sshkey() {
    declare -r pubkey="${1:-${SCRIPTDIR}/arin.authorized_keys}"
    declare -r rootfs="${2:-${MOUNTDIR}}"

    # TODO: set owner and file permissions
    if [[ -f "${pubkey}" ]]; then
        cp -v "${pubkey}" "${rootfs}/root/.ssh/authorized_keys"
    fi
}
