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
  IFS=$'\n' sortedArray=($(sort -r <<<"${solvesArray[*]}")) ; unset IFS
  for ((i = 0; i <= $toshow-1; i++)); do
    if [[ ${sortedArray[$i]} ]]; then
      echo "${sortedArray[$i]}" | awk -F, '{print " - "$1" = "$2}'
    fi
  done
}

function minmax()
{
  IFS=" "
  local numbers=($@)
  min=${numbers[0]}
  max=${numbers[0]}
  for number in ${numbers[@]:1}
  do
    if awk "BEGIN {if ($number < $min) exit 0; exit 1}"; then
      min=$number
    fi
    if awk "BEGIN {if ($number > $max) exit 0; exit 1}"; then
      max=$number
    fi
  done
  echo "$min $max"
}

function stats()
{
  totalsolves=${#solvesArray[@]}
  numbers=""

  if $calculateminmax ; then
    while read element
    do
      numbers="${numbers} ${element}"
    done < <(printf '%s\n' "${solvesArray[@]}" | awk -F, '{print $2}')
    minandmax=$(minmax "$numbers")
    min=$(echo $minandmax | awk '{print $1}')
    max=$(echo $minandmax | awk '{print $2}')
    globalmin=$min
    globalmax=$max
  else
    min=$globalmin
    max=$globalmax
  fi

  pb=$min

  today=$(date +%Y-%m-%d)
  yesterday=$(date -u -d @$(($(date +%s)-86400)) +%Y-%m-%d)
  todaycount=$(printf '%s\n' "${solvesArray[@]}" |grep $today | wc | awk '{print $1}')
  yesterdaycount=$(printf '%s\n' "${solvesArray[@]}" |grep $yesterday | wc | awk '{print $1}')
  echo -n "solves|$totalsolves  today|$todaycount  yesterday|$yesterdaycount  best|$min  worst|$max  "
} 

function mo3()
{
  if [ ${#solvesArray[@]} -lt 3 ] ; then
    return 
  fi
  total="0"
  IFS=$'\n' sortedArray=($(sort -r <<<"${solvesArray[*]}")) ; unset IFS
  while read value
  do
    total=$(awk "BEGIN {print $total + $value}")
  done < <(printf '%s\n' "${sortedArray[@]}" | head -3 | awk -F, '{print $2}')
  mo3=$(awk "BEGIN {print $total / 3}")
  printf "mo3|%0.2f" $mo3
}

function aox()
{
  if [ "$2" == "" ]; then
    goback="1"
  else
    goback="$2" # 2 == previous time
  fi
  if [ ${#solvesArray[@]} -lt $1 ]; then
    return
  fi

  IFS=$'\n' sortedArray=($(sort -r <<<"${solvesArray[*]}")) ; unset IFS

  title="ao${1}" ; numbers="" ; total="0" ; totalcount="0"

  while read element
  do
    numbers="${numbers} ${element}"
  done < <(printf '%s\n' "${sortedArray[@]}" | tail -n +${goback} | head -${1} | awk -F, '{print $2}')

  minandmax=$(minmax "$numbers")
  min=$(echo $minandmax | awk '{print $1}')
  max=$(echo $minandmax | awk '{print $2}')

  while read value
  do
    if [ "$value" != $max ] && [ "$value" != "$min" ]; then
      total=$(awk "BEGIN {print $total + $value}")
      totalcount=$((totalcount+1))
    fi
  done < <(printf '%s\n' "${sortedArray[@]}" | tail -n +${goback} | head -${1} | awk -F, '{print $2}')

  aof=$(awk "BEGIN {print $total / $totalcount}")

  printf "${title}|%0.2f" $aof
}

#
# main code starts
#

tput civis
timeresult=false ; del_time=false ; log_change=false ; globallog="5" 
calculateprevious=true
calculateminmax=true
showprevao=true
pb=9999
spacer="                    "

touch $solvesfile

# put file into array
mapfile -t solvesArray < $solvesfile

while true; do
  counter=0
  if ! $del_time && ! $log_change; then
    scramble=$(scramble)
  else
    if ! $log_change; then
      del_time=false
      thetime=$(tail -1 $solvesfile | awk -F, '{print $2}')
      sed -i --follow-symlinks '$ d' ${solvesfile}
      unset solvesArray[-1]
      calculateprevious=true
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

    if ! $calculateminmax ; then
      if awk "BEGIN {if ($result < $globalmin) exit 0; exit 1}"; then
        globalmin=$result
      fi
      if awk "BEGIN {if ($result > $globalmax) exit 0; exit 1}"; then
        globalmax=$result
      fi
    fi

    clear
    echo ; echo "${scramble}"
    echo ; printf "${spacer}%0.2f" $result
    if ! $another_scramble && ! $log_change; then
      echo "`date +%Y-%m-%d" "%H:%M:%S`,${result},${scramble}" >> $solvesfile
      solvesArray+=("`date +%Y-%m-%d" "%H:%M:%S`,${result},${scramble}")
    fi

  else
    echo ; echo "${scramble}" ; echo
  fi

  echo ; showlog "${globallog}"
  echo ; stats ; mo3
  echo ; echo

  if [[ "${#globalmin}" -eq 0 ]] || [ "${globalmax}" == "${globalmin}" ] ; then
    calculateminmax=true
  else
    calculateminmax=false
  fi

  ao5=$(aox "5")
  ao5val=$(echo ${ao5} | awk -F\| '{print $2}')
  ao12=$(aox "12")
  ao12val=$(echo ${ao12} | awk -F\| '{print $2}')
  ao25=$(aox "25")
  ao25val=$(echo ${ao25} | awk -F\| '{print $2}')
  ao50=$(aox "50")
  ao50val=$(echo ${ao50} | awk -F\| '{print $2}')
  ao100=$(aox "100")
  ao100val=$(echo ${ao100} | awk -F\| '{print $2}')

  if $calculateprevious && $showprevao; then
    ao5p=$(aox "5" "2")
    ao5pval=$(echo ${ao5p} | awk -F\| '{print $2}')
    ao5pvalArray+=("${ao5pval}")
    ao5pvalArray+=("${ao5pval}")
  
    ao12p=$(aox "12" "2")
    ao12pval=$(echo ${ao12p} | awk -F\| '{print $2}')
    ao12pvalArray+=("${ao12pval}")
    ao12pvalArray+=("${ao12pval}")
  
    ao25p=$(aox "25" "2")
    ao25pval=$(echo ${ao25p} | awk -F\| '{print $2}')
    ao25pvalArray+=("${ao25pval}")
    ao25pvalArray+=("${ao25pval}")
  
    ao50p=$(aox "50" "2")
    ao50pval=$(echo ${ao50p} | awk -F\| '{print $2}')
    ao50pvalArray+=("${ao50pval}")
    ao50pvalArray+=("${ao50pval}")
  
    ao100p=$(aox "100" "2")
    ao100pval=$(echo ${ao100p} | awk -F\| '{print $2}')
    ao100pvalArray+=("${ao100pval}")
    ao100pvalArray+=("${ao100pval}")

    calculateprevious=false
  
  else

    if ! $another_scramble && $showprevao; then
      ao5pvalArray+=("${ao5val}")
      ao12pvalArray+=("${ao12val}")
      ao25pvalArray+=("${ao25val}")
      ao50pvalArray+=("${ao50val}")
      ao100pvalArray+=("${ao100val}")
    fi

  fi

  if $showprevao; then 
    if [ ${ao5pvalArray[-2]} ]; then
      ao5diff="($(awk "BEGIN {printf \"%.2f\", $ao5val-${ao5pvalArray[-2]}}"))"
    fi
    if [ ${ao12pvalArray[-2]} ]; then
      ao12diff="($(awk "BEGIN {printf \"%.2f\", $ao12val-${ao12pvalArray[-2]}}"))"
    fi
    if [ ${ao25pvalArray[-2]} ]; then
      ao25diff="($(awk "BEGIN {printf \"%.2f\", $ao25val-${ao25pvalArray[-2]}}"))"
    fi
    if [ ${ao50pvalArray[-2]} ]; then
      ao50diff="($(awk "BEGIN {printf \"%.2f\", $ao50val-${ao50pvalArray[-2]}}"))"
    fi
    if [ ${ao100pvalArray[-2]} ]; then
      ao100diff="($(awk "BEGIN {printf \"%.2f\", $ao100val-${ao100pvalArray[-2]}}"))"
    fi
  else
    ao5diff=""
    ao12diff=""
    ao25diff=""
    ao50diff=""
    ao100diff=""
  fi

  echo -n "$ao5$ao5diff  $ao12$ao12diff  $ao25$ao25diff  $ao50$ao50diff  $ao100$ao100diff"
  echo ; echo ; echo "[space] / [s]cramble / [d]elete / [p]reviousdiff / [q]uit"

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
     calculateminmax=true
     break
   elif [ "$key" == "p" ]; then
     if $showprevao; then
       showprevao=false
     else
       showprevao=true
     fi
     log_change=true
     break
   elif [[ "$key" =~ ^[1-9]+$ ]]; then
     globallog=$((5 * $key))
     log_change=true
     calculateprevious=true
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
        checkpb=$(minmax "$result $pb" | awk '{print $1}')
        if [ $result == $checkpb ]; then
          clear ; echo ; echo ; echo
          echo  "$spacerNEW  * * * NEW PB * * *    $result    * * * NEW PB * * *"
          sleep 3
        fi
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
