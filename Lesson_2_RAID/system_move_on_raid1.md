# **Перенос систпемы на RAID 1**

Имется система на /dev/sda1 которую необходимо перенести на RAID 1. В системе имеется один свободный диск /dev/sdg размером 7.3Gb: <br/> 
`NAME    MAJ:MIN RM  SIZE RO TYPE  MOUNTPOINT 
sda       8:0    0   40G  0 disk              
└─sda1    8:1    0   40G  0 part /
sdg       8:96   0  7,3G  0 disk`
Система занимает на диске /dev/sda1 меньше 7,3Gb иначе перенести ее было бы невозможно.
Так как диск всего 1 то мы можем создать RAID 1 с отсутствующим диском, после переноса системы от диска /dev/sda1 откусим 7,3GB  и восстановим массив.
1. Создаем раздел sdg1 на диске /dev/sdg с помощью fdisk и на этом разделе RAID 1:<br/>
   `dadm --create /dev/md0 --level=1 --metadata=0.9 --raid-devices=2 missing /dev/sdg1`
2. Форматируем в xfs и монтируем в /mnt:
   `mkfs.xfs -f /dev/md0 && mount /dev/md0 /mnt/`
3. Устанавливаем утилиту xfsdump и копируем системные файлы на /dev/md0: <br/>
   `yum install -y xfsdump`
   `xfsdump -J - /dev/sda1 | xfsrestore -J - /mnt`
4. В host системе запустить 2 команды: <br/>
   `vagrant plugin install vagrant-vbguest` <br/>
   `vagrant vbguest` <br/>

После запуска вм `(vagrant up)` shara заработает.
