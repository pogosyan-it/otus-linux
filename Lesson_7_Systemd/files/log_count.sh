#!/bin/bash

str=$(cat /etc/sysconfig/serv_mon.conf | grep 'key_phrase' | sed 's|.*\=||' | tr -d '"')

num=$(cat /var/log/messages | grep "$str" | wc -l )
if [[ $num -eq 0 ]]; then
   echo "`date`  --> Key Phrase was not found in /var/log/masseges" >> /home/vagrant/report.txt
else
   echo "`date`  --> Key Phrase ($str) was found in /var/log/masseges $num times" >> /home/vagrant/report.txt
fi
