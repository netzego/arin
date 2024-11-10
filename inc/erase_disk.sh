#!/usr/bin/env bash
# shellcheck disable=SC2154

function erase_disk() {
    declare -r mapname="wipe-${RNDNR}"

    cryptsetup open \
        --type plain \
        --key-file /dev/urandom \
        --sector-size 4096 \
        "${LUKS_PATH}" "/dev/mapper/${mapname}"
    dd if=/dev/zero of="/dev/mapper/${mapname}" status=progress bs=1M
}
