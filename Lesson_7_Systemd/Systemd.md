# SYSTEMD

Для запуска стенда необходимо скачать папку files:<br/>
<https://github.com/pogosyan-it/otus-linux/tree/master/Lesson_7_Systemd/files>
и поднять ВМ `vagrant up`

1.  Написать service, который будет раз в 30 секунд мониторить лог на предмет наличия ключевого слова (файл лога и ключевое слово должны задаваться в /etc/sysconfig);
 С помощью скрипта random_log.sh пишется в лог `/var/log/messages` строка из файла `/etc/sysconfig/serv_mon.conf` раз в 30-40с (время ожидания выбирается произвольно в этом промежутке). 

2. Нажимате `Fork` этого репозитория (кнопка сверху справа) - в вашем репозитории появится копия проекта
3. На рабочей машине делаете `git clone <ссылка на ваш репозиторий>` - кнопка "clone or download"  
4. Вносите правки, работаете над проектом, делаете `git commit -m <comment> -a`  
5. По окончании работы делаете `git push`
6. В "Чате с преподавателем" отсылаете ссылку на ваш репозиторий  

Полезные ссылки по git:  
<https://git-scm.com/book/ru/v1/%D0%92%D0%B2%D0%B5%D0%B4%D0%B5%D0%BD%D0%B8%D0%B5>  
<https://githowto.com/ru>  
<https://learngitbranching.js.org/>  
