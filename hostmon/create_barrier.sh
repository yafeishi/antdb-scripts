#!/bin/bash
# 0 7,19 * * *  sh create_barrier.sh >> /data/hostmon/log/create_barrier.log 2>&1

source /home/sh2.2/.bashrc

barrier_id=`date "+%Y_%m_%d_%H_%M" `
coordhost="10.1.226.201"
coordport="17322"
dbname="postgres"
psqlconn="psql -d $dbname -h $coordhost -p $coordport"


$psqlconn -c "create barrier '$barrier_id';"
if [ `echo $?` -eq 0 ]; then
  echo `date "+%Y-%m-%d %H:%M:%S" ` "create barrier $barrier_id succuessed"
else
  echo `date "+%Y-%m-%d %H:%M:%S" ` "create barrier $barrier_id failed" 
fi  