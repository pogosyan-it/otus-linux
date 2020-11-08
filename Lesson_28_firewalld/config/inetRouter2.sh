#!/bin/bash

sudo -i

echo "net.ipv4.conf.all.forwarding=1" >> /etc/sysctl.conf
sudo sysctl -p
yum install -y iptables-services
systemctl enable iptables
systemctl start iptables
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT
iptables -t nat -F
iptables -t mangle -F
iptables -F
iptables -X
iptables -t nat -A PREROUTING -i eth0 -p tcp -m tcp --dport 8080 -j DNAT --to-destination 192.168.0.2:80
iptables -t nat -A POSTROUTING --destination 192.168.0.2/32 -j SNAT --to-source 192.168.255.2
service iptables save
echo "DEFROUTE=no" >> /etc/sysconfig/network-scripts/ifcfg-eth0
echo "GATEWAY=192.168.255.1" >> /etc/sysconfig/network-scripts/ifcfg-eth1
echo "192.168.0.0/16 via 192.168.255.3 dev eth1" > /etc/sysconfig/network-scripts/route-eth1

