#!/bin/bash

# Install
apt-get update
apt-get -y install rsnapshot

# Create an SSH key
ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa

# Set up the cron jobs
echo "0 6 * * * `pwd`/do_backups.sh daily" >> /var/spool/cron/crontabs/root
echo "5 6 * * * `pwd`/do_symlinks.sh" >> /var/spool/cron/crontabs/root
echo "0 4 * * 7 `pwd`/do_backups.sh weekly" >> /var/spool/cron/crontabs/root
echo "5 4 * * 7 `pwd`/do_symlinks.sh" >> /var/spool/cron/crontabs/root
echo "0 2 1 * * `pwd`/do_backups.sh monthly" >> /var/spool/cron/crontabs/root
echo "5 2 1 * * `pwd`/do_symlinks.sh" >> /var/spool/cron/crontabs/root
