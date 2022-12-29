#!/bin/bash

# config
# ---------------------------------
solvesfile="${HOME}/clicube.csv"
scramblesize=20
timerpattern="|"
patternlength="10"
# ---------------------------------

function scramble()
{
  num_moves=$scramblesize
  moves=(U U\' U2 D D\' D2 F F\' F2 B B\' B2 L L\' L2 R R\' R2)

  thescramble=""
  last_move=""
  for ((i=0; i<num_moves; i++)); do
    move=${moves[$RANDOM % ${#moves[@]}]}
    while [[ "$move" == "$last_move" || \
             "${move:0:1}" == "${last_move:0:1}" || \
             "$move" == "${last_move:0:2}" || \
             "${move:0:1}" == "${last_move:1:1}" || \
             "${move:0:2}" == "${last_move:1:2}" || \
             "${move:1:1}" == "${last_move:0:1}" ]]; \
    do
      move=${moves[$RANDOM % ${#moves[@]}]}
    done
    thescramble="$thescramble $move"
    last_move=$move
  done
  echo "${thescramble}" | sed -e 's/^[[:space:]]*//'
}

function showlog() 
{
  toshow=$1
  echo ; echo "Last ${toshow}:" ; echo
  sort -r $solvesfile | head -${toshow} | awk -F, '{print " - "$1" = "$2}'
}

function minmax()
{
  IFS=" "
  local numbers=($@)
  min=${numbers[0]}
  max=${numbers[0]}
  for number in ${numbers[@]:1}
  do
    if [[ $number < $min ]]
    then
        min=$number
    fi
    if [[ $number > $max ]]
    then
        max=$number
    fi
  done
  echo "$min $max"
}

function stats()
{
  totalsolves=$(cat $solvesfile | wc | awk '{print $1}')
  numbers=""
  while read element
  do
    numbers="${numbers} ${element}"
  done < <(cat $solvesfile | awk -F, '{print $2}')
  minandmax=$(minmax "$numbers")
  min=$(echo $minandmax | awk '{print $1}')
  max=$(echo $minandmax | awk '{print $2}')
  today=$(date +%Y-%m-%d)
  todaycount=$(cat $solvesfile |grep $today | wc | awk '{print $1}')
  echo "solves: $totalsolves  today: $todaycount  best: $min  worst: $max"
} 

function mo3()
{
  if [ "$(head -3 $solvesfile | wc | awk '{print $1}')" != "3" ];then
    return 
  fi
  total="0"
  while read value
  do
    total=$(awk "BEGIN {print $total + $value}")
  done < <(sort -r $solvesfile | head -3 | awk -F, '{print $2}')
  mo3=$(awk "BEGIN {print $total / 3}")
  printf "mo3|%0.2f" $mo3
}

function aox()
{
  countcheck=$(head -${1} $solvesfile | wc | awk '{print $1}')
  if [ "$countcheck" != "$1" ]; then
    return
  fi
  title="ao${1}" ; numbers="" ; total="0" ; totalcount="0"
  while read element
  do
    numbers="${numbers} ${element}"
  done < <(sort -r $solvesfile | head -${1} | awk -F, '{print $2}')
  minandmax=$(minmax "$numbers")
  min=$(echo $minandmax | awk '{print $1}')
  max=$(echo $minandmax | awk '{print $2}')
  while read value
  do
    if [ "$value" != $max ] && [ "$value" != "$min" ]; then
      total=$(awk "BEGIN {print $total + $value}")
      totalcount=$((totalcount+1))
    fi
  done < <(sort -r $solvesfile | head -${1} | awk -F, '{print $2}')
  aof=$(awk "BEGIN {print $total / $totalcount}")
  printf "${title}|%0.2f" $aof
}

tput civis
timeresult=false ; del_time=false ; log_change=false ; globallog="5"
spacer="                    "

touch $solvesfile

while true; do
  counter=0
  if ! $del_time && ! $log_change; then
    scramble=$(scramble)
  else
    if ! $log_change; then
      del_time=false
      thetime=$(tail -1 $solvesfile | awk -F, '{print $2}')
      sed -i '$ d' ${solvesfile}
      echo ; echo "deleting time ${thetime}... "
      sleep 1
      timeresult=false
    fi
  fi

  clear
  key="RESET"
  timer_running=false
  iteration_one=true

  if $timeresult ; then
    clear
    echo ; echo "${scramble}"
    echo ; printf "${spacer}%0.2f" $result
    if ! $another_scramble && ! $log_change; then
      echo "`date +%Y-%m-%d" "%H:%M:%S`,${result},${scramble}" >> $solvesfile
    fi
    echo ; showlog "${globallog}"
    echo ; stats
    echo ; mo3 ; echo -n "  " ; aox "5" ; echo -n "  " ; aox "12" ; echo -n "  " ; aox "25" ; echo -n "  " ; aox "50" ; echo -n "  " ; aox "100"
    echo ; echo ; echo "[space] / [s]cramble / [d]elete / [q]uit"
  else
    echo ; echo "${scramble}" ; echo
    echo ; showlog "${globallog}"
    echo ; stats
    echo ; mo3 ; echo -n "  " ; aox "5" ; echo -n "  " ; aox "12" ; echo -n "  " ; aox "25" ; echo -n "  " ; aox "50" ; echo -n "  " ; aox "100"
    echo ; echo ; echo "[space] / [s]cramble / [d]elete / [q]uit"
  fi

  another_scramble=false
  log_change=false

  while [ "$key" != " " ] && IFS=""; do
   read -s -n 1 -t 0.1 key
   if [ "$key" == "q" ]; then
     tput cnorm
     echo ; exit
   elif [ "$key" == "s" ]; then
     another_scramble=true
     break
   elif [ "$key" == "d" ]; then
     del_time=true
     break
   elif [[ "$key" =~ ^[1-9]+$ ]]; then
     globallog=$((5 * $key))
     log_change=true
     break
   fi
  done

  if $another_scramble || $del_time || $log_change ; then
    continue
  fi 

  clear
  echo ; echo "${scramble}"
  echo ; echo "${spacer}ready..." ; echo

  while true && IFS=""; do
    read -s -n 1 -t 0.1 key
    
    # If the timer is not running and the space key was released, start the timer
    if ! $timer_running && [[ -z $key ]]; then
      if ! $iteration_one ; then
        clear
        echo ; echo ; echo ; echo -n "${spacer}${timerpattern}" # GO!
      fi
      timer_running=true
      start_time=$(date +%s%N)
    # If the timer is running and the space key was pressed, stop the timer
    elif $timer_running && [[ $key == " " ]]; then
      timer_running=false
      end_time=$(date +%s%N)
  
      elapsed_milliseconds=$((end_time - start_time))
      result=$(awk "BEGIN {printf \"%.2f\", $elapsed_milliseconds/1000000000}")
  
      if  $iteration_one ; then
        iteration_one=false
      else
        timeresult=true
        break
      fi
    fi
    if [ "$timer_running" ] && [[ -z $key ]] && ! $iteration_one ; then
      if [ $counter -le ${patternlength} ]; then
        echo -n "${timerpattern}"
        counter=$((counter+1))
      else
        clear
        echo ; echo ; echo ; echo -n "${spacer}${timerpattern}" # GO!
        counter=0
      fi
    fi
  done
done

tput cnorm

exit
