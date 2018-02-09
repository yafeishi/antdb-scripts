#!/bin/bash 
# stat.sh

echo  "-------------------------------------`date`"
echo ""
echo "connect to oracle processes: `ps -ef|grep "ora2pg - querying table" |grep -v grep |wc -l`"
echo "sending data to file processes: `ps -ef|grep "ora2pg - sending data from" |grep -v grep | wc -l`"
echo "psql copy processes: `ps -ef|grep COPY |grep -v local| grep -v grep | wc -l`"
dstat -am 1 3
#sar -r 1 3
iostat -d sdb -x -k 1 3