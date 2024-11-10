#!/usr/bin/env bash

function configure_timesyncd() {
    systemd-nspawn -D "${MOUNTDIR}" systemctl enable systemd-timesyncd.service
}
