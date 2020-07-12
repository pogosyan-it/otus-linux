# RPM-BUILD

1. Создан docker image и выложен на dockerhub, сачать который можно командой: `docker pull dockerlabtst/buildrpm-locaprepo`
2. В образн собран rpm пакет nginx с модулем ssl, поднят локальный репозиторий из которого установлен nginx, список всех пакетов доступен по адресу:
   <http://172.17.0.1:/repo>
   172.17.0.1 ip адрес интерфейса docker0
3. Чтобы в контеинере работало бы systemd запускать его нужно командой:
    `docker run -d -p 80:80/tcp -h localrepo.com --privileged=true dockerlabtst/buildrpm-locaprepo /usr/sbin/init`
    
