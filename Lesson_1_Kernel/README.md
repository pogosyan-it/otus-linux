**Сборка ядра Linux 5.х в ручную** <br/>
Согласно статье

<http://itisgood.ru/2018/08/02/kak-skompilirovat-jadro-linux-na-centos-7/>

легко собрать ядро вручную.

Но как это автоматизировать при сборке packer-ом бокса так и не понял, использовал [скрипт](https://github.com/pogosyan-it/otus-linux/blob/master/Lesson_1/stage-1-kernel-update_bad.sh)

Конечно же на строке "make menuconfig" он зависал.

ПО вашему руководству все взлетает великолепно создается box, однако при создании ВМ востанавливается ядро 3.х 
которое выбирается по умочанию. Только добавив в Vagrantfile строки:

````bash
config.vm.provision "shell", inline: <<-SHELL
      sed -i 's/saved_entry=.*/saved_entry=0/g' /boot/grub2/grubenv
      reboot
SHELL
````

Так же попытался сперва выгрузить ВМ в ova и потом пакером преобразовать в box, соответствующий файл [json-файл](https://github.com/pogosyan-it/otus-linux/blob/master/Lesson_1/centos_ova.json)

Почему-то после поднятия ВМ он не мог к ней подключиться по ssh, хотя я добавил (прежде чем выгружать конфигурацию) интерфес типа "мост"  и прописал статический ip из моей сетки. Интерфейс был доступен, настройки ssh тоже поправил, чтобы можно было по паролю логиниться. Но процесс вылетал по timeout-у и ВМ уничтожалась.
