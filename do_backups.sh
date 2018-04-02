#!/bin/bash

# Get variables from conf file
thisdir=`dirname $0`
. "$thisdir/backups.conf"

# Get args
arg="$1"

# List all of the rsnapshot configs
while read -r conf
do
   rsnapshot -c $conf $arg &
done<<<"`find $EXEC_DIR/etc/ -iname '*.conf' -type f`"
