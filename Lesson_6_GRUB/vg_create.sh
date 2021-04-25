#!/bin/bash
# Скрипт для создания группы томов (LVM) 


echo "Введите число дисков из которых хотите создать группу томов:"

read num
ARRAY_HDD=()
  for i in `seq 1 $num`; do  #в цикле осущесталяется перебор дисков в выбранной группе 
       echo "Выберите диск $i"
       fdisk -l | grep -E "\/dev\/sd[a-z]{1,2}:" | awk '{print $2,$3,$4 }' | cat -n
       read disk
       echo DISK_NUM=$disk
       ARRAY_HDD+=($(fdisk -l | grep -E "\/dev\/sd[a-z]{1,2}:" | awk '{print $2}'| head -n $disk | tail -n 1 | sed -e 's/\:*//g'))
       echo $(fdisk -l | grep -E "\/dev\/sd[a-z]{1,2}:" | awk '{print $2}'| head -n $disk | tail -n 1 | sed -e 's/\:*//g')

   done 

echo "Введите название группы томов LVM"
read vg_name

echo "Ведите название логического тома"
read store_name

echo "Создать группу $vg_name  из Дисков: ${ARRAY_HDD[@]} yes/no?"
read answer

Answer() {   #функция ответа с проверкой на ввод пользователя.
 
if [[ $answer = "yes" ]]; then
    echo "Starting...."
    for hdd_name in "${ARRAY_HDD[@]}"; do
       #echo $hdd_name 
       pvcreate $hdd_name 
    done
       vgcreate $vg_name ${ARRAY_HDD[@]}
       m_name="$vg_name"-"$store_name"
       echo "mount_point_name=$m_name"
       lvcreate -l100%FREE -n $store_name $vg_name
       echo "Укажите тип файловой системы под которую будет отформатирован раздел:"
       echo "1   xfs"
       echo "2   ext4" 
       read fs_type

          case $fs_type in
             1) 
                mkfs.xfs /dev/mapper/$m_name 
               ;;
             2)      
                mkfs.ext4 /dev/mapper/$m_name 
               ;;
             *)
              echo "Введите целое число от 1 до 2"
               ;;
         esac  
       #mkdir -p /media/$store_name
       #mount /dev/mapper/$m_name /media/$store_name
elif [[ $answer = "y" ]]; then
  echo "Наберите полностью yes..."
  read answer
  Answer
else
  echo "Попробуйте еще раз."
fi
    }

Answer
