#!/bin/bash

# Load variables from conf file
. backups.conf

echo $0

# The functions that make everything work

# Get the hostname of the remote server
function get_hostname {
  while [ "$hostname" == "" ]
  do
    read -p "Hostname of the new server: " hostname

    # Check the host is reachable
    if [ "$hostname" != "" ]
    then
      echo "Checking host can be reached..."
      ping -c 1 $hostname 2>&1>/dev/null
      if [ "$?" != "0" ] # If the ping returned anything other than 0 there was a problem
      then
        echo -e "Host $hostname unreachable\n"
        hostname="" # If host is unreachable then prompt again
      else
        echo -e "Success!\n"
      fi
    fi
  done
}

# Get the SSH username to connect with
function get_user {
  while [ "$user" == "" ]
  do
    read -p "Username to connect to $hostname [root]: " user

    # If username is blank set it to root
    if [ "$user" == "" ]
    then
      user="root"
    fi
  done
}

# Get the SSH password and copy over an SSH key
function get_pass {
  # Copy over the SSH key
  ssh-copy-id $user@$hostname 2>/dev/null

  # If it failed then do it again
  if [ "$?" != "0" ]
  then
    get_pass
  fi
}

# Set up the rsnapshot config
function do_rsnapshot_conf {
  # Move into the main program dir
  cd "$EXEC_DIR"

  # Copy the template conf file
  cp -i etc/rsnapshot.tpl etc/$hostname.conf

  # Replace placeholder in the conf file with actual values
  sed -i "s/{{hostname}}/$hostname/g" etc/$hostname.conf

  # Check there weren't any errors
  if [ "$?" != "0" ]
  then
    read -p "There were errors setting up $EXEC_DIR/etc/$hostname.conf, press Ctrl + C to quit"
  fi
}

# Add lines to the rsnapshot conf file to actually do the backing up
function do_rsnapshot_backups {
  # Move into the main program dir
  cd "$EXEC_DIR"

  # This is so the while loop works
  backupdir="START"

  # Read each line with input and add to the bottom of the conf file
  while [ "$backupdir" != "" ]
  do
    read -p "Enter a single directory to back up (e.g. /var/www/). If you have no more directories to enter then leave blank and press Enter: " backupdir

    # If the input wasn't blank then write the backup line with this dir
    if [ "$backupdir" != "" ]
    then
      # This is so the while loop works
      excludedir="START"

      # Check if there's anything to exclude
      while [ "$excludedir" != "" ]
      do
        read -p "Enter a single file or directory to exclude from the backup of $backupdir. If you have no more directories to exclude then leave blank and press Enter: " excludedir
        excludelist="$excludelist,exclude=$excludedir"
      done

      # Tidy up the exclude list
      exclude=`echo $excludelist | sed 's/,exclude=$//g'`
      exclude=`echo $exclude | sed 's/,exclude=,//g'`

      # Make sure the backup dir ends with a slash
      if [ "${backupdir: -1}" != "/" ]
      then
        backupdir="$backupdir/"
      fi

      # Write the line to the conf file
      echo -e "backup\t$user@$hostname:$backupdir\t$hostname/\t$exclude" >> etc/$hostname.conf
    fi
  done
}

# Set up the remote host for MySQL dumps
function do_rsnapshot_mysql {
  # Get the MySQL credentials
  # MySQL username
  while [ "$muser" == "" ]
  do
    read -p "Username to connect to MySQL on $hostname [root]: " muser

    # If username is blank set it to root
    if [ "$muser" == "" ]
    then
      muser="root"
    fi
  done

  # To make the while loop work
  mpass="CHANGEME"

  # MySQL password (and confirm)
  while [ "$mpass" != "$mpassc" ]
  do
    read -p "Password to connect to MySQL on $hostname: " mpass
    read -p "Confirm password to connect to MySQL on $hostname: " mpassc

    # Check the passwords match 
    if [ "$mpass" != "$mpassc" ]
    then
      echo -e "Passwords did not match\n"
    fi
  done

  # Write the .my.cnf file on the remote server
  ssh $user@$hostname "echo -e \"[Client]\nuser=$muser\npassword=$mpass\" >> ~/.my.cnf; chmod 0400 ~/.my.cnf; mkdir -p /var/db/dump/"

  # Write the line to the rsnapshot conf file
  echo -e "backup_exec\tssh $user@$hostname 'while read -r db; do mysqldump --skip-lock-tables \$db > /var/db/dump/\$db.sql; done<<<\"\`mysql -Ne \"show databases\" | grep -vxe \"information_schema\|sys\"\`\"'" >> etc/$hostname.conf
  echo -e "backup\t$user@$hostname:/var/db/dump/\t$hostname/" >> etc/$hostname.conf

}



# The main part of the program. Prompt for the information we need

# Do file backups?
# Keep asking until we get a yes or no response
while [ "${input,,}" != "yes" -a "${input,,}" != "y" -a "${input,,}" != "no" -a "${input,,}" != "n" ] 
do
  read -p "Set up file backups (yes/no)? [yes] " input
  # A blank line means yes
  if [ "$input" == "" ]
  then
    input="yes"

    # If the answer is yes start asking questions
    get_hostname
    get_user
    get_pass
    do_rsnapshot_conf
    do_rsnapshot_backups
  fi
done


# Do MySQL backups?
while [ "${minput,,}" != "yes" -a "${minput,,}" != "y" -a "${minput,,}" != "no" -a "${minput,,}" != "n" ] 
do
  read -p "Set up MySQL backups (yes/no)? [yes] " minput
  # A blank line means yes
  if [ "$minput" == "" ]
  then
    minput="yes"

    # If the answer is yes start asking questions, but this time check if we already have the answers
    if [ "$hostname" == "" ]
    then
      get_hostname
      get_user
      get_pass
      do_rsnapshot_conf
    fi

    do_rsnapshot_mysql
  fi
done

