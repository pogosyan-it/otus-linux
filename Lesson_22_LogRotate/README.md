# RSYSLOG

 Для запуска стенда необиходимо скачать в локальную папку файлы из репозитория и запустиить: `vagrant up` <br/>
 В файле `script.sh` происходит установка утилиты rsyslog, chrony, auditd и audispd-plugins на обе ВМ, отключение selinux.  <br/>
 Для `web` устанавливается nginx и копируются конфиги в соответствующие директории. Так как используется версия nginx 1.17, то поддержка отправки должна работать на    
 уровне конфига nginx.conf - для error и access необходимо добавить следующие строки:<br/>
 error_log syslog:server=192.168.11.171:514,facility=local7,tag=nginx,severity=error;<br/>
 access_log syslog:server=192.168.11.171:514,tag=nginx,nohostname,severity=info combined; <br/>
 Так как nginx разделяет потоки error_log и access_log, что означает, что нам надо их объединить но снабдить тегами, чтобы впоследствии легко можно было бы различить.
 Для получения системных логов, достаточно разрешить транспортные протоколы TCP и UDP  еще добавить:<br/>
 $template RemoteLogs,"/var/log/%fromhost-ip%/%PROGRAMNAME%.log" <br/>
 *.* ?RemoteLogs <br/>
 & ~ <br/>
 Чтобы убедлится что помимо логов изменения в конфигурации, пишутся и access логи, достаточно выполнить:
 curl http://192.168.11.170/ <br/>
 Сразу получим лог: <br/>

Sep 28 23:33:27 192.168.11.170 nginx: 192.168.11.1 - - [28/Sep/2020:23:33:27 +0300] "GET / HTTP/1.1" 200 4833 "-" "curl/7.58.0"<br/>

Чтобы писать не все логи с хоста на сервер, а только критичные и выше необходимо в файле `/etc/rsyslog.conf` на стороне клиента добавить следующуюс строку:
`*.crit @@192.168.11.171:514`. Чтобы увидить результат на сервере, так как критические проблемы вызвать на клиенте не так легко, можно вписать вместо crit --> notice.
После чего сразу появится в папке /var/log/ директория с ip web-сервера. 

# AUDITD
Очень простой и удобной утилитой для сбора логов аудита является утилита auditd и плагин для отправки на удаленное хронилище - audispd-plugins. Смысл в том, чтобы
получать на удаленной машине сведения о доступе, изменеию или удалению важных файлов и директорий на "клиенте", для чего на последнем необходимо:
1) в файле `/etc/audisp/plugins.d/au-remote.conf` заменить `active = no` на `active = yes` (чтобы логи аудита сами уходили на сервер, а не ожидали запроса)
2) Добавить в файл `/etc/audit/rules.d/audit.rules` соответствующие правила сбора нужных логов. Например в нашем случае логируется доступ в директорию `/etc/nginx` и изменение, удаление чтение файла `nginx.conf` <br/>
cat //etc/audit/rules.d/audit.rules <br/>
-w /etc/nginx/nginx.conf -p wa <br/>
-w /etc/nginx -p r <br/>

Все тоже самое можно делать и с помощью утилиты `auditctl` <br/>
На стороне сервера логов всего лишь необходимо в файле `/etc/audit/auditd.conf` указать директорию куда будут складываться логи, а также разрешить в этом же файле слушать порт 60 --> `tcp_listen_port = 60`. После чего при попытки зайти  в `/etc/nginx` получим следующие записи в файле ` 
/var/log/192.168.11.170/audit_web.log`:
`node=web type=SYSCALL msg=audit(1601756383.141:185): arch=c000003e syscall=257 success=yes exit=3 a0=ffffffffffffff9c a1=4aa31f a2=90800 a3=0 items=1 ppid=1594 pid=1595 auid=1000 uid=0 gid=0 euid=0 suid=0 fsuid=0 egid=0 sgid=0 fsgid=0 tty=pts0 ses=1 comm="bash" exe="/usr/bin/bash" key=(null)
node=web type=CWD msg=audit(1601756383.141:185):  cwd="/etc/nginx"`

а при попытки изменения конфигурации nginx.conf: <br/>

`node=web type=PATH msg=audit(1601756643.165:197): item=1 name="/etc/nginx/nginx.conf" inode=67147321 dev=fd:00 mode=0100644 ouid=0 ogid=0 rdev=00:00 objtype=NORMAL cap_fp=0000000000000000 cap_fi=0000000000000000 cap_fe=0 cap_fver=0
node=web type=PROCTITLE msg=audit(1601756643.165:197): proctitle=6E616E6F002F6574632F6E67696E782F6E67696E782E636F6E66
`




