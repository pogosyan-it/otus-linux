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
4.  Размер хранилища: `zpool list | grep otus | awk '{print $2}'` -- 480M <br/>
    Тип пула: mirror-0 <br/> 
    zpool status <br/>
  pool: otus <br/>
 state: ONLINE <br/>
  scan: none requested <br/>
config: <br/>

        NAME                                   STATE     READ WRITE CKSUM
        otus                                   ONLINE       0     0     0
          mirror-0                             ONLINE       0     0     0
            /zfspool/import/zpoolexport/filea  ONLINE       0     0     0
            /zfspool/import/zpoolexport/fileb  ONLINE       0     0     0

`zfs get recordsize,compression,checksum otus`
NAME  PROPERTY     VALUE      SOURCE         <br/>
otus  **recordsize   128K**       local      <br/>
otus  **compression  zle**       local       <br/>
otus  **checksum     sha256**     local       <br/>

