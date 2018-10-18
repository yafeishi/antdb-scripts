#!/bin/bash
#sh agent.sh

source $HOME/.bashrc

adbuser=adb
mgrhost=""
mgrport=8430
mgr_conn='psql -p $mgrport -d postgres -h $mgrhost'
monpwd=""
logfile=${monpwd}/monitor_agent.log


Writelog()
{     
    echo -e "$(date +"%Y-%m-%d") $(date +"%H:%M:%S")[INFO] $@" >> $logfile 2>&1
}

agent_not_running=`$mgr_conn -q -t -c "monitor agent all"|grep "not running"|wc -l`
if [ $agent_not_running -ne 0 ];then
    echo "--"`date "+%Y-%m-%d %H:%M:%S"` "--need to start agent  !" >> $logfile >2&1
    $mgr_conn -q -t -c "start agent all"
fi

