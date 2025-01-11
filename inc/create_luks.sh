#!/usr/bin/env bash

function create_luks() {
    if [[ ! -f "${KEYFILE}" ]]; then
        err 3 "'${KEYFILE}' do not exsist."
    fi
    if [[ $(stat -c "%a" "${KEYFILE}") != "400" ]]; then
        err 3 "'${KEYFILE}' mode should be set to '0400'."
    fi
    cryptsetup \
        --verbose \
        --batch-mode \
        --type luks2 \
        luksFormat "${LUKS_PATH}" "${KEYFILE}"
    partprobe "${VOLUME}"
    sync
}
