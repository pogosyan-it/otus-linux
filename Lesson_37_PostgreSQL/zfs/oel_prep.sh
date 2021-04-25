#!/bin/bash 
## Настройка сервера ORACLE LINUX for DBA - подготовка к установке zfs
#telnet cpmsk.rgs.ru 259
yum update -y
mv  /tmp  /tmp-
mkdir -p /tmp  /export/share /store /opt/oracle /opt/pgsql
#----------------------------------------- rm -rf /tmp-
cp /etc/fstab /etc/fstab_bak
yum remove kernel-uek-5* -y

localectl set-locale LANG=en_US.UTF-8
dnf install langpacks-en glibc-all-langpacks -y
dnf install glibc-langpack-en nano nfs-utils -y

sed -i -e 's/defaults/defaults,noatime/g' /etc/fstab
#sed -i -e 's/umask=0077,shortname=winnt/noauto,umask=0077,shortname=winnt/g' /etc/fstab

old_swap=$(cat /etc/fstab | grep 'swap')
new_swap=$(echo $old_swap | sed 's/defaults,noatime/defaults/g')
sed -i -e "s|$old_swap|$new_swap|g" /etc/fstab

num1=$(cat /etc/fstab | grep -n root |  sed -e 's/:.*//g')
let "num=num1+1"
tmp="tmpfs /tmp  tmpfs defaults,noatime,size=1001M,mode=1777,gid=sys 0 0"
sed -i "${num}i\\$tmp" /etc/fstab 

echo "dis.rgs.ru:/export/pgsql /opt/pgsql nfs exec,ro        0 0" >> /etc/fstab
echo "dis.rgs.ru:/export/oracle /opt/oracle nfs noauto,exec,ro        0 0" >> /etc/fstab
echo "dis.rgs.ru:/export/share /export/share nfs noauto,noexec,rw        0 0" >> /etc/fstab

#echo "store-cifs.rgs.ru:/pgsql-export /export nfs exec,rw        0 0" >> /etc/fstab
#echo "k7-na-nfs-store.rgs.ru:/store   /store  nfs user,rw,noauto 0 0" >> /etc/fstab

#----------------------------------------- mount -a

sed -i -e 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config

systemctl stop firewalld
systemctl disable firewalld

systemctl stop kdump
systemctl disable kdump

yum install http://download.zfsonlinux.org/epel/zfs-release.el8_3.noarch.rpm -y
gpg --quiet --with-fingerprint /etc/pki/rpm-gpg/RPM-GPG-KEY-zfsonlinux

cat /etc/yum.repos.d/zfs.repo | grep 'zfs-kmod' -A 6
cat /etc/yum.repos.d/zfs.repo | grep 'zfs-kmod' -A 6 > /etc/yum.repos.d/zfs-kmod.repo
mv /etc/yum.repos.d/zfs.repo /root/zfs_bak.repo
mv /etc/yum.repos.d/zfs-kmod.repo /etc/yum.repos.d/zfs.repo
sed -i -e 's/enabled=0/enabled=1/g' /etc/yum.repos.d/zfs.repo

yum install zfs -y

depmod -a

/sbin/modprobe zfs

lsmod | grep zfs
