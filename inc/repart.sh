#!/usr/bin/env bash
# shellcheck disable=SC2154,SC2312

function has_part() {
    sgdisk -p "${VOLUME}" | grep -q "${1}"
    return $?
}

# shellcheck disable=SC2317,SC2086
function repart() {
    if [[ "${WIPE_DISK}" == "yes" ]]; then
        log "${VOLUME}: zapp gpt table"
        sgdisk -Z "${VOLUME}"
    fi
    if ! has_part "${TYPECODE_ESP}"; then
        log "create a new esp partition"
        sgdisk \
            --new=0:0:+${SIZE_ESP} \
            --typecode=0:${TYPECODE_ESP} \
            "${VOLUME}"
    fi
    # else
    # TODO check if ESP is greater or equal to $ESP_SIZE
    # TODO check if ESP is the first part
    # DEAD
    # if [[ "${CREATE_WIN}" == "yes" ]]; then
    #     if ! has_part "${TYPECODE_WINDATA}"; then
    #         sgdisk \
    #             --new=0:0:+${SIZE_WINDATA} \
    #             --typecode=0:${TYPECODE_WINDATA} \
    #             "${VOLUME}"
    #     fi
    #     if ! has_part "${TYPECODE_WINRESCUE}"; then
    #         sgdisk \
    #             --new=0:0:+${SIZE_WINRESCUE} \
    #             --typecode=0:${TYPECODE_WINRESCUE} \
    #             "${VOLUME}"
    #     fi
    #     if ! has_part "${TYPECODE_WINRESERVED}"; then
    #         sgdisk \
    #             --new=0:0:+${SIZE_WINRESERVED} \
    #             --typecode=0:${TYPECODE_WINRESERVED} \
    #             "${VOLUME}"
    #     fi
    # fi
    if ! has_part "${TYPECODE_LINUXROOT}"; then
        log "create a new root partition"
        sgdisk \
            --new=0:0:+${SIZE_LINUXROOT} \
            --typecode=0:${TYPECODE_LINUXROOT} \
            "${VOLUME}"
    fi
    # TODO else
    # TODO check if is $ROOT_PATH big enough?
    partprobe "${VOLUME}"
    sync
    sgdisk -p "${VOLUME}"
}
