#!/bin/bash
#cd /vagrant
sudo mv /vagrant/logmon.service /etc/systemd/system/
sudo mv /vagrant/logmon.timer /etc/systemd/system/
sudo mv /vagrant/serv_mon.conf /etc/sysconfig/
sudo bash /vagrant/random_log.sh &

systemctl daemon-reload
systemctl enable logmon.timer
systemctl start  logmon.timer
systemctl enable logmon.service
systemctl start  logmon.service

sudo mv /vagrant/spawn-fcgi /etc/sysconfig/

httpd="/etc/sysconfig/httpd"
if [ -f $httpd ]; then
   sudo cp /etc/sysconfig/httpd  /etc/sysconfig/httpd-conf1
   sudo cp /etc/sysconfig/httpd  /etc/sysconfig/httpd-conf2
   sudo mv /etc/sysconfig/httpd  /etc/sysconfig/httpd.bk
   cat /vagrant/httpd-conf1 > /etc/sysconfig/httpd-conf1
   cat /vagrant/httpd-conf2 > /etc/sysconfig/httpd-conf2
   sudo cp /etc/httpd/conf/httpd.conf /etc/httpd/conf/httpd-inst-1.conf
   sudo cp /etc/httpd/conf/httpd.conf /etc/httpd/conf/httpd-inst-2.conf
   sudo mv /etc/httpd/conf/httpd.conf /etc/httpd/conf/httpd.conf.bk
   cat /vagrant/httpd-inst-1.conf > /etc/httpd/conf/httpd-inst-1.conf
   cat /vagrant/httpd-inst-2.conf > /etc/httpd/conf/httpd-inst-2.conf
   sudo cp /usr/lib/systemd/system/httpd.service /etc/systemd/system/httpd@.service
   sudo cat /vagrant/httpd@.service > /etc/systemd/system/httpd@.service
fi


#sudo rm -rf  /vagrant/*.*

systemctl daemon-reload
systemctl start  spawn-fcgi.service
systemctl enable spawn-fcgi.service
systemctl start httpd@httpd-conf1.service
systemctl start httpd@httpd-conf2.service


str=$(cat /etc/sysconfig/serv_mon.conf | grep 'key_phrase' | sed 's|.*\=||' | tr -d '"')

num=$(cat /var/log/messages | grep "$str" | wc -l )
if [[ $num -eq 0 ]]; then
   echo "`date`  --> Key Phrase was not found in /var/log/masseges" >> /home/vagrant/report.txt
else
   echo "`date`  --> Key Phrase ($str) was found in /var/log/masseges $num times" >> /home/vagrant/report.txt
fi

