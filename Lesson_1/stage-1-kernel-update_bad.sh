#!/bin/bash
#Install packages
yum -y update &&
yum install -y ncurses-devel make gcc bc bison flex elfutils-libelf-devel openssl-devel grub2 wget
#download kernel sources
mkdir -p /media/linux_sources
cd /media/linux_sources
wget https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-5.6.6.tar.xz
tar -xvf linux-5.6.6.tar.xz
cd linux-5.6.6
#Configuring
cp -v /boot/config-3.10.0-1127.el7.x86_64 .config
sed -i 's/CONFIG_BLK_DEV_SD=m/CONFIG_BLK_DEV_SD/g' .config
sed -i 's/CONFIG_SCSI_VIRTIO=m/CONFIG_SCSI_VIRTIO=y/g' .config
sed -i 's/CONFIG_VIRTIO_NET=m/CONFIG_BLK_DEV_SD=y/g' .config

make menuconfig # on this stage process hangs up. 

make bzImage &&
make modules &&
make &&
make install &&
make modules_install

sed -i 's/saved_entry=.*/saved_entry=CentOS Linux \(5\.6\.6\)\ 7 \(Core\)/g' /boot/grub2/grubenv

# Reboot VM

shutdown -r now
