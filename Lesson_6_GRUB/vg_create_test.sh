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

echo "Введите число логических томов, из которых должна состоять группа $vg_name"
read lv_num
LV_NAME=()
LV_VOL=()
for j in `seq 1 $lv_num`; do
    echo "Ведите название $j -ого логического тома"
    read lv_name
    LV_NAME+=($lv_name)
    if [[ $j -lt $lv_num ]]; then
        echo "Соответствующий объём в Гигобайтах"
        read lv_vol
        LV_VOL+=($lv_vol)
    fi    
done    

echo "Создать группу $vg_name  из Дисков: ${ARRAY_HDD[@]} yes/no?"
read answer

Answer() {   #функция ответа с проверкой на ввод пользователя.
 
if [[ $answer = "yes" ]]; then
    echo "Starting...."
    for hdd_name in "${ARRAY_HDD[@]}"; do
       pvcreate $hdd_name 
    done
       vgcreate $vg_name ${ARRAY_HDD[@]}
       
z=${#LV_NAME[@]}
let "q = $z-1"

LV_CREATE_XFS () {
for ((t=0; t<$q; t++))
do
{
   lvcreate -n ${LV_NAME[$t]} -L${LV_VOL[$t]}G $vg_name
   mkfs.xfs /dev/$vg_name/${LV_NAME[$t]}
}
done
   lvcreate -l100%FREE -n ${LV_NAME[$q]} $vg_name
   mkfs.xfs /dev/$vg_name/${LV_NAME[$q]}
}           

LV_CREATE_EXT4 () {
for ((t=0; t<$q; t++))
do
{
   lvcreate -n ${LV_NAME[$t]} -L${LV_VOL[$t]}G $vg_name
   mkfs.ext4 /dev/$vg_name/${LV_NAME[$t]}

}
done
   lvcreate -l100%FREE -n ${LV_NAME[$q]} $vg_name
    mkfs.ext4 /dev/$vg_name/${LV_NAME[$t]}

}           
       echo "Укажите тип файловой системы под которую будет отформатирован раздел:"
       echo "1   xfs"
       echo "2   ext4" 
       read fs_type

          case $fs_type in
             1) 
                LV_CREATE_XFS 
               ;;
             2)      
               LV_CREATE_EXT4
               ;;
             *)
              echo "Введите целое число 1 или  2"
               ;;
         esac  
elif [[ $answer = "y" ]]; then
  echo "Наберите полностью yes..."
  read answer
  Answer
else
  echo "Попробуйте еще раз."
fi
    }

Answer
