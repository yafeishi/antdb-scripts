#!/bin/bash
# remote commmand


command=$1
sshoption=$2

hosts="adb01 adb02 adb03 adb04 adb05 adb06 adb07 adb08"

for host in ${hosts[@]} 
do
   echo "---------------"`date`" host is: $host, command is :$command"
   ssh $sshoption $host "$command"
done