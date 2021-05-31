# PostgreSQL
1. [Установка](#install)
2. [Подключение в БД postgres](#connect)
3. [Импорт и экспорт дампа БД](#dump)
4. [Создание пользователей](#user_create)
5. [Мета команды](#meta_commands)
6. [Схемы](#schemas)
7. [Права](#rights)
8. [Представления, Функции и Триггеры.](#perfom_func_trig)
    1. [Оконные функции](#window_func)
    2. [Пользовательские функции](#user_func)
    3. [Пример создания Функции и триггера на на PL/pgSQL](#func_trig_example)
        1. [Создание таблицы содержащей первичные и внешние ключи](#table_create)
        2. [Функция auditlog_users_insert](#auditlog_users_insert)
        3. [Триггер](#trigger)
9. [Репликация](#replic)      
## Установка <a name="install"></a>
Установка PostgreSQL из пакетов, а также сборка из исходного кода, должны выполнятся в соответствии с офф. документацией:
Полезные ссылки:  
<https://www.postgresql.org/download/> <br/>
<https://postgrespro.ru/education/courses/DBA1/>


## Подключение в БД postgres <a name="connect"></a>
1) После устаноки подключится к БД:  
   psql -d postgres (создается пользователь с правми superuser и бд postgres)
2) C внешних серверов:  
 ()   `psql -d база -U роль -h узел -p порт ` 
 
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
# Импорт и экспорт дампа БД  <a name="dump"></a>  
Импорт:
`psql -U User -d db_name -f /path/to/dump/mydb.bqp`  
Экспорт:
`pg_dump -U User db_name > /path/to/dump/mydb.bqp`


# Создание пользователей <a name="user_create"></a> 
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
Выдать права роли myrole на вход в БД  
`ALTER ROLE myrole WITH LOGIN;`  

# Мета команды <a name="meta_commands"></a>
`\c new_db` сменить базу данных  
`\dt` список таблиц  
`\l` список баз  
`\u` список пользователей  
`\f` список функций  
`\?` - СПРАВКА  
`\dt public.*` - список таблиц в схеме.  

# Схемы <a name="schemas"></a> 
Кластер баз данных — это набор баз данных, которыми управляет один экземпляр сервера. Понятие кластеров баз данных было введено разработчиками OS Ubuntu для упрощения работы с PostgreSQL, для этого был собран специальный пакет postgres-common.
Схема базы данных — это коллекция объектов базы данных, имеющая одного владельца и формирующая одно пространство имен. Две таблицы в одной и той же схеме не могут иметь одно и то же имя.
База данных содержит одну (по умолчанию существует схема public) или несколько именованных схем, которые, в свою очередь, содержат таблицы. Схемы также содержат именованные объекты других видов, включая типы данных, функции и операторы. Одно и то же имя объекта можно свободно использовать в разных схемах, например, и schema1, и myschema могут содержать таблицы с именем mytable.  
   В отличие от баз данных схемы не ограничивают доступ к данным: пользователи могут обращаться к объектам в любой схеме текущей базы данных, если им назначены соответствующие права.
   Есть несколько возможных объяснений, для чего стоит применять схемы:

    Чтобы одну базу данных могли использовать несколько пользователей, независимо друг от друга.
    Чтобы объединить объекты базы данных в логические группы для облегчения управления ими.
    Чтобы в одной базе сосуществовали разные приложения, и при этом не возникало конфликтов имен.  
Схемы в некоторым смысле подобны каталогам в операционной системе, но они не могут быть вложенными.  
Для создания схемы используется команда CREATE SCHEMA. 
`CREATE SCHEMA schema_name;`
Cоздать таблицу в новой схеме можно так:
`CREATE TABLE myschema.mytable (
 ...);`  
Cоздать схему, владельцем которой будет другой пользователь:  
 `CREATE SCHEMA schema_name AUTHORIZATION user_name;`
Список всех схем в бд, схемы которые начинаются с `pg_` - это служебные схемы бд  
 `select * from information_schema.schemata;`  
Важно отметить, что в postgres, для того, чтобы не писать полное имя таблицы `my_schema.my_table` по умолчанию используется путь поиска:  

 `SHOW search_path;`  
 `-----------------`  
 `"$user", public`  
 `(1 row)`  

Как видно, если опустить в запросе имя схемы, то поиск будет происходить именно в схеме по умолчанию - public.  
Чтобы добавить в путь нашу новую схему, мы выполняем:  
`SET search_path TO myschema,public;`
Если, помимо схемы public, имеется схема  `myschema`, то для обращения к таблицам в этой схеме (без упоминания имени схемы), нужно добавить в `path` новую схему:  
`SET search_path TO myschema,public;`  
Однако, в таком случае после завершения сессии информация из переменной `path` пропадает. Чтобы данное изменение действовало бы всегда нужно выполнить:  
`ALTER ROLE <your_login_role> SET search_path TO myschema;`

# Права <a name="rights"></a>
Выдать права на использование схемы public пользователю user.  
`GRANT USAGE on SCHEMA "public" to user;`  
Выдать для роли myrole права SELECT на вновь создаваемые таблицы пользователем user в схеме public.  
`ALTER DEFAULT PRIVILEGES FOR USER user IN SCHEMA public GRANT SELECT ON TABLES TO myrole;`  
Выдайте права для user только на SELECT из всех таблиц в схеме public  
`GRANT SELECT ON ALL TABLES IN SCHEMA public  TO user;`  

<https://lk.rebrainme.com/postgresql/task/597>  

# Представления, Функции и Триггеры.  <a name="perfom_func_trig"></a>
Представления или View используются для удобаства, когда один и тот же запрос необходимо использовать много раз. По сути птакому запросу присваивается имя и созраняется в базу данных. Обращение к такому представлению осуществляется так же как и к обычной таблице:  
`CREATE VIEW view_name AS  
    SELECT ...;`  
В Postgres существует огромное кол-во **встроенных функций** - мат. функции, строковые, функции даты и времени, подробно о которых можно почитать:  
<https://postgrespro.ru/docs/postgresql/13/functions>  
Например:  
` SELECT EXTRACT(EPOCH FROM timestamptz '2013-07-01 12:00:00');`  
 `------------`  
 `1372680000`  
 `(1 row)`  
 `select to_timestamp(1372680000);`  
  `    to_timestamp`  
  `------------------------`  
  `2013-07-01 12:00:00+00`  
  
**Оконные функции** <a name="window_func"></a>используется для обработки результата запроса. Окно — это некоторое выражение, описывающее набор строк, которые будет обрабатывать функция и порядок этой обработки. Причем окно может быть просто задано пустыми скобками (), т.е. *окном являются все строки результата запроса*.  
`Select course_id, coursename, tasks_count,  sum(price) OVER () FROM courses;`  
Запрос выведет дополнительный столбец в каждой строке которого будет сумма всех значений столбца `price`  
Если добавить в предыдущий запрос `OVER (ORDER BY price)`, то будет в каждой ячейке стобца будет вписана сумма предыдущих значений поля `price`:  
`Select course_id, coursename, tasks_count,  price, sum(price) OVER (ORDER BY price) FROM courses;`  
` course_id | coursename | tasks_count | price |  sum`  
`-----------+------------+-------------+-------+--------`  
`         3 | Bash       |          15 |  6900 |   6900`  
`         8 | Logs       |          14 |  7900 |  14800`   
`         9 | Postgresql |          14 | 10000 |  24800`  

**Пользовательские функции** бывают 4 типов:  <a name="user_func"></a>
  Функции на языке запросов (функции, написанные на SQL) - <https://postgrespro.ru/docs/postgresql/13/xfunc-sql>  
  Функции на процедурных языках (функции, написанные, например, на PL/pgSQL или PL/Tcl) - <https://postgrespro.ru/docs/postgresql/13/xfunc-pl>  
  Внутренние функции - <https://postgrespro.ru/docs/postgresql/13/xfunc-internal>  
  Функции на языке C - <https://postgrespro.ru/docs/postgresql/13/xfunc-c>  
  Пример функции написаной на языке SQL:  
  `CREATE FUNCTION add(integer, integer) RETURNS integer`
  `AS 'select $1 + $2;'`  
    `LANGUAGE SQL`  
    `IMMUTABLE`  
    `RETURNS NULL ON NULL INPUT;`  
    Обращение к функции происходи - `Select add(5,6);`  
    Так же используются процедуры, единственным отличием которых является то что они не возвращают значание, поэтому для нее не определяется возвращаемый тип.  
    
`CREATE PROCEDURE insert_data(a integer, b integer)`  
`LANGUAGE SQL`  
`AS $$`  
`INSERT INTO tbl VALUES (a);`  
`INSERT INTO tbl VALUES (b);`  
`$$;`  
 Вызов процедуры осуществляется  `CALL insert_data(1, 2);`
 # Пример создания Функции и триггера на на PL/pgSQL <a name="func_trig_example"></a>
 Расмотрим пример функции на процедурном языке, вызов которой происходит по условию. В нашем примере условием срабатывания функции (триггером) будет появление в таблице `users` новой записи. Пусть имя функции `auditlog_users_insert` - функция создает в таблице `auditlog` id вновь созданного пользователя, время его создания, под каким пользователем был осуществлен Insert в таблицу 'users' и имя вновь созданного пользователя.  
# Сперва  создадим таблицу auditloв в БД:  <a name="table_create"></a>
 
```
 CREATE TABLE auditlog(
     id  SERIAL PRIMARY KEY NOT NULL,                 -- Primary Key
     user_id INT NOT NULL,                            -- Foreign Key to table users
     creation_time timestamp NOT NULL DEFAULT now(),  -- Дата создания
     ctreator varchar(50) NOT NULL,                   --Имя пользователя
     username varchar(50) NOT NULL,                  --Имя созданного в таблице users пользователя
     CONSTRAINT fk_users_id
         FOREIGN KEY (user_id) 
             REFERENCES users(user_id)
             );
 ```
`CONSTRAINT fk_users_id` - обеспечивает проверку вводимых данных на корректность, Например, пользователь базы данных не сможет удалить карточку клиента, если у этого клиента имеются заказы. <https://postgrespro.ru/docs/postgresql/9.5/ddl-constraints>.  
# Функция auditlog_users_insert <a name="auditlog_users_insert"></a>
```
  Create or replace function auditlog_users_insert RETURNS TRIGGER AS $$
DECLARE
    add_str varchar(30);
    new_usr varchar(100);
    res_str varchar(254);
    userid int;
BEGIN
   IF  TG_OP = 'INSERT' THEN
    new_usr = NEW.username;
    add_str := 'Add new user ';
    res_str := add_str || new_usr;
    userid = NEW.user_id;
    INSERT INTO auditlog(user_id, creation_time, creator, username) values (userid, NOW(), user, res_str);
   RETURN NEW;
  END IF;
END;
$$ LANGUAGE plpgsql

```
Первая строчка, описывает имя функции (или переопределяет функцию если до этого функция с таким именем существовала), тело функции заключается в `$$`. В блоке `Declare` объявляются переменные и их тип. Условие, при котором срабатывание функции должно произайти при insert-е в таблицу , о которой не упоминается в теле функции. В описании триггера имя таблицы будет фигурировать. `TG_OP` - тригерная функция, отслеживающая запросы типа insert.   
<https://postgrespro.ru/docs/postgrespro/9.6/plpgsql-trigger>  
`new_usr = NEW.username` в переменную `new_usr` записывается значение `username` полученное из последнего Insert в таблицу `users`. Знак `||`  означает конкотенацию строк.  
# Триггер: <a name="trigger"></a>
```
Create trigger insert_into_users_trigger AFTER INSERT on users FOR EACH ROW
EXECUTE PROCEDURE auditlog_users_insert ();
```  
# Репликация: <a name="replic"></a>
