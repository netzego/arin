#!/usr/bin/env bash
# shellcheck disable=SC2155,SC2034

declare -gr VERSION="0.0.0"
declare -gr RNDNR="$(uuidgen -t | tr -d '-')"
declare -gr WORKDIR="$(mktemp -d -p /tmp "${SCRIPTNAME}.workdir-XXXXXXXX")"
declare -gr KEYFILE="arin.keyfile"
declare -gr MAPNAME="rootfs-${RNDNR}"
declare -gr MOUNTDIR="${WORKDIR}/mnt"

declare -gr TYPECODE_ESP="EF00"
declare -gr TYPECODE_LINUXROOT="8304"
# declare -gr TYPECODE_WINDATA="0700" # TODO delete me
# declare -gr TYPECODE_WINRESCUE="2700"
# declare -gr TYPECODE_WINRESERVED="0C01"

declare -gr SIZE_ESP="${ESP_SIZE:-128M}"
declare -gr SIZE_LINUXROOT="${ROOT_SIZE:-0}"
# declare -gr SIZE_SWAPFILE="$(grep ^MemTotal /proc/meminfo | xargs | cut -d' ' -f2)k"
declare -gr SIZE_SWAPFILE="128m"
# declare -gr SIZE_WINDATA="64M"    # TODO delete me
# declare -gr SIZE_WINRESCUE="128M" # TODO change me
# declare -gr SIZE_WINRESERVED="16M"

filearray "PACKAGES" "${SCRIPTDIR}/inc/core.packages" "${PWD}/${SCRIPTNAME}.packages"
declare -gr BTRFS_MOUNT_OPTIONS="noatime,compress=zstd"
declare -gra BTRFS_SUBVOLUMES=(
    # subvol:mountpoint
    "@rootfs:/"
    "@home:/home"
    "@log:/var/log"
    "@machines:/var/lib/machines"
    "@portables:/var/lib/portables"
    "@pkg:/var/cache/pacman/pkg"
    #"@root:/root"
    "@snapshots:/snapshots"
    "@srv:/srv"
    "@swap:/swap"
)

declare -gr BATCH="${BATCH:-no}"
declare -gr WIPE="${WIPE:-no}"
declare -gr RANDOMIZE_LINUXROOT="${RANDOMIZE_LINUXROOT:-yes}"
# declare -gr CREATE_WIN="${CREATE_WIN:-no}"
declare -gr LOCALE="${LOCALE:-en_US.UTF-8}"
declare -gr TIMEZONE="${TIMEZONE:-Europe/Berlin}"
declare -gr KEYMAP="${KEYMAP:-us}"
declare -gr CMDLINE_EXTRA="${CMDLINE_EXTRA:-}"
declare -gr DEFAULT_SHELL="${DEFAULT_SHELL:-/usr/bin/bash}"
