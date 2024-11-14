#!/usr/bin/env bash
# shellcheck disable=SC2154

function gen_cmdline() {
    declare -r luks_uuid="${1}"
    declare -r root_uuid="${2}"
    declare -r cmdline="rd.luks.name=${luks_uuid}=rootfs root=UUID=${root_uuid} rootflags=noatime,compress=zstd rw console=tty0 ${CMDLINE_EXTRA}"

    echo "${cmdline}" | tee "${MOUNTDIR}/etc/kernel/cmdline"
}
