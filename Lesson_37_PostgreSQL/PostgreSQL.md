# PostreSQL
Установка PostgreSQL из пакетов, а также сборка из исходного кода, должны выполнятся в соответствии с офф. документацией:
Полезные ссылки:  
<https://www.postgresql.org/download/> <br/>
<https://postgrespro.ru/education/courses/DBA1/>

## Tips and FAQs

# Подключение в БД postgres
1) После устаноки подключится к БД:  
   psql -d postgres (создается пользователь с правми superuser и бд postgres)
2) C внешних серверов:  
   `psql -d база -U роль -h узел -p порт ` 
 
 Чтобы дать разрешение на подключение с удаленных хостов к бд, необходимо:
 1) прописать в файл postgresql.conf  
    `listen_addresses = '*'`, если нужно конкретную подсеть указать, вместо * пишем 192.168.0.0/24 
 2) В файл pg_hba.conf прописать:  
    `host     mybd     postgres     192.168.0.0/24     md5`  
    Запись разрешает подключение к БД mybd пользователю postgres с подсети 192.168.0.0/24, используя пароль.
Узнать расположение файлов конфигурации PostgreSQL: postgresql.conf, pg_hba.conf:  
`ps aux | grep postgres | grep -- -D`  
Для получения информация о текущем подключении:  
`postgres-# \conninfo`  
You are connected to database "postgres" as user "postgres" via socket in "/var/run/postgresql" at port "5432".  
# Создание пользователя  
`CREATE USER user WITH PASSWORD 'mypassword';`
Чтобы подключится к базе под этим пользователем в системе должен быть создан рользователь с таким именем и в файл pg_hba.conf прописано разрешение (см выше)  
Создание пользователя с правами суперпользователя:  
`create user my_user with superuser password 'mypass';`  
Выдать все права для пользователя `user_name` на БД `myDB`:  
`GRANT ALL PRIVILEGES on DATABASE "myDB" to my_user`;
Создать базу данных:  
`Create database myDB;`
Изменение пароля пользователя:  
`ALTER USER MyUser WITH PASSWORD 'NEW_PASS';`
# Метакоманды
`\c new_db` сменить базу данных  
`\dt` список таблиц  
`\l` список баз  
`\u` список пользователей  
`\f` список функций  
`\?` - СПРАВКА
`ALTER DEFAULT PRIVILEGES for role "backup" in schema "public" GRANT Select ON TABLES TO PUBLIC;`
