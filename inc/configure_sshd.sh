#!/usr/bin/env bash
# shellcheck disable=SC2154

function configure_sshd() {
    systemctl --root "${MOUNTDIR}" enable sshd.service
}
