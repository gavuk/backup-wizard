#!/bin/bash

# Include variables
. backups.conf

# Get the arguments
mode="$1"
backup="$2"
dest="$3"

function usage {
  echo "Usage:"
  echo "$0 files|db <backup_dir> <destination>"
  echo ""
  echo "For example:"
  echo "$0 files /backups/daily.0/web root@newserver"
  echo "$0 db /backups/weekly.0/db root@newserver"
}

# Check that the arguments have been set
if [ "$backup" == "" -o "$dest" == "" ]
then
  usage
fi

# Restore files
function restore_files {
  # Zip the files up
  tar cfz "$backup" "/tmp/$dest.tar.gz"
}

# Get the mode
case $mode in
"files")
  restore_files
  ;;
"db")
  restore_db
  ;;
*)
  usage
  ;;
esac
