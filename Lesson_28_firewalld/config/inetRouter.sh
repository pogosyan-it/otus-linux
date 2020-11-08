#!/bin/bash
sudo -i
yum install -y epel-release
yum install libpcap* -y
rpm -ivU http://li.nux.ro/download/nux/dextop/el7Server/x86_64/knock-server-0.7-1.el7.nux.x86_64.rpm
echo "net.ipv4.conf.all.forwarding=1" >> /etc/sysctl.conf
sudo sysctl -p
yum install -y iptables-services
systemctl enable iptables
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT
iptables -t nat -F
iptables -t mangle -F
iptables -F
iptables -X
iptables -t nat -A POSTROUTING ! -d 192.168.0.0/16 -o eth0 -j MASQUERADE
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -p tcp --dport 22 -j REJECT
service iptables save
systemctl start iptables
echo "192.168.0.0/16 via 192.168.255.2 dev eth1" > /etc/sysconfig/network-scripts/route-eth1

mv /vagrant/config/inetRouter_knock.conf /etc/knockd.conf
chown root:root /etc/knockd.conf 
chmod 600 /etc/knockd.conf
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config

systemctl restart sshd
systemctl start knockd.service
systemctl enable knockd.service
