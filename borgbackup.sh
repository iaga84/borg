#!/bin/bash

echo "CIAO!"
borg --version
echo "$(date): executed script" >> /var/log/cron.log 2>&1
