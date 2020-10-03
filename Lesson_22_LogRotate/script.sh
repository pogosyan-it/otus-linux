#!/bin/bash

SET_TO_ALL () {
yum install epel-release -y
yum install rsyslog chrony auditd audispd-plugins -y
systemctl enable chronyd
systemctl enable auditd
service auditd start
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
   mv /vagrant/audisp-remote_web.conf /etc/audisp/audisp-remote.conf
   chown root:root /etc/rsyslog.conf /etc/nginx/nginx.conf /etc/audisp/audisp-remote.conf
   sed -i -e 's/^active =.*/active = yes/g' /etc/audisp/plugins.d/au-remote.conf
   echo "-w /etc/nginx/nginx.conf -p wa" > /etc/audit/rules.d/audit.rules
   echo "-w /etc/nginx -p r" >> /etc/audit/rules.d/audit.rules
   systemctl start nginx
   systemctl restart rsyslog
   service auditd restart
else
     SET_TO_ALL
     mv /vagrant/rsyslog.conf_srv /etc/rsyslog.conf
     sed -i -e 's/\#\#tcp_listen_port =.*/tcp_listen_port = 60/g' /etc/audit/auditd.conf
     chown root:root /etc/rsyslog.conf
     systemctl restart rsyslog
     service auditd  restart 
fi

