#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

declare -gr LOG_PREFIX="---"
declare -gr ERROR_PREFIX="***"

function log() {
    echo "${LOG_PREFIX} ${*}"
}

function err() {
    declare -r exitcode="${1}"
    shift
    echo "${ERROR_PREFIX} ${*}" >&2
    exit "${exitcode}"
}

function check_mountpoint() {
    declare -r mntpoint="${1}"

    if [[ ! -d "${mntpoint}" ]]; then
        err 1 "\`${mntpoint}' is not a directory"
    fi
    # shellcheck disable=SC2312
    if [[ -n "$(ls -1A "${mntpoint}")" ]]; then
        err 1 "\`${mntpoint}' directory is not empty"
    fi
    if mountpoint "${mntpoint}"; then
        err 1 "\`${mntpoint}' is already a mountpoint"
    fi
}

# DESC: declare a global readonly array with values equal to lines
#       (exclude empty lines and ons with trailing #) from files in
#       `$@`. if files in `${@[2..-1]}` do not exists this function
#       will not complain. the values of the declared array are
#       unique and sorted.
# ARGS: `$1` (required): the name of the global array which is defined
#       `$@` (required): one ore more filenames to read in
# EXIT: if `$@` is empty
#       if `${@[1]}` do not exists
# EXPL: filearray "VARNAME" "a.foo" [ "not.exists" "b.bar" ... ]
# TODO: write tests
function filearray() {
    declare -r varname="$1"
    shift
    declare -ar files=("$@")

    if ((${#files[@]} < 1)); then
        err 30 "'\${#files[#]}' is less then 1."
    fi

    if [[ ! -f ${files[0]} ]]; then
        err 31 "'\${files[0]}' do not exists"
    fi

    # grep -v: inverts the matching patterns
    # grep -s: suppress errors. in case `$2` do not exists.
    # grep -h: suppress filenames in the output.
    declare -agr "${varname}"="$(grep -shv "^#\|^\$" "${files[@]}")"
}
# filearray ARR test.filearray # TODO remove me
# echo "${ARR[@]}" # TODO remove me. iam here for poor debuging :-)
