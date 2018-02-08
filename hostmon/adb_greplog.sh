#!/bin/bash
# greplog

logdir=$1
grepcontent=$2
filecnt=$3

if [ ! -d "$logdir" ]; then
  echo "please input logdir on the first parameter!"
  exit 1
fi


if [ "x$grepcontent" = "x" ]; then
   echo "please input grep content on the second parameter!"
   exit 1
fi  

if [ "x$filecnt" = "x" ]; then
   filecnt=1
fi   

echo "filecnt:$filecnt"

grep "$grepcontent" `find $logdir -name '*.csv' -mtime 0  -exec ls -rt {} +|tail -$filecnt` |more