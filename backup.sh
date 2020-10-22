#!/bin/bash

set -euo pipefail

BORG_LOCATION="/borgbackup-database/borgbackup"

if pgrep borg > /dev/null; then
  echo "borg is already running - aborting"
  exit 0
fi

echo "Running borgbackup.."
archive_name="borgbackup-$(date -Iseconds | cut -d '+' -f 1)"

borg create --stats --compression zstd,22 \
  "${BORG_LOCATION}"::"${archive_name}" \
  /borgbackup-ale \
  /borgbackup-zai

echo "Backup finished"