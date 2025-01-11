#!/usr/bin/env bash
# shellcheck disable=SC2154

function erase_luks() {
    declare -r lukspart="${1:-${LUKS_PATH}}"
    declare -r mapname="wipe-${RNDNR}"

    if [[ "${RANDOMIZE_LINUXROOT}" != "yes" ]]; then
        return 0
    fi

    cryptsetup open \
        --type plain \
        --key-file /dev/urandom \
        --batch-mode \
        --sector-size 512 \
        "${LUKS_PATH}" "${mapname}"

    set +o errexit
    dd if=/dev/zero of="/dev/mapper/${mapname}" status=progress bs=1M
    set -o errexit

    cryptsetup close "${mapname}"
}
