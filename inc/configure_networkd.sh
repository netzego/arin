#!/usr/bin/env bash

function configure_networkd() {
    declare -r rootfs="${1:-$MOUNTDIR}"

    # TODO: try via `systemd-run`
    systemd-nspawn -D "${rootfs}" systemctl enable systemd-networkd.service
    systemd-nspawn -D "${rootfs}" systemctl enable systemd-resolved.service

    ln -frs "${rootfs}/usr/lib/systemd/network/89-ethernet.network.example" \
        "${rootfs}/etc/systemd/network/80-ethernet.network"

    ln -frs "${rootfs}/usr/lib/systemd/network/80-wifi-station.network.example" \
        "${rootfs}/etc/systemd/network/80-wifi-station.network"

    ln -frs "${rootfs}/run/systemd/resolve/stub-resolv.conf" \
        "${rootfs}/etc/resolv.conf"
}
