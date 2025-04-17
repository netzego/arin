#!/usr/bin/env bash

function configure_timesyncd() {
    systemctl --root "${MOUNTDIR}" enable systemd-timesyncd.service
}
