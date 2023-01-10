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
  ascramble=$2
  atime=$(check_for_mins $3)

  echo ; echo "Last ${toshow}:"
  IFS=$'\n' sortedArray=($(sort -r <<<"${solvesArray[*]}")) ; unset IFS
  echo ".--------------------------------."
  for ((i = 0; i <= $toshow-1; i++)); do
    if [[ ${sortedArray[$i]} ]]; then
      if [ "$i" -gt 0 ]; then
        if [ "$i" -eq 3 ]; then
          thetime=$(check_for_mins $(echo ${sortedArray[$i]} | awk -F, '{print $2}'))
          echo "${sortedArray[$i]}" | awk -F, '{printf "| %19s | ",$1}'
          printf "%8s |" $thetime
          if [ "$atime" != "" ]; then
            echo "  Time  ==>  ${atime}"
          else
            echo
          fi
        else
          thetime=$(check_for_mins $(echo ${sortedArray[$i]} | awk -F, '{print $2}'))
          echo "${sortedArray[$i]}" | awk -F, '{printf "| %19s | ",$1}'
          printf "%8s |\n" $thetime
        fi
      else
        thetime=$(check_for_mins $(echo ${sortedArray[$i]} | awk -F, '{print $2}'))
        echo "${sortedArray[$i]}" | awk -F, '{printf "| %19s | ",$1}'
        printf "%8s |" $thetime
        echo "  ${ascramble}"
      fi
    else
      if [ "$i" -gt 0 ]; then
        if [ "$i" -eq 3 ]; then
          printf "| %19s | %8s |" " " " "
          echo "  ${atime}"
        else
          printf "| %19s | %8s |\n" " " " "
        fi
      else
        printf "| %19s | %8s |" " " " "
        echo "  ${ascramble}"
      fi
    fi
  done

  echo "'--------------------------------'"
}

function streakinit()
{
  global10allowcalc=true
  global15allowcalc=true
  global20allowcalc=true
  global25allowcalc=true
  global30allowcalc=true
  echo "loading..."
  global10=0
  global10ht=0
  global15=0
  global15ht=0
  global20=0
  global20ht=0
  global25=0
  global25ht=0
  global30=0
  global30ht=0
  IFS=$'\n' sortedArray=($(sort -r <<<"${solvesArray[*]}")) ; unset IFS
  for record in "${sortedArray[@]}"; do
    thetime=$(echo "$record" | awk -F, '{print $2}')
    if awk "BEGIN {if ($thetime < 10) exit 0; exit 1}"; then
      if $global10allowcalc; then
        global10=$((global10 + 1))
        global10ht=$((global10ht + 1))
      fi
      if $global15allowcalc; then
        global15=$((global15 + 1))
        global15ht=$((global15ht + 1))
      fi
      if $global20allowcalc; then
        global20=$((global20 + 1))
        global20ht=$((global20ht + 1))
      fi
      if $global25allowcalc; then
        global25=$((global25 + 1))
        global25ht=$((global25ht + 1))
      fi
      if $global30allowcalc; then
        global30=$((global30 + 1))
        global30ht=$((global30ht + 1))
      fi
    elif awk "BEGIN {if ($thetime < 15) exit 0; exit 1}"; then
      global10allowcalc=false
      if $global15allowcalc; then
        global15=$((global15 + 1))
        global15ht=$((global15ht + 1))
      fi
      if $global20allowcalc; then
        global20=$((global20 + 1))
        global20ht=$((global20ht + 1))
      fi
      if $global25allowcalc; then
        global25=$((global25 + 1))
        global25ht=$((global25ht + 1))
      fi
      if $global30allowcalc; then
        global30=$((global30 + 1))
        global30ht=$((global30ht + 1))
      fi
    elif awk "BEGIN {if ($thetime < 20) exit 0; exit 1}"; then
      global10allowcalc=false
      global15allowcalc=false
      if $global20allowcalc; then
        global20=$((global20 + 1))
        global20ht=$((global20ht + 1))
      fi
      if $global25allowcalc; then
        global25=$((global25 + 1))
        global25ht=$((global25ht + 1))
      fi
      if $global30allowcalc; then
        global30=$((global30 + 1))
        global30ht=$((global30ht + 1))
      fi
    elif awk "BEGIN {if ($thetime < 25) exit 0; exit 1}"; then
      global10allowcalc=false
      global15allowcalc=false
      global20allowcalc=false
      if $global25allowcalc; then
        global25=$((global25 + 1))
        global25ht=$((global25ht + 1))
      fi
      if $global30allowcalc; then
        global30=$((global30 + 1))
        global30ht=$((global30ht + 1))
      fi
    elif awk "BEGIN {if ($thetime < 30) exit 0; exit 1}"; then
      global10allowcalc=false
      global15allowcalc=false
      global20allowcalc=false
      global25allowcalc=false
      if $global30allowcalc; then
        global30=$((global30 + 1))
        global30ht=$((global30ht + 1))
      fi
    elif awk "BEGIN {if ($thetime > 30) exit 0; exit 1}"; then
      break 
    fi
  done
}

function streakupdate()
{
  thetime=$1
  if awk "BEGIN {if ($thetime < 10) exit 0; exit 1}"; then
    global10=$((global10 + 1))
    global10ht=$((global10ht + 1))
    global15=$((global15 + 1))
    global15ht=$((global15ht + 1))
    global20=$((global20 + 1))
    global20ht=$((global20ht + 1))
    global25=$((global25 + 1))
    global25ht=$((global25ht + 1))
    global30=$((global30 + 1))
    global30ht=$((global30ht + 1))
  elif awk "BEGIN {if ($thetime < 15) exit 0; exit 1}"; then
    global10=0
    global10ht=0
    global15=$((global15 + 1))
    global15ht=$((global15ht + 1))
    global20=$((global20 + 1))
    global20ht=$((global20ht + 1))
    global25=$((global25 + 1))
    global25ht=$((global25ht + 1))
    global30=$((global30 + 1))
    global30ht=$((global30ht + 1))
  elif awk "BEGIN {if ($thetime < 20) exit 0; exit 1}"; then
    global10=0
    global10ht=0
    global15=0
    global15ht=0
    global20=$((global20 + 1))
    global20ht=$((global20ht + 1))
    global25=$((global25 + 1))
    global25ht=$((global25ht + 1))
    global30=$((global30 + 1))
    global30ht=$((global30ht + 1))
  elif awk "BEGIN {if ($thetime < 25) exit 0; exit 1}"; then
    global10=0
    global10ht=0
    global15=0
    global15ht=0
    global20=0
    global20ht=0
    global25=$((global25 + 1))
    global25ht=$((global25ht + 1))
    global30=$((global30 + 1))
    global30ht=$((global30ht + 1))
  elif awk "BEGIN {if ($thetime < 30) exit 0; exit 1}"; then
    global10=0
    global10ht=0
    global15=0
    global15ht=0
    global20=0
    global20ht=0
    global25=0
    global25ht=0
    global30=$((global30 + 1))
    global30ht=$((global30ht + 1))
  elif awk "BEGIN {if ($thetime > 30) exit 0; exit 1}"; then
    global10=0
    global10ht=0
    global15=0
    global15ht=0
    global20=0
    global20ht=0
    global25=0
    global25ht=0
    global30=0
    global30ht=0
  fi
}

function hatricks()
{
  if [ $global10ht -eq 3 ]; then
    if $congrats10enabled; then
      congrats "AMAZE BALLZ !!!" "SUB 10 HATRICK" 5
    fi
    global10ht=0
  elif [ $global15ht -eq 3 ]; then
    if $congrats15enabled; then
      congrats "O M G !" "SUB 15 HATRICK" 3
    fi
    global15ht=0
  elif [ $global20ht -eq 3 ]; then
    if $congrats20enabled; then
      congrats "yeah baby yeah!" "SUB 20 HATRICK" 3
    fi
    global20ht=0
  elif [ $global25ht -eq 3 ]; then
    if $congrats25enabled; then
      congrats "noice!" "SUB 25 HATRICK" 3
    fi
    global25ht=0
  elif [ $global30ht -eq 3 ]; then
    if $congrats30enabled; then
      congrats "yay" "SUB 30 HATRICK" 2
    fi
    global30ht=0
  fi
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
  amo3=$1
  totalsolves=${#solvesArray[@]}
  globalsolves=$totalsolves
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
  yesterday=$(date --date='yesterday' +%Y-%m-%d)
  todaycount=$(printf '%s\n' "${solvesArray[@]}" |grep $today | wc | awk '{print $1}')
  yesterdaycount=$(printf '%s\n' "${solvesArray[@]}" |grep $yesterday | wc | awk '{print $1}')
  totaldays=$(printf '%s\n' "${solvesArray[@]}" |awk '{print $1}' | sort -u | wc | awk '{print $1}')
  avgpday=$((totalsolves/totaldays))

  # solves
  printf "%-11s %-14s %-14s %-14s %-14s %-14s\n" " " "total" "today" "yesterday" "total-days" "avg-per-day"
  printf "%11s %-14s %-14s %-14s %-14s %-14s\n" "solves:" $totalsolves $todaycount $yesterdaycount $totaldays $avgpday

  echo

  todayminmax=$(todaystats)
  todaymin=$(echo $todayminmax | awk '{print $1}')
  todaymax=$(echo $todayminmax | awk '{print $2}')
  todayminglobal=$todaymin

  minfmt=$(check_for_mins $min)
  maxfmt=$(check_for_mins $max)
  todayminfmt=$(check_for_mins $todaymin)
  todaymaxfmt=$(check_for_mins $todaymax)
  amo3fmt=$(check_for_mins $amo3)

  # times
  printf "%-11s %-14s %-14s %-14s %-14s %-14s\n" " " "best" "worst" "best-today" "worst-today" "mo3"
  printf "%11s %-14s %-14s %-14s %-14s %-14s" "times:" $minfmt $maxfmt $todayminfmt $todaymaxfmt $amo3fmt
} 

function todaystats()
{
  numbers=""
  today=$(date +%Y-%m-%d)
  while read element
  do
    numbers="${numbers} ${element}"
  done < <(printf '%s\n' "${solvesArray[@]}" | grep ${today} | awk -F, '{print $2}')
  minandmax=$(minmax "$numbers")
  echo "$minandmax"
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
  printf "%0.2f" $mo3
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

  printf "%0.2f" $aof
}

function congrats()
{
  if [[ "$1" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
    atime=$(check_for_mins $1)
  else
    atime=$1
  fi
  amessage=$2
  asleeptime=$3
  clear ; echo ; echo ; echo
  echo  "$spacerNEW  * * * ${amessage} * * *    ${atime}    * * * ${amessage} * * *"
  sleep $asleeptime
}

function check_for_mins {
  if [ "$1" != "" ]; then
    if awk "BEGIN {if ($1 >= 60) exit 0; exit 1}"; then
      local int_seconds=$(printf "%.0f" "$1")
      local hundredths=$(printf "%.2f" "$1")
      local hundredths=${hundredths#*.}
      local minutes=$((int_seconds / 60))
      local seconds=$((int_seconds % 60))
      if [ "$minutes" -lt 10 ]; then
        minutes="0$minutes"
      fi
      if [ "$seconds" -lt 10 ]; then
        seconds="0$seconds"
      fi
      echo "${minutes}:${seconds}.${hundredths}"
    else
      echo $1
    fi
  fi
}

#
# main code starts
#

tput civis
timeresult=false ; del_time=false ; log_change=false ; reload=false ; globallog="5" 
calculateprevious=true
calculateminmax=true
congrats10enabled=true
congrats15enabled=true
congrats20enabled=true
congrats25enabled=true
congrats30enabled=true
showprevao=true
pb=9999
spacer="                    "

touch $solvesfile
mapfile -t solvesArray < $solvesfile

streakinit

while true; do
  counter=0
  if ! $del_time && ! $log_change && ! $reload; then
    scramble=$(scramble)
  else
    if ! $log_change && ! $reload; then
      del_time=false
      thetime=$(tail -1 $solvesfile | awk -F, '{print $2}')
      sed -i --follow-symlinks '$ d' ${solvesfile}
      unset solvesArray[-1]
      calculateprevious=true
      echo ; echo "deleting time ${thetime}... "
      sleep 1
      timeresult=false
      streakinit
    fi
  fi

  clear
  key="RESET"
  timer_running=false
  iteration_one=true

  if $timeresult ; then

    streakupdate "$result"
    hatricks
    timeresult=false

    if ! $calculateminmax ; then
      if awk "BEGIN {if ($result < $globalmin) exit 0; exit 1}"; then
        globalmin=$result
      fi
      if awk "BEGIN {if ($result > $globalmax) exit 0; exit 1}"; then
        globalmax=$result
      fi
    fi
    clear
    formattedresult=$(printf "%0.2f" $result)
    if ! $another_scramble && ! $log_change && ! $reload; then
      echo "`date +%Y-%m-%d" "%H:%M:%S`,${result},${scramble}" >> $solvesfile
      solvesArray+=("`date +%Y-%m-%d" "%H:%M:%S`,${result},${scramble}")
    fi
  else
    if ! $another_scramble && ! $log_change; then
      formattedresult=""
    fi
  fi

  showlog "${globallog}" "${scramble}" "${formattedresult}"
  themo3=$(mo3)
  echo ; stats "$themo3"
  echo ; echo

  if [[ "${#globalmin}" -eq 0 ]] || [ "${globalmax}" == "${globalmin}" ] ; then
    calculateminmax=true
  else
    calculateminmax=false
  fi

  ao5=$(aox "5")
  ao12=$(aox "12")
  ao25=$(aox "25")
  ao50=$(aox "50")
  ao100=$(aox "100")

  if $calculateprevious && $showprevao; then
    ao5p=$(aox "5" "2")
    ao5pvalArray+=("${ao5p}")
    ao5pvalArray+=("${ao5p}")
  
    ao12p=$(aox "12" "2")
    ao12pvalArray+=("${ao12p}")
    ao12pvalArray+=("${ao12p}")
  
    ao25p=$(aox "25" "2")
    ao25pvalArray+=("${ao25p}")
    ao25pvalArray+=("${ao25p}")
  
    ao50p=$(aox "50" "2")
    ao50pvalArray+=("${ao50p}")
    ao50pvalArray+=("${ao50p}")
  
    ao100p=$(aox "100" "2")
    ao100pvalArray+=("${ao100p}")
    ao100pvalArray+=("${ao100p}")

    calculateprevious=false
  
  else

    if ! $another_scramble && $showprevao; then
      ao5pvalArray+=("${ao5}")
      ao12pvalArray+=("${ao12}")
      ao25pvalArray+=("${ao25}")
      ao50pvalArray+=("${ao50}")
      ao100pvalArray+=("${ao100}")
    fi

  fi

  if $showprevao; then 
    if [ ${ao5pvalArray[-2]} ]; then
      ao5diff="($(awk "BEGIN {printf \"%.2f\", $ao5-${ao5pvalArray[-2]}}"))"
    fi
    if [ ${ao12pvalArray[-2]} ]; then
      ao12diff="($(awk "BEGIN {printf \"%.2f\", $ao12-${ao12pvalArray[-2]}}"))"
    fi
    if [ ${ao25pvalArray[-2]} ]; then
      ao25diff="($(awk "BEGIN {printf \"%.2f\", $ao25-${ao25pvalArray[-2]}}"))"
    fi
    if [ ${ao50pvalArray[-2]} ]; then
      ao50diff="($(awk "BEGIN {printf \"%.2f\", $ao50-${ao50pvalArray[-2]}}"))"
    fi
    if [ ${ao100pvalArray[-2]} ]; then
      ao100diff="($(awk "BEGIN {printf \"%.2f\", $ao100-${ao100pvalArray[-2]}}"))"
    fi
  else
    ao5diff=""
    ao12diff=""
    ao25diff=""
    ao50diff=""
    ao100diff=""
  fi

  # ao's

  ao5fmt=$(check_for_mins $ao5)
  ao12fmt=$(check_for_mins $ao12)
  ao25fmt=$(check_for_mins $ao25)
  ao50fmt=$(check_for_mins $ao50)
  ao100fmt=$(check_for_mins $ao100)

  printf "%-11s %-14s %-14s %-14s %-14s %-14s\n" " " "ao5" "ao12" "ao25" "ao50" "ao100"
  printf "%11s %-14s %-14s %-14s %-14s %-14s\n" "averages:" $ao5fmt $ao12fmt $ao25fmt $ao50fmt $ao100fmt

  if $showprevao ; then
    printf "%11s %-14s %-14s %-14s %-14s %-14s\n" " " $ao5diff $ao12diff $ao25diff $ao50diff $ao100diff
  fi

  # streaks
  printf "\n%-11s %-14s %-14s %-14s %-14s %-14s\n" " " "<10" "<15" "<20" "<25" "<30"
  printf "%11s %-14s %-14s %-14s %-14s %-14s\n" "streaks:" $global10 $global15 $global20 $global25 $global30

  echo
  echo ; echo ; echo "[space] / [s]cramble / [d]elete / [p]reviousdiff / [c]ongrats / [q]uit"

  another_scramble=false
  log_change=false
  reload=false

  while [ "$key" != " " ] && IFS=""; do
   read -s -n 1 -t 0.1 key
   if [ "$key" == "q" ]; then
     tput cnorm
     echo ; exit
   elif [ "$key" == "s" ]; then
     another_scramble=true
     timeresult=false
     break
   elif [ "$key" == "d" ]; then
     del_time=true
     calculateminmax=true
     break
   elif [ "$key" == "c" ]; then
     reload=true
     if ! $congrats10enabled && ! $congrats15enabled && ! $congrats20enabled && ! $congrats25enabled && ! $congrats30enabled; then
       congrats10enabled=true
       congrats15enabled=true
       congrats20enabled=true
       congrats25enabled=true
       congrats30enabled=true
       echo ; echo "CONGRATULATIONS:   <10|enabled  <15|enabled  <20|enabled  <25|enabled  <30|enabled" ; echo ; sleep 2
     elif $congrats10enabled && $congrats15enabled && $congrats20enabled && $congrats25enabled && $congrats30enabled; then
       congrats10enabled=true
       congrats15enabled=true
       congrats20enabled=true
       congrats25enabled=true
       congrats30enabled=false
       echo ; echo "CONGRATULATIONS:   <10|enabled  <15|enabled  <20|enabled  <25|enabled  <30|DISABLED" ; echo ; sleep 2
     elif $congrats10enabled && $congrats15enabled && $congrats20enabled && $congrats25enabled && ! $congrats30enabled; then
       congrats10enabled=true
       congrats15enabled=true
       congrats20enabled=true
       congrats25enabled=false
       congrats30enabled=false
       echo ; echo "CONGRATULATIONS:   <10|enabled  <15|enabled  <20|enabled  <25|DISABLED  <30|DISABLED" ; echo ; sleep 2
     elif $congrats10enabled && $congrats15enabled && $congrats20enabled && ! $congrats25enabled && ! $congrats30enabled; then
       congrats10enabled=true
       congrats15enabled=true
       congrats20enabled=false
       congrats25enabled=false
       congrats30enabled=false
       echo ; echo "CONGRATULATIONS:   <10|enabled  <15|enabled  <20|DISABLED  <25|DISABLED  <30|DISABLED" ; echo ; sleep 2
     elif $congrats10enabled && $congrats15enabled && ! $congrats20enabled && ! $congrats25enabled && ! $congrats30enabled; then
       congrats10enabled=true
       congrats15enabled=false
       congrats20enabled=false
       congrats25enabled=false
       congrats30enabled=false
       echo ; echo "CONGRATULATIONS:   <10|enabled  <15|DISABLED  <20|DISABLED  <25|DISABLED  <30|DISABLED" ; echo ; sleep 2
     elif $congrats10enabled && ! $congrats15enabled && ! $congrats20enabled && ! $congrats25enabled && ! $congrats30enabled; then
       congrats10enabled=false
       congrats15enabled=false
       congrats20enabled=false
       congrats25enabled=false
       congrats30enabled=false
       echo ; echo "CONGRATULATIONS:   <10|DISABLED  <15|DISABLED  <20|DISABLED  <25|DISABLED  <30|DISABLED" ; echo ; sleep 2
     fi
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

  if $another_scramble || $del_time || $log_change || $reload ; then
    continue
  fi 

  clear
  echo ; echo ; echo
  printf "   %19s    %8s  " " " " "
  echo "${scramble}"
  echo ; echo
  printf "   %19s    %8s  " " " " "
  echo "ready..."

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
        checktodaypb=$(minmax "$result $todayminglobal" | awk '{print $1}')
        thousandcheck=$((globalsolves + 1))

        if [ $result == $checkpb ]; then
          congrats $result "NEW PB" "3"
        elif [ $result == $checktodaypb ]; then
          congrats $result "BEST TIME TODAY" "2"
        fi

        if [ $((thousandcheck % 1000)) -eq 0 ]; then
          congrats "YOU'VE COMPLETED $thousandcheck SOLVES !!" " TOTES AWESOME" 10
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
