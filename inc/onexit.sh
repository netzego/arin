#!/usr/bin/env bash
# shellcheck disable=SC2154

function onexit() {
    if [[ ${VOLUME} == /dev/loop* ]]; then
        losetup -d "${VOLUME}"
    fi

    if mountpoint -q "${MOUNTDIR}"; then
        umount -R "${MOUNTDIR}"
    fi

    if [[ -e /dev/mapper/${MAPNAME} ]]; then
        cryptsetup close "${MAPNAME}"
    fi

    if [[ -d ${WORKDIR} ]]; then
        rm -fr "${WORKDIR}"
    fi
}
