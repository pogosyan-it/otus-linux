#!/bin/bash
#cd /vagrant
sudo cp /vagrant/logmon.service /vagrant/logmon.timer /etc/systemd/system/
sudo cp /vagrant/serv_mon.conf /etc/sysconfig/
sudo bash /vagrant/random_log.sh &

systemctl daemon-reload
systemctl enable logmon.timer
systemctl start  logmon.timer
systemctl enable logmon.service
systemctl start  logmon.service

sudo cp /vagrant/spawn-fcgi /vagrant/httpd-conf1 /vagrant/httpd-conf2 /etc/sysconfig/

httpd="/etc/sysconfig/httpd"
if [ -f $httpd ]; then
   sudo rm /etc/sysconfig/httpd /etc/httpd/conf/httpd.conf
fi


sudo cp /vagrant/httpd-inst-1.conf /vagrant/httpd-inst-2.conf /etc/httpd/conf/
sudo cp /vagrant/spawn-fcgi.service /vagrant/httpd@.service /etc/systemd/system/

systemctl daemon-reload
systemctl start  spawn-fcgi.service
systemctl enable spawn-fcgi.service
systemctl start httpd@httpd-inst-1.service


str=$(cat /etc/sysconfig/serv_mon.conf | grep 'key_phrase' | sed 's|.*\=||' | tr -d '"')

num=$(cat /var/log/messages | grep "$str" | wc -l )
if [[ $num -eq 0 ]]; then
   echo "`date`  --> Key Phrase was not found in /var/log/masseges" >> /home/vagrant/report.txt
else
   echo "`date`  --> Key Phrase ($str) was found in /var/log/masseges $num times" >> /home/vagrant/report.txt
fi

