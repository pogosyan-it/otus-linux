# BORGBACKUP

 Для запуска стенда необиходимо скачать в локальную папку файлы из репозитория и запустиить: `vagrant up` <br/>
 В файле `script.sh` происходит установка утилиты rsyslog, chrony на обе ВМ, отключение selinux  <br/>
 для `web` устанавливается nginx и копируются конфиги в соответствующие директории. Так как версия nginx 1.17, то поддержка отправки должна работать на уровне конфига <br/>nginx - для error и access через unix socket необходимо добавить следующие строки:<br/>
 error_log  syslog:server=unix:/dev/log,tag=nginx,nohostname,severity=error;<br/>
 access_log syslog:server=unix:/dev/log,tag=nginx,nohostname,severity=info combined; <br/>
 Для получения системных логов, достаточно помимо того, чтоьбы разрешить транспортные протоколы TCP и UDP  - добавить <br/>
 $template RemoteLogs,"/var/log/%fromhost-ip%/%PROGRAMNAME%.log" <br/>
 *.* ?RemoteLogs <br/>
 & ~ <br/>
   




