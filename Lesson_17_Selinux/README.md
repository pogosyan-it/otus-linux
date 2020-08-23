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
  `yum install setools-console policycoreutils-python selinux-policy* ` 
  1. В файле /etc/nginx/nginx.conf изменим порт 80 на допустим 2080, после чего сервис nginx перестанет запускатся (при включенном selinux) 
  audit2why < /var/log/audit/audit.log
  type=AVC msg=audit(1598204042.094:1728): avc:  denied  { name_bind } for  pid=8666 comm="nginx" src=2080 scontext=system_u:system_r:httpd_t:s0 tcontext=system_u:object_r:unreserved_port_t:s0 tclass=tcp_socket

 Was caused by:
 The boolean nis_enabled was set incorrectly.
 Description:
 Allow system to run with NIS

 Allow access by executing:
 `# setsebool -P nis_enabled 1`
 Утилита audit2why нам сама подсказывает один из способов запуска nginx на нестандартном порту (setsebool -P nis_enabled 1). Это не лучший способ так как таким образом открывается возможность запуска и других сервисов, а также запуск nginx на произвольном порту.
2. В selinux за каждый сервис отвечает некий контекст:
  semanage port -l | grep http
http_cache_port_t              tcp      8080, 8118, 8123, 10001-10010 <br/>
http_cache_port_t              udp      3130
**http_port_t                    tcp      80, 81, 443, 488, 8008, 8009, 8443, 9000**
pegasus_http_port_t            tcp      5988
pegasus_https_port_t           tcp      5989

   
