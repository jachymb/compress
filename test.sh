#!/bin/bash

chl=$2
bit=$3
fname=$1

testn() {
  echo -n "$1 "
  t=0
  instfile=lpinstance/${fname}_$1_$bit.lp
  while true; do
    python genCompressInstance.py $fname $chl $1 $bit > $instfile
    clingo -q -t 2 --opt-mode=ignore -c t=$t mindfn.lp $instfile >/dev/null 2>/dev/null
    if [[ $? -ne 20 ]]; then
      echo $t;
      break;
    fi
    ((t++))
  done
}

for i in `seq 100`; do
  testn $i
done
