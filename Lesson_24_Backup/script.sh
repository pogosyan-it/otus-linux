#!/bin/bash

yum install epel-release -y
yum install borgbackup nano -y

sed -i -e 's/\#PermitRootLogin\ yes/PermitRootLogin\ yes/g' /etc/ssh/sshd_config
sed -i -e 's/\#PubkeyAuthentication\ yes/PubkeyAuthentication\ yes/g' /etc/ssh/sshd_config
sed -i -e 's/GSSAPIAuthentication\ yes/\#GSSAPIAuthentication\ yes/g' /etc/ssh/sshd_config
sed -i -e 's/GSSAPICleanupCredentials\ no/\##GSSAPICleanupCredentials\ no/g' /etc/ssh/sshd_config


ip=$(ip r | grep '192\.168\.11\.160' | awk '{print $9}' |  rev |sed -e 's/\..*//g' | rev)
if [[ $ip -eq 160 ]]; then
  echo ';' | sfdisk /dev/sdb
  mkfs.xfs /dev/sdb1
  mkdir /var/backup1
  mount /dev/sdb1 /var/backup1
  echo "/dev/sdb1  /var/backup1  xfs	defaults	0	0" >> /etc/fstab
  mkdir  -p /root/.ssh
  cp /vagrant/authorized_keys /root/.ssh/
  chown -R root:root /root/.ssh/
  chmod -R 700 /root/.ssh/
  systemctl restart sshd
else
   mkdir -p /root/.ssh
   cp -r /vagrant/.ssh_client/* /root/.ssh/
   echo "Host *" > ~/.ssh/config
   echo " StrictHostKeyChecking no" >> ~/.ssh/config          #Не спрашивать добовлять или нет отпечаток (fingerprint)
   chown -R root:root /root/.ssh/
   chmod -R 700 /root/.ssh/
   systemctl restart sshd
   mkdir -p /var/log/borg
   mv /vagrant/borglog.conf /etc/logrotate.d/
   chown root:root /vagrant/borg.sh
   echo "*/5 * * * * root bash /vagrant/borg.sh" >> /etc/crontab
fi

