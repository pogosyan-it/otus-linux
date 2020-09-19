#/bin/bash 

Host="192.168.11.160"
backup_dir="/etc"
backup_repo="/var/backup1/"

borg list root@$Host:$backup_repo

if [[ $? -eq 2 ]]; then
    BORG_NEW_PASSPHRASE= borg init --encryption=keyfile -v root@$Host:$backup_repo  
else
   echo "Repo created"
fi

borg create -v --stats root@$Host:$backup_repo::$(hostname)_'{now:%Y-%m-%d-%H-%M}' $backup_dir   &>>/var/log/borg/borg.log
borg prune -v --list --keep-within=4H --keep-daily=92 --keep-monthly=9 root@$Host:$backup_repo &>>/var/log/borg/borg.log
