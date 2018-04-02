# Backup Wizard
Author: Gavin Abson <gavin.abson@gmail.com>

## Introduction
This backup wizard is a collection of scripts to easily customise the backups of files and databases. It guides the user through a series of questions and then creates an rsnapshot config based on their answers.

## Installation
1. The installation is easiest if you can switch to the root user with `su -` or `sudo -i`
2. Start off by cloning the Git repo to somewhere like /opt

```bash
cd /opt
git clone https://github.com/gavuk/backup-wizard
```

3. Run the installer script to install rsnapshot and add cron jobs
```bash
cd /opt/backup-wizard
./install.sh
```

## Adding a server
To add a remote server to start getting backed up use the add_server.sh script

```bash
./add-server.sh
```

This will then prompt you to answer a few questions, including:
* if you want to back up files and/or databases
* the hostname of the remote server
* the login credentials for SSH and MySQL (if applicable)
* the remote directories you want to back up
* any directories you want to exclude
* and databases you want to exclude (the default is to back up all of them)

Once you have gone through the wizard it will create an rsnapshot config file in the `etc` directory (e.g. /opt/backup-wizard/etc)

This is a regular rsnapshot config file, so you can manually add any extra parameters you want to this file - see the man page for more details `man rsnapshot`


## Removing a server
To remove a server and stop it backing up, you just need to remove the config file in `etc`. For example, to remove the config file for a server with the hostname 'webserver'

```bash
rm etc/webserver.conf
```

*Note that deleting the config file like this cannot be undone.* If you just want to disable the backups, you can just rename the config file. Only files ending with .conf get parsed so you could do

```bash
mv etc/webserver.conf etc/webserver.disabled
```


## Changing backup time
The backups are set a cron jobs in the root user's cron tab. The defaults are 06:00 every day for daily backups, 04:00 every Sunday for weekly backups and 02:00 on the first of every month for monthly backups. 

These times can be changed by editing the crontab entries using `crontab -e`


## Backup locations
The location of the backups is set in `backup.conf` with the default being `/backups`

Note that if you change the backup location after adding some servers, you will need to manually change it in the config file for those servers in `etc`

The backups are stored in sub-directories in the format time-period.increment, e.g. daily.0, and under that is the name of the server, e.g. /backups/daily.0/webserver. There are also symlinks under /backups which use the format _date-time_ to point to the backup directories, e.g. /backups/20180402-0605/webserver. This give the option to browse to backups using either the increment number or the date and time of the backup.


## Change backup retention
The default retention periods for the backups are
* daily: 7
* weekly: 4
* monthly: 6

These can be changed in the backup config files. If you want to change the retention period for all newly added server then edit the file etc/rsnapshot.tpl, e.g. to change the daily retention to 10 snapshots change the line

```
daily	7
```

to instead read

```
daily	10
```

*Note that tabs must be used between the label and the number, spaces will cause an error*

If you want to change the retention for a single server you can make the same change in the config file for that server.

To change the retention period for all existing server, you can use a command like this to change all of the config files at once

```bash
cd /opt/backup-wizard/etc
sed -i 's/daily\t7/daily\t10/g' *.conf
```

This command will also change `daily	7` to `daily	10`: the first parameter in the sed string is the existing value, the second parameter is that value it will be changed to and the `\t` represents a tab.
