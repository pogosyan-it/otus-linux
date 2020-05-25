#!/bin/bash

sudo yum install nfs-utils
sudo systemctl start rpcbind
sudo systemctl enable rpcbind
sudo mkdir /mnt/nfs-share
sudo mount -t nfs 192.168.11.122:/mnt/storage /mnt/nfs-share
sudo chmod 0777 /etc/fstab
sudo echo "192.168.11.122:/mnt/storage  /mnt/nfs-share     nfs    defaults    0 0" >> /etc/fstab
sudo chmod u-x,g-wx,o-wx /etc/fstab
