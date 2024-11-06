#!/usr/bin/env bash
# shellcheck disable=SC2154

# DESC: mount uefi partition inside rootfs
# ARGS: `$1` (optional): path to the device/partition
#       `$2` (required): path to efi directory. should be inside rootfs.
# EXPL: mount_fat32 "/dev/sdX1" "/mnt/efi"
# COND: $MOUNTPOINT
#       $UEFIPART
mount_esp() {
    local device="${1:-${ESP_PATH}}"
    local mntpoint="${2:-${MOUNTDIR}}/efi"

    mkdir -vp "${mntpoint}"

    check_mountpoint "${mntpoint}"

    mount -v "${device}" "${mntpoint}"
}
