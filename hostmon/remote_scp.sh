#!/bin/bash
# remote scp


file=$1
scpoption=$2

hosts="adb02 adb03 adb04 adb05 adb06 adb07 adb08"

for host in ${hosts[@]} 
do
   echo "---------------"`date`" host is: $host, scp file is :$file"
   scp $scpoption $file $host:$file 
done
