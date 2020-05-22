# **Перенос системы на RAID 1**

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
7.  Бэкапим текущий файл initramfs и созбираем новый: <br/>
    `mv /boot/initramfs-3.10.0-957.12.2.el7.x86_64.img /boot/initramfs-3.10.0-957.12.2.el7.x86_64.img_bak`
    `dracut /boot/initramfs-$(uname -r).img $(uname -r)`
8.  Чтобы активировать RAID при загрузке в файле /etc/default/grub дописываем в строке GRUB_CMDLINE_LINUX параметр  rd.auto=1:
     `GRUB_CMDLINE_LINUX="no_timer_check console=tty0 console=ttyS0,115200n8 net.ifnames=0 biosdevname=0 elevator=noop    crashkernel=auto rd.auto=1"`
9.  Переписываем конфиг GRUB и устанавливаем загрузчик на диск /dev/sdg: <br/>
    `grub2-mkconfig -o /boot/grub2/grub.cfg`<br/>
    `grub2-install /dev/sdg`<br/>
10. Во время перезагрузки выбираем загрузку с нового диска и, после входа с систему, видим: <br/>
    NAME    MAJ:MIN RM  SIZE RO TYPE  MOUNTPOINT <br/>
 sda        8:0    0   40G  0 disk <br/>
  └─sda1    8:1    0   40G  0 part <br/>
 sdg        8:96   0   7,3G  0 disk <br/>
  └─sdg1    8:97   0   7,3G  0 part <br/>
    └─md0   9:0    0   7,3G  0 raid1 / <br/>
11. Удаляем раздел /dev/sda1 и создаем новый раздел размером 7,3GB, равным разделу sdg1: <br/>
   sda       8:0    0   40G  0 disk <br/>
  ├─sda1    8:1    0  7,3G  0 part <br/>
  └─sda2    8:2    0 32,7G  0 part<br/>
12. Добавляем /dev/sda1 в массив: <br/>
    mdadm --manage /dev/md0 --add /dev/sda1 <br/>
Получаем: <br/>
sda       8:0    0   40G  0 disk <br/>
├─sda1    8:1    0  7,3G  0 part  <br/>
│ └─md0   9:0    0  7,3G  0 raid1 / <br/>
└─sda2    8:2    0 32,7G  0 part    <br/>
sdg       8:96   0  7,3G  0 disk    <br/>
└─sdg1    8:97   0  7,3G  0 part    <br/>
  └─md0   9:0    0  7,3G  0 raid1 /  <br/>
  
13. Устанавливаем загрузчик (после окончания ребилда) на /dev/sda и пересобираем grub <br/>
 `grub2-install /dev/sda`<br/>
 `grub2-mkconfig -o /boot/grub2/grub.cfg`<br/>
После чего система нормально перезагрузится. 
    






