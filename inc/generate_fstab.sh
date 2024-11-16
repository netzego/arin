#!/usr/bin/env bash
# shellcheck disable=SC2154,SC2312

function generate_fstab() {
    declare -r mountpoint="$(realpath "${1:-"${MOUNTDIR}"}")"

    grep "${mountpoint}" /proc/mounts |
        sed "s@${mountpoint}/*@/@" |
        sed "s@${ROOT_PATH}@UUID=${UUID_ROOT}@" |
        sed "s@${ESP_PATH}@UUID=${UUID_ESP}@" |
        sed "s@22@77@g" |
        cat - <(echo "/swap/swapfile none swap defaults 0 0") |
        tee "${mountpoint}/etc/fstab"

    return 0
}
