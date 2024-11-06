#!/usr/bin/env bash
# shellcheck disable=SC2154,SC2312

function has_part() {
    sgdisk -p "${VOLUME}" | grep -q "${1}"
    return $?
}

# shellcheck disable=SC2317,SC2086
function repart() {
    if [[ "${WIPE}" == "yes" ]]; then
        # TODO: WARNING
        sgdisk -Z "${VOLUME}"
    fi
    if ! has_part "${TYPECODE_ESP}"; then
        sgdisk \
            --new=0:0:+${SIZE_ESP} \
            --typecode=0:${TYPECODE_ESP} \
            "${VOLUME}"
    fi
    if [[ "${CREATE_WIN}" == "yes" ]]; then
        if ! has_part "${TYPECODE_WINDATA}"; then
            sgdisk \
                --new=0:0:+${SIZE_WINDATA} \
                --typecode=0:${TYPECODE_WINDATA} \
                "${VOLUME}"
        fi
        if ! has_part "${TYPECODE_WINRESCUE}"; then
            sgdisk \
                --new=0:0:+${SIZE_WINRESCUE} \
                --typecode=0:${TYPECODE_WINRESCUE} \
                "${VOLUME}"
        fi
        if ! has_part "${TYPECODE_WINRESERVED}"; then
            sgdisk \
                --new=0:0:+${SIZE_WINRESERVED} \
                --typecode=0:${TYPECODE_WINRESERVED} \
                "${VOLUME}"
        fi
    fi
    if ! has_part "${TYPECODE_LINUXROOT}"; then
        sgdisk \
            --new=0:0:+${SIZE_LINUXROOT} \
            --typecode=0:${TYPECODE_LINUXROOT} \
            "${VOLUME}"
    fi
    partprobe "${VOLUME}"
    sync
    sgdisk -p "${VOLUME}"
}
