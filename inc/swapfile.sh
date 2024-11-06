#!/usr/bin/env bash

function swapfile() {
    declare -r swapfile="${1:-${WORKDIR}/mnt/swap/swapfile}"
    declare -r size="${2:-${SIZE_SWAPFILE}}"
    declare -r swapdir="$(dirname "${swapfile}")"

    if [[ ! -d "${swapdir}" ]]; then
        err 3 "\`${swapdir}' is not a directory"
    fi

    btrfs -v filesystem mkswapfile --size "${size}" "${swapfile}"
}
