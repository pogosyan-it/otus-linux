#!/bin/bash

vg_old=$(lsblk | grep '\/' | grep -v '\/.' | awk '{print $1}' | cut -c 3- |  sed -e 's/-.*//g')
lv_root=$(lsblk | grep '\/' | grep -v '\/.' | awk '{print $1}' | cut -c 3- | sed 's|.*-||')
vg_new=OtusNewRoot
vgrename $vg_old $vg_new
sed -i "s/$vg_old/$vg_new/g" /etc/fstab
sed -i "s/$vg_old/$vg_new/g" /etc/default/grub
mount /dev/mapper/"$vg_new"-"$lv_root" /mnt

for dir in /proc/ /sys/ /dev/ /run/ /boot/; do 
    mount --bind $dir /mnt/$dir
done

cat << EOF | chroot /mnt
  grub2-mkconfig -o /boot/grub2/grub.cfg
exit
EOF

sed -i "s/$vg_old/$vg_new/g" /boot/grub2/grub.cfg
mkinitrd -f -v /boot/initramfs-$(uname -r).img $(uname -r)
vgs




