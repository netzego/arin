#!/usr/bin/env bash
# shellcheck disable=SC2155

set -o errexit
set -o nounset
set -o pipefail

declare -gr SCRIPTNAME="$(basename "${BASH_ARGV0}")"
declare -gr SCRIPTDIR="$(dirname "$(realpath "${BASH_ARGV0}")")"

source "${SCRIPTDIR}/inc/utils.sh"
# source "${SCRIPTDIR}/inc/findconf.sh" # TODO merge w/ utils.sh
# shellcheck disable=SC1090,SC2312
source "${SCRIPTDIR}/arin.config"
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
    VOLUME="$(losetup --show --find --partscan "${VOLUME}")"
    partprobe "${VOLUME}"
    sync
fi
declare -gr VOLUME
log "VOLUME = ${VOLUME}"

mkdir -p "${WORKDIR}/mnt"

# TODO warning
# source "${SCRIPTDIR}/inc/erase_disk.sh"
# erase_disk

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

source "${SCRIPTDIR}/inc/create_luks.sh"
create_luks

source "${SCRIPTDIR}/inc/open_luks.sh"
open_luks
declare -gr ROOT_PATH="/dev/mapper/${MAPNAME}"

source "${SCRIPTDIR}/inc/mkfs_btrfs.sh"
mkfs_btrfs

source "${SCRIPTDIR}/inc/mount_btrfs.sh"
mount_btrfs

source "${SCRIPTDIR}/inc/swapfile.sh"
swapfile

source "${SCRIPTDIR}/inc/mkfs_esp.sh"
mkfs_esp

source "${SCRIPTDIR}/inc/mount_esp.sh"
mount_esp

declare -gr UUID_ESP="$(lsblk -rno UUID "${ESP_PATH}")"
declare -gr UUID_LUKS="$(lsblk -rno UUID,FSTYPE "${LUKS_PATH}" | grep -m1 "crypto_LUKS" | cut -d' ' -f1)"
declare -gr UUID_ROOT="$(lsblk -rno UUID,FSTYPE "${ROOT_PATH}" | grep -m1 "btrfs" | cut -d' ' -f1)"

log "${UUID_ESP}"
log "${UUID_LUKS}"
log "${UUID_ROOT}"

source "${SCRIPTDIR}/inc/install_packages.sh"
install_packages

source "${SCRIPTDIR}/inc/generate_fstab.sh"
generate_fstab

source "${SCRIPTDIR}/inc/gen_locale.sh"
gen_locale

source "${SCRIPTDIR}/inc/firstboot.sh"
firstboot

source "${SCRIPTDIR}/inc/gen_cmdline.sh"
gen_cmdline "${UUID_LUKS}" "${UUID_ROOT}"

source "${SCRIPTDIR}/inc/configure_initrd.sh"
configure_initrd

source "${SCRIPTDIR}/inc/gen_initrd.sh"
gen_initrd

source "${SCRIPTDIR}/inc/install_bootloader.sh"
install_bootloader

# source "${SCRIPTDIR}/inc/copy_skeleton.sh"
# copy_skeleton

# configure_networkd
# configure_timesyncd
# configure_sshd
# copy_sshkeys

# add_user -- not implemented
# remove_pam_securetty -- not implemented; needed for nspawn

log "~~~ C O N G R A T S ~~~"

exit 0
