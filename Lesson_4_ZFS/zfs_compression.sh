
#!/bin/bash

cd /home/

zpool_name=$(zpool list | awk '{print }' | tail -n 1 | awk '{print $1}')
zpool_char=$(zpool list | awk '{print }' | tail -n 1 | awk '{print $1}'|awk '{print length}')
let n="$zpool_char + 2"
for i in $(zfs list | grep "$zpool_name"\/. | awk '{print $1 }' | cut -c "$n"-); do
    time1="`date +%s`"
    cp -r linux-5.6.9 /$zpool_name/$i
    vol=$(du -sh /$zpool_name/$i/linux* | awk '{print $1}')
    time2="`date +%s`"
    let delta="$time2 - $time1" 
    echo "$i --->$delta ---->$vol" >> zfs_comp.stat 
done

