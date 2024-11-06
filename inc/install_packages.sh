#!/usr/bin/env bash
# shellcheck disable=SC2154

install_packages() {
    declare -r pkgs=${1:-${PACKAGES[@]}}
    declare -r rootdir="${2:-${MOUNTDIR}}"
    declare -r cpu="${CPU_VENDOR}"

    if [[ ! -d ${rootdir} ]]; then
        err 3 "\`${rootdir}' is not a directory"
    fi

    if ! mountpoint "${rootdir}"; then
        err 3 "\`${rootdir}' is not a mountpoint"
    fi

    # shellcheck disable=SC2086,SC2048
    pacstrap -cGM "${rootdir}" ${pkgs[*]}

    if [[ -n "${cpu}" ]]; then
        pacstrap -cGM "${rootdir}" "${cpu}-ucode"
    fi
}
