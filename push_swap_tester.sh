#!/bin/bash

count_bits() {
    num=$1
    bits=0
    while [ $num -gt 0 ]; do
        bits=$((bits + 1))
        num=$((num >> 1))
    done
    echo $bits
}

while getopts ":p:e:t:o:s:c:v" opt; do
  case $opt in
    p)
      push_swap=$OPTARG
      ;;
    e)
      range=$OPTARG
      ;;
    o)
      offset=$OPTARG
      ;;
    s)
      start=$OPTARG
      ;;
    t)
      iterations=$OPTARG
      ;;
    c)
      checker=$OPTARG
      ;;
    v)
      valgrind=0
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done

if [ -z "$push_swap" ]
then
  push_swap="push_swap"
fi

if [ -z "$offset" ]
then
  offset=50
fi

if [ -z "$start" ]
then
  start=0
fi

if [ -z "$range" ]
then
  range=500
fi

if [ -z "$iterations" ]
then
  iterations=20
fi

if [ -z "$valgrind" ]
then
  valgrind=1
fi

if [ -z "$checker" ]
then
  checker="checker"
fi

ps_exec=$(realpath $push_swap)
ck_exec=$(realpath $checker)

if [ ! -x "$(command -v $ps_exec )" ] || [ ! -x "$(command -v $ck_exec)" ]; then
    echo "push_swap or checker executables not found or not executable"
    exit 1
fi

for ((i=$start; i<=$range; i+=$offset)); do
  line_sum=0
  success_count=0
  min_line=999999
  max_line=0
  leak_detected=false
  for ((j=0; j<$iterations; j++)); do
    random_list=$(echo $(shuf -i 0-$i -n $i) | tr '\n' ' ')
    output=$($ps_exec $random_list 2> /dev/null)
    line_count=$(echo -n "$output" | wc -l)
    line_sum=$((line_sum + line_count))
    if [ "$valgrind" -eq 0 ]; then
      valgrind_output=$(valgrind --leak-check=full --log-fd=9 9>&1 $ps_exec $random_list > /dev/null)
    fi
    if [ "$line_count" -gt $max_line ]; then
        max_line=$line_count
    fi
    if [ "$line_count" -lt $min_line ]; then
        min_line=$line_count
    fi
    if [ "$output" ]; then
      checker_output=$(echo "$output" | $ck_exec $random_list 2> /dev/null)
    else
      checker_output=$(: | $ck_exec $random_list 2> /dev/null)
    fi
    if [ "$checker_output" == "OK" ]; then
      success_count=$((success_count+1))
    fi
    if [ "$valgrind" -eq 0 ]; then
      if ! echo "$valgrind_output" | grep -q "no leaks are possible"; then
          echo -e "\033[0;31m $valgrind_output"
          leak_detected=true
      fi
    fi
  done
  success_rate=$((success_count*100/$iterations))
  line_avg=$((line_sum / $iterations))
  if [ $line_avg -eq 0 ]; then
    bits=0;
  else
    bits=$(count_bits $i)
  fi
  echo -e "\033[0;36m Taille liste: $i  ($iterations tests)"
  if [ "$line_avg" -gt "$(echo "$bits*$i" | bc)" ]; then
    echo -e "\033[0;33m 🟠 Moyenne d'étapes:  \033[0;33m"$line_avg" (+$(echo "$line_avg - $bits*$i" | bc))"
  else
    echo -e "\033[0;32m 🟢 Moyenne d'étapes:  \033[0;32m"$line_avg" ($(echo "$line_avg - $bits*$i" | bc))"
  fi
  if [ "$min_line" -gt "$(echo "$bits*$i" | bc)" ]; then
    echo -e "\033[0;33m 🟠 Minimum d'étapes: \033[0;33m"$min_line" (+$(echo "$min_line - $bits*$i" | bc))"
  else
    echo -e "\033[0;32m 🟢 Minimum d'étapes: \033[0;32m"$min_line" ($(echo "$min_line - $bits*$i" | bc))"
  fi
  if [ "$max_line" -gt "$(echo "$bits*$i" | bc)" ]; then
    echo -e "\033[0;33m 🟠 Maximum d'étapes: \033[0;33m"$max_line" (+$(echo "$max_line - $bits*$i" | bc))"
  else
    echo -e "\033[0;32m 🟢 Maximum d'étapes: \033[0;32m"$max_line" ($(echo "$max_line - $bits*$i" | bc))"
  fi
  if [ $success_rate -lt 50 ]; then
    echo -e "\033[0;31m 🔴 Taux de succès: $success_rate% \033[0m"
  elif [ $success_rate -lt 80 ]; then
    echo -e "\033[0;33m 🟠 Taux de succès: $success_rate% \033[0m"
  elif [ $success_rate -le 100 ]; then
    echo -e "\033[0;32m 🟢 Taux de succès: $success_rate% \033[0m"
  fi
  if [ "$valgrind" -eq 0 ]; then
    if [ "$leak_detected" = true ]; then
      echo -e "\033[31m 🔴 A memory leak was detected during the test. Please check the valgrind output for more details."
    else
      echo -e "\033[32m 🟢 No memory leaks detected during the test."
    fi
 fi
 if [ "$i" == 1 ]; then
  i=0
 fi
done

echo -e "\n\033[0;36m ------ Other checks ------"

int_max_output=$($push_swap "2147483648" 5 4 3 2 1 2> /dev/null)
int_min_output=$($push_swap 5 4 3 2 1 "-2147483649" 2> /dev/null)
if [ "$(echo -n "$int_max_output" | wc -l)" -eq 0 ] && [ "$(echo -n "$int_min_output" | wc -l)" -eq 0 ]; then
    echo -e "\033[32m 🟢 Numbers > INT_MAX and numbers < INT_MIN return an error"
else
    echo -e "\033[31m 🔴 Numbers > INT_MAX and/or numbers < INT_MIN does not return an error"
fi
letter_output=$($push_swap "a" 5 4 3 2 1 2> /dev/null)
if [ "$(echo -n "$letter_output" | wc -l)" -eq 0 ]; then
    echo -e "\033[32m 🟢 Characters return an error"
else
    echo -e "\033[31m 🔴 Characters does not return an error"
fi
empty_output=$($push_swap 2>&1)
if [ "$(echo -n "$empty_output" | grep -c "Error")" -eq 0 ]; then
    echo -e "\033[32m 🟢 Empty argument return nothing"
else
    echo -e "\033[31m 🔴 Empty argument does not return nothing"
fi
echo -e "\033[0m"
