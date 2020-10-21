FROM python:3.9

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y cron python3-dev libssl-dev openssl libacl1-dev libacl1 build-essential && \
    pip install -U pip setuptools wheel && \
    pip install -U borgbackup

COPY crontab /etc/cron.d/simple-cron
COPY borgbackup.sh /

RUN chmod +x /borgbackup.sh
RUN chmod 0644 /etc/cron.d/simple-cron
RUN touch /var/log/cron.log

CMD cron && tail -f /var/log/cron.log
