#!/bin/bash

# Get variables from conf file
thisdir=`dirname $0`
. "$thisdir/backups.conf"

# Get args
arg="$1"

# Write the master config file
echo "" > "$EXEC_DIR/rsnapshot.conf"

# List all of the rsnapshot configs
while read -r conf
do
   echo -e "include_conf\t$conf" >> "$EXEC_DIR/rsnapshot.conf"
done<<<"`find $EXEC_DIR/etc/ -iname '*.conf' -type f`"

# Run rsnapshot
rsnapshot -c "$EXEC_DIR/rsnapshot.conf" $arg
