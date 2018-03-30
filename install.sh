#!/bin/bash

# Install
apt-get update
apt-get -y install rsnapshot

# Create an SSH key
ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa

# Set up the cron jobs
echo "0 4 * * * `pwd`/do_backups.sh daily" >> /var/spool/cron/crontabs/root
echo "0 2 * * 7 `pwd`/do_backups.sh weekly" >> /var/spool/cron/crontabs/root
echo "0 4 1 * * `pwd`/do_backups.sh monthly" >> /var/spool/cron/crontabs/root
