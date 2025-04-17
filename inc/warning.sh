#!/usr/bin/env bash
# shellcheck disable=2120,2312,2154
function warning() {
    # log "  ${SCRIPTNAME} Version ${VERSION}"
    # cat "${SCRIPTDIR}/inc/asciiart" | sed "s@^@${LOG_PREFIX}@"
    sed "s@^@${LOG_PREFIX}@" "${SCRIPTDIR}/inc/asciiart"
    log "Warning! You about to delete your data here."
    log "Please make sure you have copy of your files. Also"
    log "note that this programm come without any warranty."
    log "The following path (device or file) will be deleted."
    log ""
    log "$(realpath "${1}")"
    log ""
    # log "${SCRIPTNAME} $()${VOLUME}"
    if [[ ${BATCH} != yes ]]; then
        echo ">>> Type yes in uppecase to continue (YES): "
        echo -n "<<< "
        read -r ans
        if [[ ${ans} != "YES" ]]; then
            err 254 "execution aborted by user."
        fi
    fi
}
