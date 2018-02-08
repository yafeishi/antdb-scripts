#!/bin/bash

#minfree=$1
#dropnum=$2
nodropnum=10
dropnum=5

memfree=`cat /proc/meminfo |grep MemFree |awk '{print $2/1024/1024}'`
echo $memfree

# if [ `echo "$max > $min" | bc` -eq 1 ]


if [ `echo "$memfree > $nodropnum" | bc` -eq 1 ];then
   echo "Nothing"
elif [ `echo "$memfree >= $dropnum" | bc` -eq 1 ];then
  sysctl -w vm.drop_caches=2
elif [ `echo "$memfree < $dropnum" | bc` -eq 1 ];then
  sysctl -w vm.drop_caches=3
fi  
  