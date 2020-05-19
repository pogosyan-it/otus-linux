# **Перенос систпемы на RAID 1**

Имется система на /dev/sda1 которую необходимо перенести на RAID 1. В системе имеется один свободный диск /dev/sdg размером 7.3Gb: <br/> 
`NAME    MAJ:MIN RM  SIZE RO TYPE  MOUNTPOINT` <br/>
`sda       8:0    0   40G  0 disk `             <br/>
`└─sda1    8:1    0   40G  0 part     /`         <br/>
`sdg       8:96   0  7,3G  0 disk`              <br/>
Система занимает на диске /dev/sda1 меньше 7,3Gb иначе перенести ее было бы невозможно.
Так как диск всего 1 то мы можем создать RAID 1 с отсутствующим диском, после переноса системы от диска /dev/sda1 откусим 7,3GB  и восстановим массив.
1. Создаем раздел sdg1 на диске /dev/sdg с помощью fdisk и на этом разделе RAID 1:<br/>
   `dadm --create /dev/md0 --level=1 --metadata=0.9 --raid-devices=2 missing /dev/sdg1`
2. Форматируем в xfs и монтируем в /mnt:
   `mkfs.xfs -f /dev/md0 && mount /dev/md0 /mnt/`
3. Устанавливаем утилиту xfsdump и копируем системные файлы на /dev/md0: <br/>
   `yum install -y xfsdump` <br/>
   `xfsdump -J - /dev/sda1 | xfsrestore -J - /mnt` <br/>
4. Монтируем информацию о текущей системе в наш новый корень и делаем chroot в него: <br/>
   `for i in /proc/ /sys/ /dev/ /run/ /boot/; do mount --bind $i /mnt/$i; done` <br/>
   `chroot /mnt/` <br/>
5. Заменяем в `/etc/fstab` UUID диска `/dev/sda1 ` <br/>
   `blkid | grep sda1 | awk '{print $2}'` <br/>
          на UUID `/dev/md0` <br/>
   `blkid | grep md0 | awk '{print $2}'`  <br/>
6.  Создаем конфиг. файл массива:
    `mdadm --detail --scan > /etc/mdadm.conf`
7.  Бэкапим текущий файл initramfs и созбираем новый:
    `mv /boot/initramfs-3.10.0-957.12.2.el7.x86_64.img /boot/initramfs-3.10.0-957.12.2.el7.x86_64.img_bak`
    `dracut /boot/initramfs-$(uname -r).img $(uname -r)`
    


