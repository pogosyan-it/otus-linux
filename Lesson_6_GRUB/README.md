1.  **Попасть в систему без пароля**

После нажатия "e" чтобы получить доступ к консоли для смены пороля, помимо того что описано в методиске пришлось удалить "no_timer_check console=tty0 console=ttyS0,115200n8 net.ifnames=0 biosdevname=0 elevator=noop " В противном случае, или зависал процесс загрузки или загружалась сама система. После удаления вышеупомянутой строки в точности следуя методичке получаем доступ к консоли с праввами рут. <br/> 
**1споспоб** <br/>
Добавление  linux init=/bin/sh в конец строки с Linux16, сохраняем заходим загружаемся в систему c правами рут:<br/>
mount -o remount,rw / <br/>
passwd root - Назначаем пароль. <br/>
**2 способ** <br/>
В конце строки начинающейся с linux16 добавляем rd.break <br/>
mount -o remount,rw /sysroot <br/>
chroot /sysroot <br/>
passwd root <br/>
**3 способ** <br/>
В строке начинающейся с linux16 заменяем ro на rw init=/sysroot/bin/sh <br/>


2. **Переименовать VG, содержащем на одном из своих логических томов каталог /root** <br/>
Эта задача автоматизирована с помощью скрипта:<br/>
https://github.com/pogosyan-it/otus-linux/blob/master/Lesson_6_GRUB/vg-rename.sh<br/>
Скрипт сам определяет ту группу томов на которой находится каталог /root и переименовывает его в OtusNewRoot, правит fstab, /etc/default/grub, монтирует рутовый логический том в  /mnt, после чего chroot в /mnt, так как если этого не сделать то пересобрать grub  невозможно - не находит по новому названию vg пусть к  /root/<br/>
3. **Добавить модуль в initrd** <br/>
mkdir /usr/lib/dracut/modules.d/01test <br/>
sudo cp module-setup.sh test.sh /usr/lib/dracut/modules.d/01test/ <br/>
sudo chmod +x /usr/lib/dracut/modules.d/01test/test.sh <br/>
sudo chmod +x /usr/lib/dracut/modules.d/01test/module-setup.sh<br/> 
Проверяем модуль <br/> 
sudo lsinitrd -m /boot/initramfs-$(uname -r).img | grep test<br/> 
test <br/>
Пересобираем образ initrd <br/>
sudo dracut -f -v <br/>
Редактировать grub.cfg  <br/>
sudo sed -i 's/OtusNewRoot\/LogVol01 rhgb/OtusNewRoot\/LogVol01/g' /etc/default/grub <br/>
Перезагружаемся, видим при загрузке пингвина ждем 10с и радуемся.<br/>
Лог прилагаю<br/>
https://github.com/pogosyan-it/otus-linux/blob/master/Lesson_6_GRUB/module.log

    






