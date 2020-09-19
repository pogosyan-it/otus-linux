# PS ax on BASH

1. С помощью скрипта user_pam.sh создаётся группа `admin` и в цикле - 10 пользователей user1, user2, ... ,user10, часть из которых добавляется в группу `admin` (по условию если остаток от деления на 3 порядкового номера пользователя равен 1, то пользователь добавляется в группу `admin`). По условию задачи нам необходимо запретиить всем пользователям, не входящим в группу `admin` логин в выходные дни. Согласно описанию, приведенному в файле `/etc/security/time.conf` исключить логин в выходные дни можно с помощью выражения `"*;*;$user;!Wd0000-2400"`. Таким образом, отобрав в цикле всех тех пользователей кроме рута  имеющих право логинится в систему и не входящих в группу `admin` пишем в файл соответствующиие выражения. 
2. Для того, чтобы дать возможность пользователю `vagrant `не входящему в группу sudoers иметь возможность запускать сервис docker, необходимо установить модуль polkit и создать правило см файл `01-systemd.rules` , вкотором прописать нужные нам условия и положить его в `/etc/polkit-1/rules.d/` после чего пользователь vagrant получит право останавливать и запускать `docker`.
 