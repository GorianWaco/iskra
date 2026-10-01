#!/usr/bin/env bash
# Iskra — wpięcie w świeży CachyOS / Arch.
#
# Program, modele i pamięć zostają na dysku SSD (etykieta Iskra).
# Ten skrypt tylko je znajduje i odpala instalator z dysku.
#
#   curl -fsSL https://raw.githubusercontent.com/GorianWaco/iskra/main/przywroc.sh | bash
set -euo pipefail

LABEL="Iskra"
UUIDS=(
  "34c09bed-0813-4f70-b069-2ecbbbbbea59"
  "4e69e61b-b4b9-4f9e-958e-baa8da620055"
)

say() { printf '==> %s\n' "$*"; }
die() { printf 'BŁĄD: %s\n' "$*" >&2; exit 1; }

has_installer() {
  local root="$1"
  [[ -f "$root/app/install.sh" || -f "$root/iskra/app/install.sh" || -f "$root/install.sh" ]]
}

mounted_root() {
  local candidate
  for candidate in /mnt/iskra "/run/media/${USER}/Iskra"; do
    if findmnt -n "$candidate" >/dev/null 2>&1 && has_installer "$candidate"; then
      printf '%s' "$candidate"
      return 0
    fi
  done
  return 1
}

disk_src() {
  if [[ -n "${ISKRA_DISK:-}" && -e "$ISKRA_DISK" ]]; then
    printf '%s' "$ISKRA_DISK"
    return 0
  fi
  if [[ -e "/dev/disk/by-label/$LABEL" ]]; then
    printf '%s' "/dev/disk/by-label/$LABEL"
    return 0
  fi
  local uuid
  for uuid in "${UUIDS[@]}"; do
    if [[ -e "/dev/disk/by-uuid/$uuid" ]]; then
      printf '%s' "/dev/disk/by-uuid/$uuid"
      return 0
    fi
  done
  return 1
}

mount_disk() {
  local ready src mnt
  ready="$(mounted_root || true)"
  if [[ -n "$ready" ]]; then
    printf '%s' "$ready"
    return 0
  fi
  src="$(disk_src || true)"
  [[ -n "$src" ]] || die "Nie widzę dysku Iskra. Podłącz SSD i uruchom skrypt jeszcze raz. Nie formatuj tego dysku."
  mnt="$(findmnt -n -o TARGET "$src" 2>/dev/null | head -n1 || true)"
  if [[ -z "$mnt" ]]; then
    command -v udisksctl >/dev/null 2>&1 || die "Brak udisksctl. Zamontuj dysk Iskra i uruchom skrypt jeszcze raz."
    say "Montuję $src"
    udisksctl mount -b "$src" >/dev/null
    mnt="$(findmnt -n -o TARGET "$src" 2>/dev/null | head -n1 || true)"
  fi
  [[ -n "$mnt" ]] || die "Dysk jest podłączony, ale nie ma punktu montowania."
  printf '%s' "$mnt"
}

installer_on() {
  local root="$1" candidate
  for candidate in "$root/app/install.sh" "$root/iskra/app/install.sh" "$root/install.sh"; do
    if [[ -f "$candidate" ]]; then
      printf '%s' "$candidate"
      return 0
    fi
  done
  return 1
}

root="$(mount_disk)"
install="$(installer_on "$root" || true)"
[[ -n "$install" ]] || die "Na $root nie ma install.sh. Zostaw dysk Iskra. Nie formatuj go."

say "Przywracam Iskrę z $install"
exec bash "$install"
