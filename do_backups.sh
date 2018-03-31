#!/bin/bash

# Get variables from conf file
. backups.conf

# Get args
arg="$1"

# List all of the rsnapshot configs
while read -r conf
do
   rsnapshot -c $conf $arg
done<<<"`find $EXEC_DIR/etc/ -iname '*.conf' -type f`"

# Remove existing symlinks
rm -f $BACKUP_DIR/2*-*

# Create symlinks with date and time in the backups dir
while read -r file
do 
  ln -s $BACKUP_DIR/$file `stat -c %y $BACKUP_DIR/$file | sed 's/\..*//g' | sed 's/://g' | sed 's/-/./g' | sed 's/ /-/g'`
done<<<"`ls -1 $BACKUP_DIR`"
