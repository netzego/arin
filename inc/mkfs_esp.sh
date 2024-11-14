#!/usr/bin/env bash

function mkfs_esp() {
    if [[ "$(lsblk -rno FSTYPE "${ESP_PATH}")" != "vfat" ]]; then
        # WARNING
        mkfs.vfat "${ESP_PATH}"
    fi
}
