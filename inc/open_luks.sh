#!/usr/bin/env bash

function open_luks() {
    declare -r device="${1:-${LUKS_PATH}}"
    declare -r keyfile="${2:-${KEYFILE}}"
    declare -r mapname="${3:-${MAPNAME}}"

    if [[ "$(lsblk -rno FSTYPE "${device}")" == "crypto_LUKS" ]]; then
        cryptsetup \
            --verbose \
            --key-file "${keyfile}" \
            open "${device}" "${mapname}"
    else
        err 3 "TODO ..."
    fi
}
