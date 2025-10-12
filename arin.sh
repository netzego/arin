#!/usr/bin/env bash
# shellcheck disable=SC2155,SC1091

set -o errexit
set -o nounset
set -o pipefail
#set -o xtrace

declare -gr SCRIPTNAME="$(basename "${BASH_ARGV0}")"
declare -gr SCRIPTDIR="$(dirname "$(realpath "${BASH_ARGV0}")")"

source "${SCRIPTDIR}/inc/utils.sh"
# shellcheck disable=SC1090,SC2312
source "${SCRIPTDIR}/arin.config"
source "${SCRIPTDIR}/inc/vars.sh"

source "${SCRIPTDIR}/inc/onexit.sh"
trap onexit EXIT

if ((UID != 0)); then
    err 2 "permission error"
fi

if (($# != 1)); then
    err 2 "usage: ${SCRIPTNAME} VOLUME"
fi

source "${SCRIPTDIR}/inc/warning.sh"
warning "$@"

function set_volume() {
    declare -g VOLUME="${1:-${VOLUME:-}}"
    # set $VOLUME
    if [[ ! -e ${VOLUME} ]]; then
        err 255 "'${VOLUME}' do not exist."
    fi
    if [[ -f ${VOLUME} ]]; then
        if [[ $(file -b --mime-encoding "${VOLUME}") != "binary" ]]; then
            err 255 "'${VOLUME}' is not a binary file."
        fi
        declare -gr BACKFILE="${VOLUME}"
        if losetup -nO BACK-FILE | grep -q "${BACKFILE}"; then
            err 255 "'${VOLUME}' is already a back file. try \`losetup -D\`."
        fi
        VOLUME="$(losetup --show --find "${VOLUME}")"
        partprobe "${VOLUME}"
        sync
    elif [[ ! -b ${VOLUME} ]]; then
        err 255 "'${VOLUME}' is not a block nor a binary file."
    fi
    declare -gr VOLUME
    log "VOLUME='${VOLUME}'"
    # check if volume is mounted
    if lsblk -Pno MOUNTPOINT "${VOLUME}" | grep -qv '=""'; then
        err 255 "'${VOLUME}' is mounted"
    fi
}
set_volume "$@"

mkdir -p "${MOUNTDIR}"

source "${SCRIPTDIR}/inc/repart.sh"
repart

# set ESP_PATH and LUKS_PATH
declare -gr LUKS_PATH="$(lsblk -rno PATH,PARTTYPENAME "${VOLUME}" | grep -m1 'Linux\\x20root' | cut -d' ' -f1)"
declare -gr ESP_PATH="$(lsblk -rno PATH,PARTTYPENAME ${VOLUME} | grep -m1 'EFI\\x20System' | cut -d' ' -f1)"
if [[ -z "${ESP_PATH}" ]] || [[ ! -e "${ESP_PATH}" ]]; then
    err 64 "\$ESP_PATH is empty or does not exsist."
fi
if [[ -z "${LUKS_PATH}" ]] || [[ ! -e "${LUKS_PATH}" ]]; then
    err 64 "\$LUKS_PATH is empty or does not exsist."
fi
log "ESP_PATH='${ESP_PATH}'"
log "LUKS_PATH='${LUKS_PATH}'"

source "${SCRIPTDIR}/inc/erase_luks.sh"
erase_luks

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

source "${SCRIPTDIR}/inc/install_bootloader.sh"
install_bootloader

source "${SCRIPTDIR}/inc/gen_cmdline.sh"
gen_cmdline "${UUID_LUKS}" "${UUID_ROOT}"

source "${SCRIPTDIR}/inc/configure_initrd.sh"
configure_initrd

source "${SCRIPTDIR}/inc/gen_initrd.sh"
gen_initrd

source "${SCRIPTDIR}/inc/configure_networkd.sh"
configure_networkd

source "${SCRIPTDIR}/inc/configure_timesyncd.sh"
configure_timesyncd

source "${SCRIPTDIR}/inc/configure_sshd.sh"
configure_sshd

source "${SCRIPTDIR}/inc/copy_sshkey.sh"
copy_sshkey

# source "${SCRIPTDIR}/inc/copy_skeleton.sh"
function copy_skeleton() {
    declare -r skel="${SCRIPTDIR}/arin.skeleton"

    if [[ -d "${skel}" ]]; then
        rsync -av --chown=root:root "${skel}/" "${MOUNTDIR}"
    fi
}
copy_skeleton

# add_user -- not implemented
# remove_pam_securetty -- not implemented; needed for nspawn

log "ARIN HAS FINISHED -- CONGRATS"

exit 0
