#!/usr/bin/env bash

function create_luks() {
    # TODO warning
    cryptsetup \
        --verbose \
        --batch-mode \
        --type luks2 \
        luksFormat "${LUKS_PATH}" "${KEYFILE}"
    partprobe "${VOLUME}"
    sync
}
