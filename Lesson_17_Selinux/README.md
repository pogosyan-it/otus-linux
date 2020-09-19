**1. Запустить nginx на нестандартном порту 3-мя разными способами:**

    переключатели setsebool; 
    добавление нестандартного порта в имеющийся тип; 
    формирование и установка модуля SELinux. 
    К сдаче: README с описанием каждого решения (скриншоты и демонстрация приветствуются). 

**2. Обеспечить работоспособность приложения при включенном selinux.**

    Развернуть приложенный стенд https://github.com/mbfx/otus-linux-adm/tree/master/selinux_dns_problems 
    Выяснить причину неработоспособности механизма обновления зоны (см. README); 
    Предложить решение (или решения) для данной проблемы; 
    Выбрать одно из решений для реализации, предварительно обосновав выбор; 
    Реализовать выбранное решение и продемонстрировать его работоспособность. К сдаче: 
    README с анализом причины неработоспособности, возможными способами решения и обоснованием выбора одного из них; 
    Исправленный стенд или демонстрация работоспособной системы скриншотами и описанием. 

 Чтобы иметь все необходимые инструменты для работы с Selinux необходимо установить следующие пакеты:
  `yum install setools-console policycoreutils-python setroubleshoot selinux-policy* ` 
  1. В файле /etc/nginx/nginx.conf изменим порт 80 на допустим 2080, после чего сервис nginx перестанет запускатся (при включенном selinux) 
  audit2why < /var/log/audit/audit.log
  type=AVC msg=audit(1598204042.094:1728): avc:  denied  { name_bind } for  pid=8666 comm="nginx" src=2080 scontext=system_u:system_r:httpd_t:s0 tcontext=system_u:object_r:unreserved_port_t:s0 tclass=tcp_socket

 Was caused by:<br/>
 The boolean nis_enabled was set incorrectly.<br/>
 Description:<br/>
 Allow system to run with NIS<br/>

 Allow access by executing:<br/>
 `# setsebool -P nis_enabled 1` <br/>
 Утилита audit2why нам сама подсказывает один из способов запуска nginx на нестандартном порту (setsebool -P nis_enabled 1). Это не лучший способ так как таким образом открывается возможность запуска и других сервисов, а также запуск nginx на произвольном порту.<br/>
2. В selinux за каждый сервис отвечает некий контекст:<br/>
  semanage port -l | grep http<br/>
http_cache_port_t              tcp      8080, 8118, 8123, 10001-10010 <br/>
http_cache_port_t              udp      3130<br/>
**http_port_t                    tcp      80, 81, 443, 488, 8008, 8009, 8443, 9000**<br/>

несложно догадаться что за запуск web сервера в селинукс отвечает контекст http_port_t. Нам остается добавить в него наш нестандартный порт:<br/>
`semanage port -a -t http_port_t -p tcp 2080`
systemctl status nginx <br/>
● nginx.service - The nginx HTTP and reverse proxy server <br/>
   Loaded: loaded (/usr/lib/systemd/system/nginx.service; disabled; vendor preset: disabled) <br/>
   Active: active (running) since Sun 2020-08-23 18:09:33 UTC; 6s ago<br/>
   
3. Помимо утилиты audit2why есть очень удобная утилита sealert:  <br/>
  `sealert -a /var/log/audit/audit.log` <br/>
  Помимо указания проблем с запуском nginx подсказывает еще один способ запуска: <br/>
  ausearch -c 'nginx' --raw | audit2allow -M my-nginx <br/>
******************** IMPORTANT *********************** <br/>
To make this policy package active, execute: <br/>

semodule -i my-nginx.pp <br/>
После установки модуля `my-nginx.pp` nginx запустится на нестандартном порту.

2. После того как развернут стенд, заходим на `ns01` запускаем: <br/>
[vagrant@client ~]$ nsupdate -k /etc/named.zonetransfer.key <br/>
> server 192.168.50.10 <br/>
> zone ddns.lab <br/>
> update add www.ddns.lab. 60 A 192.168.50.15 <br/>
> send<br/>
update failed: SERVFAIL <br/>
Того как появилась ошибка, с помощью утилиты audit2why получим слудеющую подсказку: <br/>

type=AVC msg=audit(1598216680.578:2040): avc:  denied  { unlink } for  pid=5464 comm="isc-worker0000" name="named.ddns.lab" dev="dm-0" ino=278807 scontext=system_u:system_r:named_t:s0 tcontext=system_u:object_r:etc_t:s0 tclass=file <br/>

        Was caused by: <br/>
                Missing type enforcement (TE) allow rule. <br/>

                **You can use audit2allow to generate a loadable module to allow this access.**<br/>

Таким образом можно использовать утилиту audit2allow, которая подскажет какой именно модуль необходимо загрузить, чтобы user vagrant могу бы обновить зону:<br/>
`man audit2allow`<br/>
OPTIONS<br/>
       -a | --all<br/>
              Read input from audit and message log<br/>

audit2allow -a <br/>


#============= named_t ==============

#!!!! WARNING: 'etc_t' is a base type.<br/>
allow named_t etc_t:file { create rename unlink write };<br/>
allow named_t sysctl_net_t:dir search;<br/>

Откуда понятно, что за обновление DNS зон отвечает контекст named_t.  Снова воспользуемся `man` и найдем ключ, который отвечает за определение названия модуля - это ключ -M:
[root@ns01 ~]# audit2allow -a -M named_t <br/>
******************** IMPORTANT *********************** <br/>
To make this policy package active, execute: <br/>

semodule -i named_t.pp <br/>

Запустим команду `semodule -i named_t.pp`, после чего перейдем снова под пользователя vagrant и запустим команду `nsupdate`: <br/>
[vagrant@ns01 ~]$ nsupdate -k /etc/named.zonetransfer.key  <br/>
> server 192.168.50.10 <br/>
> zone ddns.lab  <br/>
> update add www.ddns.lab. 60 A 192.168.50.15 <br/>
> send <br/>
>  <br/>
Как видим команда отработала без ошибок.

   Если более внимательно изучить проблему, то можно сделать вывод, что динамические файлы зон должны лежать в `/var/named/dynamic` и тогда никакого влияния Selinux на корректную работу сервиса не окажет. Чтобы наш стенд поднялся и сервис named запустился необходимо:
   1) Поправить файл named.conf: `/etc/named/dynamic --> /var/named/dynamic`
   2) Поправить файл playbook.yml: `/etc/named/dynamic --> /var/named/dynamic`
   Верные файлы:  <br/>
   https://github.com/pogosyan-it/otus-linux/blob/master/Lesson_17_Selinux/named.conf  <br/>
   https://github.com/pogosyan-it/otus-linux/blob/master/Lesson_17_Selinux/playbook.yml
   После чего, обновление зон пройдет успешно.
