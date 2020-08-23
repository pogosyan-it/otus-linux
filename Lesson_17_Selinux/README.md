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
После установки модуля `my-nginx.pp` nginx запустится на порту нашем нестандартном порту.


