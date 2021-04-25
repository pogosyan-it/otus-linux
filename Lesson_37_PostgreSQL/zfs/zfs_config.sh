#!/bin/bash

name=$(lvs | grep root | awk '{print $2}')
#echo "Insert for master host - 1, for slave - 2"
#read num
#name2=".$num"
#name=${name1}${name2}

telnet cpmsk.rgs.ru 259

yum install tcsh git glibc-langpack-ru wget rsync lz4 bzip2 unzip zip tar telnet-server ethtool time tcpdump iotop lsof binutils gcc m4 bison make redhat-rpm-config xinetd -y

systemctl    stop xinetd
systemctl disable xinetd

mount /export/share
rm -rf /root/.tcshrc /root/.cshrc /etc/csh.*
cp  /export/share/install/ROOT/etc/csh.* /etc/

echo "Insert for master host - 1, for slave - 2"
read num

sed -i -e "s/set nn_=''/set nn_='$num'/g" /etc/csh.cshrc
sed -i -e "s/set sg_=''/set nn_='$name'/g" /etc/csh.cshrc

#-cp /export/Dis/screen-4.6.2-10.el8.x86_64.rpm /export/Dis/terminus-fonts-console-4.48-1.el8.noarch.rpm /root/

#-                                                    &&
  rpm -ivU /export/share/install/rpm/screen-4.6.2-10.el8.x86_64.rpm
  rpm -ivU /export/share/install/rpm/terminus-fonts-console-4.48-1.el8.noarch.rpm

  echo "KEYMAP='ruwin_cplk-UTF-8'" > /etc/vconsole.conf
  echo "FONT='ter-c14n'" >> /etc/vconsole.conf

  groupadd -g 911 me
  groupadd -g 5432 postgres
  groupadd -g 1970 cc
  groupadd -g 1982 sun
  useradd -u 10001 -g me -G wheel -d /var/lib/zobnin -s /usr/bin/tcsh zobnin
  useradd -u 5432 -g postgres -d /var/lib/pgsql -s /usr/bin/tcsh postgres
  echo "%zobnin  ALL=(ALL)       ALL" >> /etc/sudoers
  echo "%postgres  ALL=(ALL)       ALL" >> /etc/sudoers

  q=$(cat /etc/shadow | grep -n zobnin | sed -e 's/:.*//g')
  sed -i -e "$q d" /etc/shadow  
  echo "zobnin:\$6\$5X00Cb2uG9JhIQw4\$PHZcBjDX4JUKn70WtKPqhu4aAnIN/Xi6.peJ/m3a1MKqNTsYWzMRD1JpHalrNfjQuLoxEG6H0bkBgCOAiAVeR.:18549:0:99999:7:::" >> /etc/shadow
#+
  #/export/oel+zfs/wheelNOPASSWD

  #mount /store
  #bash /store/Scripts_lnk/ad_join_rhel8.sh
  #realm leave
  #bash /store/Scripts_lnk/ad_join_rhel8.sh
  #id ERPogosyan
#+
  #umount /store

echo "At first you must create zpool on your hard drives, if it done type 'yes'?"

read answer1

if [[ $answer1 = "yes" ]]; then 

   #zpool create -f $name /dev/sda4
   zfs set mountpoint=none $name
   zfs set compress=lz4 $name
   zfs set atime=off $name
   zfs create -o mountpoint=/db ${name}/db
   zfs create -o mountpoint=none ${name}/pgsql
   #zfs create -o mountpoint=/home ${name}/home

  echo "Do you want to install PostgreSQL, yes/no"  
    read answer2
    if [[ $answer2 = "yes" ]]; then
       
       dnf install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-8-x86_64/pgdg-redhat-repo-latest.noarch.rpm
       dnf -qy module disable postgresql
       dnf install perl-TimeHiRes perl-DBI perl-DBD-Pg
 
      echo "Which version of postgres do you want to install"
      echo "10"
      echo "11"
      echo "12"
      echo "13"
    read version
 
      zfs create -o mountpoint=/usr/pgsql-$version ${name}/pgsql/$version
      dnf install -y postgresql$version-server  postgresql$version-libs pg_activity
      dnf install -y pg_repack$version pg_stat_kcache$version postgresql$version-devel postgresql$version-contrib
   fi
fi
#+
#   cp /export/git/pgcompacttable/bin/pgcompacttable /usr/bin/

#-   /usr/pgsql-12/bin/postgresql-12-setup initdb
#-   systemctl enable postgresql-12
#-   systemctl start postgresql-12
