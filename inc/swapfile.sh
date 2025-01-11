#!/usr/bin/env bash

function swapfile() {
    declare -r swapfile="${1:-${WORKDIR}/mnt/swap/swapfile}"
    declare -r size="${2:-${SIZE_SWAPFILE}}"
    declare -r dir="$(dirname "${swapfile}")"

    # check if dirname of swapfile is a) mountpoint and b) a btrfs subvolume
    if [[ ! -d "${dir}" ]]; then
        err 30 "'${dir}' is not a directory"
    fi

    if ! mountpoint -q "${dir}"; then
        err 31 "'${dir}' is not a mountpoint."
    fi

    # check if $dir is a btrfs subvol
    # https://stackoverflow.com/a/32865333
    if [[ "$(stat --format=%i ${dir})" -ne 256 ]]; then
        err 32 "'${dir}' is not a btrfs subvolume."
    fi

    btrfs -v filesystem mkswapfile --size "${size}" "${swapfile}"
}
