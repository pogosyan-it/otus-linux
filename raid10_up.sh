#/bin/bash
# Disk amount
check_array=$(cat /proc/mdstat | grep md0 | cut -c 1-3)
if [[ $check_array != "md0" ]]; then
 N=$(lsscsi | grep HARDDISK | grep -v sda | wc -l)
 if  [[ $N -eq 5 ]]; then
    ARRAY_HDD=()
    for i in $(lsscsi | grep HARDDISK | grep -v sda | awk '{print $7}'); do
       mdadm --zero-superblock --force $i
       ARRAY_HDD+=($i)
    done
  #echo ${ARRAY_HDD[@]}
  mdadm --create --verbose /dev/md0 --level=10 --raid-device=4 ${ARRAY_HDD[0]} ${ARRAY_HDD[1]} ${ARRAY_HDD[2]} ${ARRAY_HDD[3]} --spare-device=1 ${ARRAY_HDD[4]}
  #mdadm -D /dev/md0
  mkdir -p /etc/mdadm/
  echo "DEVICE partitions" >> /etc/mdadm/mdadm.conf
  mdadm --datail --scan --verbose | awk '/ARRAY/{print}' >> /etc/mdadm/mdadm.conf

  parted -s /dev/md0 mklabel gpt

   for j in $(seq 1 5); do
     parted /dev/md0 mkpart primary ext4 $((20*$(($j-1))))% $((20*$j))%
     mkfs.ext4 /dev/md0p$j
     mkdir -p /raid/part$j
     mount /dev/md0p$j /raid/part$j
   done

 else
    echo "FALSE"
 fi
else
   echo "RAID $check_array exists"
fi
