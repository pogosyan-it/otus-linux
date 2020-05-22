# **ZFS - определение алгоритма наилучшего сжатия**


1. Создаем zfs pool:<br/>
   `zpool create zfspool /dev/sdb /dev/sdc /dev/sdd /dev/sde /dev/sdf /dev/sdb /dev/sda2` <br/>
    pool: zfspool    <br/>
 state: ONLINE <br/>
  scan: none requested <br/>
config:<br/>
  NAME        STATE     READ WRITE CKSUM <br/>
        zfspool     ONLINE       0     0     0  <br/>
          sda       ONLINE       0     0     0 <br/>
          sdb       ONLINE       0     0     0 <br/>
          sdc       ONLINE       0     0     0 <br/>
          sdd       ONLINE       0     0     0 <br/>
          sde       ONLINE       0     0     0 <br/>
          sda2       ONLINE       0     0     0 <br/>

2. Создаем файловые системы gzip_N,lz4,zle, lzjb: <br/>
   `zfs create zfspool/gzip_N где N от 1 до 9`
   Получаем: <br/>
   zfs list <br/>
NAME            USED  AVAIL     REFER  MOUNTPOINT <br/>
zfspool         750M  31,8G       35K  /zfspool <br/>
zfspool/gzip1   278M  31,8G      278M  /zfspool/gzip1 <br/>
zfspool/gzip2    24K  31,8G       24K  /zfspool/gzip2 <br/>
zfspool/gzip3    24K  31,8G       24K  /zfspool/gzip3 <br/>
zfspool/gzip4    24K  31,8G       24K  /zfspool/gzip4 <br/>
zfspool/gzip5    24K  31,8G       24K  /zfspool/gzip5 <br/>
zfspool/gzip6    24K  31,8G       24K  /zfspool/gzip6 <br/>
zfspool/gzip7    24K  31,8G       24K  /zfspool/gzip7 <br/>
zfspool/gzip8    24K  31,8G       24K  /zfspool/gzip8 <br/>
zfspool/gzip9    24K  31,8G       24K  /zfspool/gzip9 <br/>
zfspool/lz4     472M  31,8G      472M  /zfspool/lz4 <br/>
zfspool/lzjb     24K  31,8G       24K  /zfspool/lzjb <br/>
zfspool/zle      24K  31,8G       24K  /zfspool/zle <br/>

3. На каждую файловую систему устанавливаем соответствующее сжатие: <br/>
   `for i in ``seq 1 9``; do zfs set compression=gzip-$i zfspool/gzip$i` <br/>
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
    






