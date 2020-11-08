### ДЗ №28 Фильтрация трафика - firewalld, iptables
Домашнее задание

Сценарии iptables
Цель: Студент получил навыки работы с centralServer, inetRouter.
1) реализовать knocking port
- centralRouter может попасть на ssh inetrRouter через knock скрипт
пример в материалах
2) добавить inetRouter2, который виден(маршрутизируется (host-only тип сети для виртуалки)) с хоста или форвардится порт через локалхост
3) запустить nginx на centralServer
4) пробросить 80й порт на inetRouter2 8080
5) дефолт в инет оставить через inetRouter

* реализовать проход на 80й порт без маскарадинга
Критерии оценки: 5 - все сделано 

Практическая часть

1) Реализовать  возможность доступа с centralRouter на inetRouter с помощью сервиса knockd по ssh (22 порт)

Port knocking — это сетевой защитный механизм, действие которого основано на следующем принципе: сетевой порт является по-умолчанию закрытым, но до тех пор, пока на него не поступит заранее определённая последовательность пакетов данных, которая «заставит» порт открыться. Например, вы можете сделать «невидимым» для внешнего мира порт SSH, и открытым только для тех, кто знает нужную последовательность. (https://putty.org.ru/articles/port-knocking.html)

Для настройки сервиса knockd используется скрипт inetRouter.sh, в котором прописаны следю правила для iptables (так как в Centos7 по умолчанию firewalld, то приходится ставить пакет iptables-services):
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT #правило, разрешающее входящий трафик инициированный хостом соединения
sudo iptables -A INPUT -p tcp --dport 22 -j REJECT #Отрубаем возможность прямого подключения по ssh
service iptables save iptables
После установки knockd и настройки iptables, копируем конфиг:
mv /vagrant/config/inetRouter_knock.conf /etc/knockd.conf
[options] <br/>
        UseSyslog
        logfile = /var/log/knockd.log
        interface = eth1
[SSHopen]
        sequence      = 3333:tcp,4444:tcp,5555:tcp
        seq_timeout   = 5
        tcpflags      = syn
        start_command = /sbin/iptables -I INPUT 1 -s %IP% -p tcp --dport 22 -j ACCEPT
        cmd_timeout   = 30
        stop_command  = /sbin/iptables -D INPUT -s %IP% -p tcp --dport 22 -j ACCEPT

[SSHclose]
        sequence      = 5555:tcp,4444:tcp,3333:tcp
        seq_timeout   = 5
        tcpflags      = syn
        start_command = /sbin/ipta      cmd_timeout   = 30
        stop_command  = /sbin/iptables -D INPUT -s %IP% -p tcp --dport 22 -j ACCEPT

Важно отметить:
1) Последовательность портов в sshopen должны быть противоположной последовательности в SSHclose, так как если они совпадут то одновременно сработают оба праввила
2) Параметр `seq_timeout   = 5` означает что после того как мы простучали все порты последовательности, у нас 5 сек. чтобы уже подключится к хосту по ssh

Теперь можно проверить настройку knocking port. Необходимо зайти на centralRouter командой vagrant ssh centralRouter и выполнить:
(Предварительно должен быть установлен пакет rpm -ivh http://li.nux.ro/download/nux/dextop/el7Server/x86_64/knock-0.7-1.el7.nux.x86_64.rpm
)
 knock -v 192.168.255.2 3333 4444 5555
 в ответ в файле /var/log/knockd.log увидим:
 [2020-11-08 22:30] 192.168.255.3: SSHopen: Stage 1
[2020-11-08 22:30] 192.168.255.3: SSHopen: Stage 2
[2020-11-08 22:30] 192.168.255.3: SSHopen: Stage 3
[2020-11-08 22:30] 192.168.255.3: SSHopen: OPEN SESAME
После выполнения этой команды можно подключаться по ssh `ssh vagrant@192.168.255.1`

2) Добавить inetRouter2, который виден(маршрутизируется (host-only тип сети для виртуалки)) с хоста или форвардится порт через локалхост

Добавлен в Vagrantfile директивой box.vm.network "forwarded_port", guest: 8080, host: 1234, host_ip: "127.0.0.1", id: "nginx"
3) Запустить nginx на centralServer

Добавлено в Vagrantfile
sudo yum install -y epel-release; sudo yum install -y nginx; sudo systemctl enable nginx; sudo systemctl start nginx

4) Пробросить 80й порт на inetRouter2 8080
Для настройки ВМ inetRouter2 используется скрипт inetRouter2.sh
inetRouter2 Правила iptables, в котором помимо правил очищающих таблицы iptables добавлены 2 важных правила

sudo iptables -t nat -A PREROUTING -i eth0 -p tcp -m tcp --dport 8080 -j DNAT --to-destination 192.168.0.2:80 # Перенаправляет tcp трафик приходящий на порт 8080 на 80 порт хоста centralServer
sudo iptables -t nat -A POSTROUTING --destination 192.168.0.2/32 -j SNAT --to-source 192.168.255.2 # Перенаправляет трафик с хоста 192.168.0.2 на 192.168.255.2 (на inetRouter2)

5) Все машины по умолчанию выходят в Глобальную сеть через 192.168.255.1 (inetRouter)
Это прямо взято из ДЗ 25 по сетям:
echo "DEFROUTE=no" >> /etc/sysconfig/network-scripts/ifcfg-eth0 
echo "GATEWAY=192.168.0.1" >> /etc/sysconfig/network-scripts/ifcfg-eth1

