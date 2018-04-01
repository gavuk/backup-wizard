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

# Restore files
function restore_files {
  # Warning
  read -p "This will overwrite the server $dest. This action cannot be undone, are you sure? (yes/no) " input
  if [ "${input,,}" != "yes" ]
  then
    exit 0
  fi

  # Zip the files up
  cd "$backup"
  tar -czf "$dest.tar.gz" .

  # Copy file to the new server
  rsync -a "$dest.tar.gz" $dest:/
  ssh $dest "cd /; nohup tar zxf /$dest.tar.gz"
}

# Restore database
function restore_db {
  # Warning
  read -p "This will overwrite the server $dest. This action cannot be undone, are you sure? (yes/no) " input
  if [ "${input,,}" != "yes" ]
  then
    exit 0
  fi

  # Copy over the sql file
  rsync -a "$backup/var/db/dump/databases.sql" $dest:/tmp/
  read -p "MySQL password: " pass
  ssh $dest "nohup mysql -uroot -p < /tmp/databases.sql"
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
