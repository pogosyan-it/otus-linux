#!/bin/bash

SET_TO_ALL () {
yum install epel-release -y
yum install rsyslog chrony nano -y
systemctl enable chronyd
systemctl start chronyd
systemctl enable rsyslog
systemctl start rsyslog
setenforce 0
sed -i -e 's/^SELINUX=.*/SELINUX=disabled/g' /etc/selinux/config
cp /usr/share/zoneinfo/Europe/Moscow /etc/localtime
}

ip=$(ip r | grep '192\.168\.11\.170' | awk '{print $9}' |  rev |sed -e 's/\..*//g' | rev)
if [[ $ip -eq 170 ]]; then
   SET_TO_ALL
   yum install nginx -y
   systemctl enable nginx
   mv /vagrant/nginx.conf /etc/nginx/nginx.conf
   mv /vagrant/rsyslog.conf_web /etc/rsyslog.conf
   mv /vagrant/10-nginx.conf /etc/rsyslog.d/nginx.conf
   chown root:root /etc/rsyslog.d/nginx.conf /etc/rsyslog.conf /etc/nginx/nginx.conf
   systemctl start nginx
   systemctl restart rsyslog
else
     SET_TO_ALL
     mv /vagrant/rsyslog.conf_srv /etc/rsyslog.conf
     chown root:root /etc/rsyslog.conf
     systemctl restart rsyslog
fi

