FROM python:3.9

ARG BORG_PASSPHRASE

ENV BORG_PASSPHRASE $BORG_PASSPHRASE

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y cron python3-dev libssl-dev openssl libacl1-dev libacl1 build-essential && \
    pip install -U pip setuptools wheel && \
    pip install -U borgbackup && \
    curl https://rclone.org/install.sh | bash

COPY crontab /etc/cron.d/simple-cron
COPY backup.sh /

RUN chmod +x /backup.sh
RUN chmod 0644 /etc/cron.d/simple-cron
RUN touch /var/log/cron.log

CMD cron && tail -f /var/log/cron.log
