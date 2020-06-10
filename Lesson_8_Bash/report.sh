#!/bin/bash

n=$(cat access-4560-644067.log | wc -l)
lockfile=/tmp/localfile

mkdir -p report report/tmp

Full_time () {
fulltime=$(echo $1 | awk -F '/' '{print $3}' | cut -c 6-)
echo ${fulltime}
} # Функция времени получает на вход строку (14/Aug/2019:04:57:08) выдает 04:57:08

Day_OF_Month () {
day_of_month=$(echo $1 | awk -F '/' '{print $1}')
echo ${day_of_month}
}

Year () {
year=$(echo $1 | awk -F '/' '{print $3}' | cut -c 1-4)
echo ${year} 
}

Month () {
month=$(echo $1 | awk -F '/' '{print $2}')
echo ${month} 
}

Time_Stamp () {
    date_formate="$1 $2, $3 $4"
    date +%s -d"${date_formate}"

} #Преобразует дату в timestamp чтобы удобно было находить интервал в 1ч=3600с

full_date_1=$(cat access-4560-644067.log | head -n 1 |awk '{print $4}' | cut -c 2-)
Time_0=$(Time_Stamp $(Month $full_date_1) $(Day_OF_Month $full_date_1) $(Year $full_date_1) $(Full_time $full_date_1))

Log_Read () {
for (( i = $1; i < $n; i++ ))
   do
      if [[ $delta -lt 3600 ]]; then
             line=$(cat access-4560-644067.log | head -n $i | tail -n 1)  
             line1=$(echo $line | head -n 1 | awk '{print $4}' | cut -c 2-)
             Time_t=$(Time_Stamp $(Month $line1) $(Day_OF_Month $line1) $(Year $line1) $(Full_time $line1))
             ip=$(echo $line | awk '{print $1}')
             code=$(echo $line | awk '{print $9}')
             echo $ip >> report/tmp/ip_tmp.log
             echo $code >> report/tmp/code_tmp.log
             let "delta=$Time_t-$Time_0"
             let "q=$i-1"
             echo "After first iteration was $i string"
      else
            break
      fi
  done

} #Функия в цикле пробегает файл и  проверяет условие разности фремени на n-й строке и на первой, если эта разность больше 1ч прерывает цикл

label=$(cat access-4560-644067.log | grep Label)


report () 
{
  arg=$(cat access-4560-644067.log | head -n $1 | tail -n 1 | awk '{print $4}' | cut -c 2-)
  year=$(Year $arg)
  month=$(Month $arg)
  day_of_month=$(Day_OF_Month $arg)
  fulltime=$(Full_time $arg)
  full_date="$year"\."$month"\."$day_of_month":"$fulltime"
  echo $full_date, $Time_t
  let "Time_zero=$Time_t-3600"
  time_str_0=`date -d@$Time_zero`
  time_str_1=`date -d@$Time_t`
  echo "Временной интервал: c $time_str_0 по $time_str_1">>report/report_"$full_date"
  echo "Список IP адресов с указанием кол-ва запросов с каждого:">>report/report_"$full_date"
  cat report/tmp/ip_tmp.log | sort | uniq -c | sort -nrk 1 >> report/report_"$full_date"
  err=$(cat access-4560-644067.log | head -n $q | awk '{print $9}' | grep "404\|500\|405\|499" |wc -l)
  echo "Всего ошибок за 1 час: $err" >> report/report_"$full_date" >> report/report_"$full_date"
  echo "Список всех кодов возврата с указанием их кол-ва:" >> report/report_"$full_date"
  cat report/tmp/code_tmp.log | sort | uniq -c | sort -nrk 1 >> report/report_"$full_date"
  cat  access-4560-644067.log | head -n $q | awk '{print $9}' |  sort | uniq -c | sort -nrk 1 >> report_"$full_date" 
  echo "REPORT" | mail -s "HTTP_LOG_Stat_$full_date" root < report_"$full_date" #отправка почты для в root  в файл /var/spool/mail/root
  Timestamp1=$(Time_Stamp ${month} ${day_of_month} ${year} ${fulltime})
  let  "z=$q+1"
  str="Label $Time_t $q"
  sed -i "${z}i\\$str" access-4560-644067.log
  rm report/tmp/ip_tmp.log report/tmp/code_tmp.log

} #Функция формирует отчет и как только разность между начальным временим и текущим оказывается больше 1ч ставит метку в лог файл 
  #(Label время с которого в следующий раз надо принять за начальное, номер строки на котором закончился предыдущий проход ), 
  #чтобы при следующем проходе цикл начинался со строки идущей сразу после последней метки.

if ( set -o noclobber; echo "$$" > "$lockfile") 2> /dev/null; then
    trap 'rm -f "$lockfile"; exit $?' INT TERM EXIT
    if [[ -z $label ]]; then
       Log_Read 1
       report $q
    else
       str_num=$(cat access-4560-644067.log | grep Label | tail -n 1 | awk '{print $3}')
       Time_0=$(cat access-4560-644067.log | grep Label | tail -n 1 | awk '{print $2}')
       let "report_arg=$str_num+2"
       echo $report_arg, $Time_0, $n
       Log_Read $report_arg
       report $q
    fi
rm -f "$lockfile"
   trap - INT TERM EXIT
else
   echo "Failed to acquire lockfile: $lockfile."
   echo "Held by $(cat $lockfile)"
fi

