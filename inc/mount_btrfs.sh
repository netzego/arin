#!/usr/bin/env bash
# shellcheck disable=SC2155

# DESC: mounts the rootfs partiton to $MOUNTPOINT
# ARGS: $1 (optional): partition
#       $2 (optional): mountpoint
#       $3 (optional): array of strings defining "subvolumes:mountpoint".
#                      eg.: array=("@rootfs:/" ...)
#       $4 (optional): btrfs mount options. see man:mount(8).
# EXMP: mount_btfs "/dev/sdx2" "/mnt" ("@rootfs:/" "@home:/home") "noatime,compress=zstd"
# GLOB:
#       $ROOT_PATH
#       $WORKDIR
#       $MOUNTPOINT
#       $BTRFS_MOUNT_OPTIONS
#       $BTRFS_SUBVOLUMES
function mount_btrfs() {
    declare -r partition="${1:-${ROOT_PATH}}"
    declare -r mountdir="${2:-${MOUNTDIR}}"
    declare -ra subvolumes=("${3:-${BTRFS_SUBVOLUMES[@]}}")
    declare -r options="${4:-${BTRFS_MOUNT_OPTIONS}}"

    check_mountpoint "${mountdir}"

    # mount default subvolume
    mount -v -o "${options}" "${partition}" "${mountdir}"

    # mount subvolumes
    for s in "${subvolumes[@]}"; do
        declare subvol=$(echo "${s}" | cut -d: -f1)
        declare subdir=$(echo "${s}" | cut -d: -f2)
        [[ "${subvol}" = "@rootfs" ]] && continue
        mount -v -o "${options},subvol=${subvol}" "${partition}" "${mountdir}/${subdir}"
    done

    findmnt --raw -t btrfs -R "${ROOT_PATH}"
}
