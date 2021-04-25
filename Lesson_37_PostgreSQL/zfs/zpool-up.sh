#!/bin/bash

 z_import=$(zpool import  2>&1>/dev/null)
 res="no pools available to import"
 if [[ $z_import != $res ]]; then
    #/usr/sbin/zpool import dwhcbd.1 
   for zpool_name in `/usr/sbin/zpool import | /usr/bin/grep pool | /usr/bin/grep -v action | /usr/bin/awk '{print $2}'`; do
      /usr/sbin/zpool import $zpool_name
   done 
 fi


#[ "no pools available to import" = "`/usr/sbin/zpool import 2>&1>/dev/null`" ] || /usr/sbin/zpool import dwhcbd.1
