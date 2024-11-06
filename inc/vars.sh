#!/usr/bin/env bash
# shellcheck disable=SC2155,SC2034

declare -gr WIPE="${WIPE:-no}"
declare -gr CREATE_WIN="${CREATE_WIN:-no}"

declare -gr RNDNR="$(uuidgen -t | tr -d '-')"
declare -gr WORKDIR=".workdir-${RNDNR}"
declare -gr KEYFILE="arin.keyfile"
declare -gr MAPNAME="rootfs-${RNDNR}"
declare -gr MOUNTDIR="${WORKDIR}/mnt"

declare -gr TYPECODE_ESP="EF00"
declare -gr TYPECODE_LINUXROOT="8304"
declare -gr TYPECODE_WINDATA="0700"
declare -gr TYPECODE_WINRESCUE="2700"
declare -gr TYPECODE_WINRESERVED="0C01"

declare -gr SIZE_ESP="${ESP_SIZE:-128M}"
declare -gr SIZE_LINUXROOT="${ROOT_SIZE:-0}"
declare -gr SIZE_SWAPFILE="128M"
declare -gr SIZE_WINDATA="64M"    # TODO change me
declare -gr SIZE_WINRESCUE="128M" # TODO change me
declare -gr SIZE_WINRESERVED="16M"

filearray "PACKAGES" "${SCRIPTDIR}/inc/core.packages" "${PWD}/${SCRIPTNAME}.packages"
declare -gr BTRFS_MOUNT_OPTIONS="noatime,compress=zstd"
declare -gra BTRFS_SUBVOLUMES=(
    # subvol:mountpoint
    "@rootfs:/"
    "@home:/home"
    "@log:/var/log"
    "@machines:/var/lib/machines"
    "@portables:/var/lib/portables"
    "@pkgs:/var/cache/pacman/pkgs"
    #"@root:/root"
    "@snapshots:/snapshots"
    "@srv:/srv"
    "@swap:/swap"
)