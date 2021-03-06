#!/bin/bash

# Get variables from conf file
thisdir=`dirname $0`
. "$thisdir/backups.conf"

# Get the start time
starttime=`date`

# Get args
arg="$1"

# Write the master config file
cat "$EXEC_DIR/rsnapshot.tpl" > "$EXEC_DIR/rsnapshot.conf"

# List all of the rsnapshot configs
while read -r conf
do
   echo -e "include_conf\t$conf" >> "$EXEC_DIR/rsnapshot.conf"
done<<<"`find $EXEC_DIR/etc/ -iname '*.conf' -type f`"

# Run rsnapshot
rsnapshot -Vc "$EXEC_DIR/rsnapshot.conf" $arg

# Sort out the symlinks
$EXEC_DIR/do_symlinks.sh > /var/log/backup_symlinks.log

# Output some stats
echo ""
echo "Start time: $starttime"
echo "End time:   `date`"
echo ""
du -h --max-depth=1 "$BACKUP_DIR/$arg.0/"
