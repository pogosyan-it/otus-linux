# RSYSLOG

 Для запуска стенда необиходимо скачать в локальную папку файлы из репозитория и запустиить: `vagrant up` <br/>
 В файле `script.sh` происходит установка утилиты rsyslog, chrony на обе ВМ, отключение selinux  <br/>
 для `web` устанавливается nginx и копируются конфиги в соответствующие директории. Так как версия nginx 1.17, то поддержка отправки должна работать на уровне конфига <br/>nginx - для error и access через unix socket необходимо добавить следующие строки:<br/>
 error_log  syslog:server=unix:/dev/log,tag=nginx,nohostname,severity=error;<br/>
 access_log syslog:server=unix:/dev/log,tag=nginx,nohostname,severity=info combined; <br/>
 Для получения системных логов, достаточно помимо того, чтоьбы разрешить транспортные протоколы TCP и UDP  - добавить <br/>
 $template RemoteLogs,"/var/log/%fromhost-ip%/%PROGRAMNAME%.log" <br/>
 *.* ?RemoteLogs <br/>
 & ~ <br/>
 Чтобы убедлится что помимо логов изменения в конфигурации, пишутся и access логи, достаточно выполнить:
 curl http://192.168.11.170/ <br/>
 Сразу получим лог: <br/>
Sep 28 23:33:01 web nginx: nginx: the configuration file /etc/nginx/nginx.conf syntax is ok <br/>
Sep 28 23:33:01 web nginx: nginx: configuration file /etc/nginx/nginx.conf test is successful <br/>
Sep 28 23:33:27 192.168.11.170 nginx: 192.168.11.1 - - [28/Sep/2020:23:33:27 +0300] "GET / HTTP/1.1" 200 4833 "-" "curl/7.58.0"<br/>

Системные логи пишутся абсолютно все, если пытаюсь какие-то исключить то перестают писатся и access логи. Не нашел причину и не смог исправить эту проблему.




