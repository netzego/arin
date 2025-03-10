#!/usr/bin/env bash
# shellcheck disable=SC2154

function gen_cmdline() {
    declare -r luks_uuid="${1}"
    declare -r root_uuid="${2}"
    declare -r cmdline="rd.luks.name=${luks_uuid}=rootfs root=UUID=${root_uuid} rootflags=noatime,compress=zstd ro ${CMDLINE_EXTRA} rd.luks.options=timeout=0 rootflags=x-systemd.device-timeout=0"

    echo "${cmdline}" | tee "${MOUNTDIR}/etc/kernel/cmdline"
}
