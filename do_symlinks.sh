#!/bin/bash

# Get dirname
thisdir=`dirname $0`
. "$thisdir/backups.conf"

# Remove existing symlinks
rm -f $BACKUP_DIR/2*-*

# Create symlinks with date and time in the backups dir
while read -r file
do
  if [ "$file" != "lost+found" ]
  then
    echo "ln -s $BACKUP_DIR/$file $BACKUP_DIR/`stat -c %y $BACKUP_DIR/$file | sed 's/\..*//g' | sed 's/://g' | sed 's/-/./g' | sed 's/ /-/g'`"
    ln -s $BACKUP_DIR/$file $BACKUP_DIR/`stat -c %y $BACKUP_DIR/$file | sed 's/\..*//g' | sed 's/://g' | sed 's/-/./g' | sed 's/ /-/g'`
  fi
done<<<"`cd $BACKUP_DIR; ls -1d *.?`"
