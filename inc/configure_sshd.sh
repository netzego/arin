#!/usr/bin/env bash
# shellcheck disable=SC2154

function configure_sshd() {
    systemd-nspawn -D "${MOUNTDIR}" systemctl enable sshd.service
}
