#!/usr/bin/env bash

function mkfs_btrfs() {
    declare subvol
    declare subdir
    mkfs.btrfs -f "${ROOT_PATH}"
    # <FS-ROOT>
    mount -o "${BTRFS_MOUNT_OPTIONS}" "${ROOT_PATH}" "${MOUNTDIR}"
    for s in "${BTRFS_SUBVOLUMES[@]}"; do
        subvol=$(echo "${s}" | cut -d: -f1)
        btrfs -v subvol create "${MOUNTDIR}/${subvol}"
    done
    btrfs -v subvolume set-default "${MOUNTDIR}/@rootfs"
    umount -v "${MOUNTDIR}"

    # @rootfs
    mount -o "${BTRFS_MOUNT_OPTIONS}" "${ROOT_PATH}" "${MOUNTDIR}"
    for s in "${BTRFS_SUBVOLUMES[@]}"; do
        local subvol=$(echo "${s}" | cut -d: -f1)
        local subdir=$(echo "${s}" | cut -d: -f2)
        [[ "${subvol}" = "@rootfs" ]] && continue
        mkdir -vp "${MOUNTDIR}/${subdir}"
        mount -o "${BTRFS_MOUNT_OPTIONS},subvol=${subvol}" "${ROOT_PATH}" "${MOUNTDIR}/${subdir}"
    done

    findmnt --raw -t btrfs -R "${ROOT_PATH}"

    umount -v -R "${MOUNTDIR}"
}
