#!/usr/bin/env bash

gen_locale() {
    declare -r locale="${1:-${LOCALE}}"
    declare -r rootfs="${2:-${MOUNTDIR}}"

    if [[ ! -f "${rootfs}/etc/locale.gen" ]]; then
        err 3 "\`${rootfs}/etc/locale.gen' does not exists"
    fi

    echo "${locale} UTF-8" >>"${rootfs}/etc/locale.gen"

    systemd-nspawn -D "${rootfs}" locale-gen
}
