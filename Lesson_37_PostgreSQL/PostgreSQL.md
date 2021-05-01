# PostreSQL
Установка PostgreSQL из пакетов, а также сборка из исходного кода, должны выполнятся в соответствии с офф. документацией:
Полезные ссылки:  
<https://www.postgresql.org/download/> <br/>
<https://postgrespro.ru/education/courses/DBA1/>

## Tips and FAQs

# Подключение в БД postgres
1) После устаноки подключится к БД: \\
   psql -d postgres (создается пользователь с правми superuser и бд postgres)
2) C внешних серверов:
   psql -d база -U роль -h узел -p порт
