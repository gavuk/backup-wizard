#!/bin/bash

# Set the variable from conf file
. backups.conf

# Get the args
server="$1"
increment="$2"

# usage message
function usage {
  echo "Script to take a manual backup of a server"
  echo ""
  echo "Usage: $0 <server-name> <increment>"
  echo "For example:"
  echo "$0 web daily"
  exit 1
}

# Check the args were given
if [ "$server" == "" ] || [ "$increment" == ""]
then
  usage
fi

# Check config file exists
if [ ! -f "$EXEC_DIR/etc/$server.conf" ]
then
  usage
fi

# Run rsnapshot
rsnapshot -c "$EXEC_DIR/etc/$server.conf" $increment

# Update the symlinks
$EXEC_DIR/do_symlinks.sh
