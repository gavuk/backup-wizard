#!/bin/bash

# Get variables from conf file
. backups.conf

# Get args
arg="$1"

# List all of the rsnapshot configs
while read -r conf
do
   rsnapshot -c $conf $arg &
done<<<"`find $EXEC_DIR/etc/ -iname '*.conf' -type f`"

# Remove existing symlinks
rm -f $BACKUP_DIR/2*-*
