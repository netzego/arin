#!/usr/bin/env bash

function findconf() {
    declare -r filename="${1}"

    if [[ -f "${PWD}/${filename}" ]]; then
        echo "${PWD}/${filename}"
    elif [[ -f "${SCRIPTDIR}/${filename}" ]]; then
        echo "${SCRIPTDIR}/${filename}"
    fi
}
