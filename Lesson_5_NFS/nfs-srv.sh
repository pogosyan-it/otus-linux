#!/bin/bash


sudo yum install -y net-tools portmap nfs-utils
sudo systemctl enable rpcbind nfs-server firewalld
sudo systemctl start rpcbind nfs-server firewalld
sudo firewall-cmd --permanent --zone=public --add-service=nfs3
sudo firewall-cmd --permanent --zone=public --add-service=ssh
sudo firewall-cmd --permanent --zone=public --add-service=rpc-bind
#sudo firewall-cmd --permanent --zone=public --service=nfs3 --add-port=111/tcp
sudo firewall-cmd --permanent --zone=public --service=nfs3 --add-port=111/udp
sudo firewall-cmd --reload
sudo chown -R nfsnobody:nfsnobody /mnt/storage
sudo chmod -R 777 /mnt/storage
sudo chmod 0777 /etc/exports
sudo echo "/mnt/storage           192.168.11.122(rw,sync,no_root_squash,no_subtree_check)" >>/etc/exports
sudo chmod u-x,g-wx,o-wx /etc/exports
sudo systemctl restart firewalld.service
sudo exportfs -r
