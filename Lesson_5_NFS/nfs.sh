#!/bin/bash
ip=$(cat -n /etc/sysconfig/network-scripts/ifcfg-eth1 | head -n 6 | tail -n 1 | rev | cut -c 1-3 | rev)

if [[ $ip -eq 121 ]]; then
  sudo yum install -y net-tools portmap nfs-utils
  sudo systemctl enable rpcbind nfs-server firewalld
  sudo systemctl start rpcbind nfs-server firewalld
  sudo firewall-cmd --permanent --zone=public --add-service=nfs3
  sudo firewall-cmd --permanent --zone=public --add-service=ssh
  sudo firewall-cmd --permanent --zone=public --add-service=rpc-bind
  sudo firewall-cmd --permanent --zone=public --add-service=mountd 
  sudo firewall-cmd --reload
  sudo mkdir  -p /mnt/storage
  sudo chown -R nfsnobody:nfsnobody /mnt/storage
  sudo chmod -R 777 /mnt/storage 
  sudo chmod 0777 /etc/exports /etc/hosts /etc/hostname
  sudo echo "nfs-server" > /etc/hostname
  sudo echo "192.168.11.121  nfs-server.otus.ru      nfs-server" > /etc/hosts
  sudo echo "/mnt/storage           192.168.11.122(rw,sync,no_root_squash,no_subtree_check)" > /etc/exports
  sudo chmod u-x,g-wx,o-wx /etc/exports /etc/hosts /etc/hostname
  sudo systemctl restart firewalld.service
  sudo exportfs -r
else
  sudo yum install -y nfs-utils net-tools
  sudo systemctl start rpcbind
  sudo systemctl enable rpcbind
  sudo mkdir -p /mnt/nfs-share
  sudo mount -o udp 192.168.11.121:/mnt/storage /mnt/nfs-share/
  sudo chmod 0777 /etc/fstab /etc/hosts /etc/hostname
  sudo echo "nfs-server" > /etc/hostname
  sudo echo "192.168.11.122  nfs-client.otus.ru      nfs-client" > /etc/hosts
  sudo echo "192.168.11.121:/mnt/storage /mnt/nfs-share nfs (rw,relatime,vers=3,rsize=32768,wsize=32768,namlen=255,hard,proto=udp,timeo=11,retrans=3,sec=sys,mountaddr=192.168.11.121,mountvers=3,mountport=20048,mountproto=udp,local_lock=none,addr=192.168.11.121)" >> /etc/fstab
  sudo mount -a
  sudo chmod u-x,g-wx,o-wx /etc/fstab  
fi
