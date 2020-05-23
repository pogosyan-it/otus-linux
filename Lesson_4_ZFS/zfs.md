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
   for i in `seq 1 9`; do zfs set compression=gzip-$i zfspool/gzip$i <br/>
   `zfs set compression=lz4 zfspool/lz4` <br/>
   NAME           PROPERTY     VALUE     SOURCE <br/>
   zfspool/gzip1  compression  gzip-1    local  <br/>
   zfspool/gzip2  compression  gzip-2    local  <br/>
   zfspool/gzip3  compression  gzip-3    local  <br/>
   zfspool/gzip4  compression  gzip-4    local  <br/>
   zfspool/gzip5  compression  gzip-5    local  <br/>
   zfspool/gzip6  compression  gzip-6    local  <br/>
   zfspool/gzip7  compression  gzip-7    local  <br/>
   zfspool/gzip8  compression  gzip-8    local  <br/>
   zfspool/gzip9  compression  gzip-9    local  <br/>
   zfspool/lz4  compression    lz4       local  <br/>
   zfspool/lzjb  compression   lzjb      local  <br/>
   zfspool/zle  compression    zle       local  <br/>

4. Скопируем архив ядра на каждую ФС и замерим время и размер папки, для этого используем простой скрипт: <br/>
   https://github.com/pogosyan-it/otus-linux/blob/master/Lesson_4_ZFS/zfs_compression.sh <br/>
   Результат его работы запишем в файл: <br/>
   https://github.com/pogosyan-it/otus-linux/blob/master/Lesson_4_ZFS/zfs_comp.stat <br/>
   где в среднем столбце кол-во секунд, которое потребовалось чтобы скопировать разархивированную копию ядра.
   Легко видить, что лучше всех сжал gzip-9 и время у него для этого ушло не самое худшее.
   
**ZFS - импорт диска**
  
1.  Скачиваем (как это сделать с помощью wget я так и не понял) и распаковываем: <br/>
    `tar -zxvf zfs_task1.tar.gz` <br/>
2.  Импортируем: <br/>
    `zpool import -d zpoolexport/`<br/>
    onfig:<br/>

        otus                                   ONLINE
          mirror-0                             ONLINE
            /zfspool/import/zpoolexport/filea  ONLINE
            /zfspool/import/zpoolexport/fileb  ONLINE
    
3.  `zpool import -d zpoolexport/ otus` <br/>
      `zpool list` <br/>
     NAME      SIZE  ALLOC   FREE  CKPOINT  EXPANDSZ   FRAG    CAP  DEDUP    HEALTH  ALTROOT <br/>
     otus      480M  2,18M   478M        -         -     0%     0%  1.00x    ONLINE  - <br/>
     zfspool  33,6G  4,98G  28,6G        -         -     4%    14%  1.00x    ONLINE  - <br/>

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
    






