#!/bin/bash

set -euo pipefail

BORG_LOCATION="/borgbackup-database/borgbackup"
RCLONE_SOURCE="/borgbackup-database"
RCLONE_CONFIG="/borgbackup-database/rclone.conf"
RCLONE_REMOTE_NAME="b2"
B2_BUCKET_NAME="hoana-borgbackup"

echo "$(date): Scheduled backup procedure started.." >> /var/log/cron.log 2>&1

if pgrep borg > /dev/null; then
  echo "$(date): borg is already running - aborting" >> /var/log/cron.log 2>&1
  exit 0
fi

if pgrep rclone > /dev/null; then
  echo "$(date): rclone is already running - aborting" >> /var/log/cron.log 2>&1
  exit 0
fi

echo "$(date): Running borgbackup" >> /var/log/cron.log 2>&1

archive_name="borgbackup-$(date -Iseconds | cut -d '+' -f 1)"

borg create --stats --compression zstd,22 \
  "${BORG_LOCATION}"::"${archive_name}" \
  /borgbackup-ale \
  /borgbackup-zai

echo "$(date): borgbackup completed, starting rclone" >> /var/log/cron.log 2>&1

if pgrep borg > /dev/null; then
  echo "$(date): borg is already running - aborting" >> /var/log/cron.log 2>&1
  exit 0
fi

if pgrep rclone > /dev/null; then
  echo "$(date): rclone is already running - aborting" >> /var/log/cron.log 2>&1
  exit 0
fi

rclone sync --config="${RCLONE_CONFIG}" --bwlimit 0.275M "${RCLONE_SOURCE}" "${RCLONE_REMOTE_NAME}":"${B2_BUCKET_NAME}"

echo "$(date): rclone sync completed, starting rclone cleanup" >> /var/log/cron.log 2>&1

rclone cleanup --config="${RCLONE_CONFIG}" "${RCLONE_REMOTE_NAME}":"${B2_BUCKET_NAME}"

echo "$(date): Backup procedure successfully completed" >> /var/log/cron.log 2>&1