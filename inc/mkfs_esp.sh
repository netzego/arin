#!/usr/bin/env bash

function mkfs_esp() {
    if [[ "$(lsblk -rno FSTYPE "${ESP_PATH}")" != "vfat" ]]; then
        # WARNING
        mkfs.vfat -F32 "${ESP_PATH}"
    fi
}
