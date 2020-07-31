#!/bin/bash

/usr/sbin/groupadd admin

for (( i=1; i<=10; i++ )); do
/usr/sbin/useradd user$i
echo "passw"$i"rd" | passwd --stdin user$i
let "j=$i%3"
if [[ $j -eq 1 ]]; then 
   /usr/bin/gpasswd -a user$i admin
fi
done

sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/g' /etc/ssh/sshd_config
systemctl restart sshd.service

user_array=($(cat /etc/passwd | grep -e '\/bin\/sh\|\/bin\/bash' | sed -e 's/:.*//g'))
for user in ${user_array[@]}; do
  user_alow=$(id $user | grep -v admin )
   if [[ -n $user_alow && "$user" != "root" ]]; then
       echo "*;*;$user;!Wd0000-2400" >> /etc/security/time.conf
   fi
done
n=$(cat /etc/pam.d/sshd | grep -n "pam_nologin.so" |  sed -e 's/:.*//g')
string="account    required     pam_time.so"
let "j=$n+1"
sed -i "${j}i\\$string" /etc/pam.d/sshd


yum install polkit docker -y
cp /vagrant/01-systemd.rules /etc/polkit-1/rules.d/
chown root:root /etc/polkit-1/rules.d/01-systemd.rules
su vagrant 
systemctl start docker.service
systemctl status docker.service
