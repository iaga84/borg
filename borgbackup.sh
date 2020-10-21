#!/bin/bash

echo "$(date): executed script ($BORG_PASSPHRASE)" >> /var/log/cron.log 2>&1
