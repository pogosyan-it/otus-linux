#!/bin/bash

random_flud () {
str=$(cat /etc/sysconfig/serv_mon.conf | grep 'key_phrase' | sed 's|.*\=||' | tr -d '"')
echo $str >> /var/log/messages
sleep $[ ( $RANDOM % 10 )  + 30 ]s
random_flud
}
random_flud
