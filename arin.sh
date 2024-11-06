#!/usr/bin/env bash
# shellcheck disable=SC2155

set -o errexit
set -o nounset
set -o pipefail

declare -gr SCRIPTNAME="$(basename "${BASH_ARGV0}")"
declare -gr SCRIPTDIR="$(dirname "$(realpath "${BASH_ARGV0}")")"

source "${SCRIPTDIR}/inc/utils.sh"
source "${SCRIPTDIR}/inc/findconf.sh" # TODO merge w/ utils.sh
# shellcheck disable=SC1090,SC2312
source "$(findconf arin.config)"
source "${SCRIPTDIR}/inc/vars.sh"

if ((UID != 0)); then
    err 2 "permission error"
fi

if (($# != 1)); then
    err 2 "usage: ${SCRIPTNAME} VOLUME"
fi

source "${SCRIPTDIR}/inc/cleanup.sh"
trap cleanup EXIT

# set $VOLUME
declare -g VOLUME="${1:-${VOLUME:-""}}"
if [[ ! -e ${VOLUME} ]]; then
    err 255 "VOLUME not exist"
fi
if [[ -f ${VOLUME} ]]; then
    VOLUME="$(losetup --show --find "${VOLUME}")"
    partprobe "${VOLUME}"
    sync
fi
declare -gr VOLUME
log "VOLUME = ${VOLUME}"

mkdir -p "${WORKDIR}/mnt"

# source "${SCRIPTDIR}/inc/wipe_disk.sh"
# wipe_disk

source "${SCRIPTDIR}/inc/repart.sh"
repart

declare -gr LUKS_PATH="$(lsblk -rno PATH,PARTTYPENAME "${VOLUME}" | grep -m1 'Linux\\x20root' | cut -d' ' -f1)"
declare -gr ESP_PATH="$(lsblk -rno PATH,PARTTYPENAME ${VOLUME} | grep -m1 'EFI\\x20System' | cut -d' ' -f1)"
if [[ -z "${ESP_PATH}" ]] || [[ ! -e "${ESP_PATH}" ]]; then
    err 64 "ESP_PATH"
fi
if [[ -z "${LUKS_PATH}" ]] || [[ ! -e "${LUKS_PATH}" ]]; then
    err 64 ""
fi
log "esp_path ${ESP_PATH}"
log "luks_path ${LUKS_PATH}"

source "${SCRIPTDIR}/inc/mkfs_esp.sh"
mkfs_esp

# source "${SCRIPTDIR}/inc/create_luks.sh"
function create_luks() {
    # TODO warning
    cryptsetup \
        --verbose \
        --batch-mode \
        --type luks2 \
        luksFormat "${LUKS_PATH}" "${KEYFILE}"
    partprobe "${VOLUME}"
    sync
}
create_luks

source "${SCRIPTDIR}/inc/open_luks.sh"
open_luks
declare -gr ROOT_PATH="/dev/mapper/${MAPNAME}"

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
mkfs_btrfs

source "${SCRIPTDIR}/inc/mount_btrfs.sh"
mount_btrfs

source "${SCRIPTDIR}/inc/swapfile.sh"
swapfile

source "${SCRIPTDIR}/inc/mount_esp.sh"
mount_esp

declare -gr UUID_ESP="$(lsblk -rno UUID "${ESP_PATH}")"
declare -gr UUID_LUKS="$(lsblk -rno UUID "${LUKS_PATH}")"
declare -gr UUID_ROOT="$(lsblk --nodeps -rno UUID "${ROOT_PATH}")"

source "${SCRIPTDIR}/inc/install_packages.sh"
install_packages

tree -L1 -d "${MOUNTDIR}"

# source "${SCRIPTDIR}/inc/copy_skeleton.sh"
# copy_skeleton

source "${SCRIPTDIR}/inc/generate_fstab.sh"
generate_fstab

# generate_locale
# firstboot
# bootloader
# gen_cmdline
# configure_initrd
# gen_initrd

# source "${SCRIPTDIR}/inc/@@.sh"
# @@

exit 0
