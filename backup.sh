#!/bin/bash

set -euo pipefail

BORG_LOCATION="/borgbackup-database/borgbackup"
RCLONE_SOURCE="/borgbackup-database"
RCLONE_REMOTE_NAME="b2"
B2_BUCKET_NAME="hoana-borgbackup"

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
echo "Running rclone.."

if pgrep rclone > /dev/null; then
  echo "rclone is already running - aborting"
  exit 0
fi

rclone sync "${RCLONE_SOURCE}" "${RCLONE_REMOTE_NAME}":"${B2_BUCKET_NAME}"
rclone cleanup "${RCLONE_REMOTE_NAME}":"${B2_BUCKET_NAME}"

echo "Backblaze sync finished"

echo "$(date): Backup completed" >> /var/log/cron.log 2>&1
