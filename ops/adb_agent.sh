#!/bin/bash
# * * * * *  sh /data/hostmon/shell/monitor_agent.sh > /dev/null

source /home/adb/.bashrc

mgrhost="xxx"
mgrport=6433
adbuser=adb
mgr_conn="psql -h $mgrhost -p $mgrport -d postgres"
logfile=/data/hostmon/log/monitor_agent.log

agent_not=`$mgr_conn -c 'monitor agent all'|grep "not running"|wc -l`
if [ $agent_not -ne 0 ];then
   echo "--"`date "+%Y-%m-%d %H:%M:%S"` "--monitor_agent-- ERROR:there are some agents down !" >> $logfile 2>&1
   $mgr_conn -c 'monitor agent all'|grep "not running"  >> $logfile 2>&1
   echo "--"`date "+%Y-%m-%d %H:%M:%S"` "--monitor_agent-- INFO:start to agent all!" >> $logfile 2>&1
   $mgr_conn -c 'start agent all'
fi