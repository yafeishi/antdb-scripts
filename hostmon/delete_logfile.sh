#!/bin/bash
# psql "port=17321 dbname=postgres options='-c command_mode=sql'"

source /home/adb/.bashrc

function trans_nodetype
{
nodetype=$1
if    [ "$nodetype" = "g" ]; then
    echo "gtm master"
elif  [ "$nodetype" = "p" ]; then  
    echo "gtm slave"
elif  [ "$nodetype" = "e" ]; then  
    echo "gtm extra"
elif  [ "$nodetype" = "c" ]; then  
    echo "coordinator"
elif  [ "$nodetype" = "s" ]; then  
    echo "coordinator slave"
elif  [ "$nodetype" = "d" ]; then  
    echo "datanode master"
elif  [ "$nodetype" = "b" ]; then  
    echo "datanode slave"
elif  [ "$nodetype" = "n" ]; then  
    echo "datanode extra"
fi    
}

function del_file
{
logdir=$1
keep_day=$2
if [ "x$logdir" = "x" -o "x$keep_day" = "x" ]; then
 echo "--"`date "+%Y-%m-%d %H:%M:%S"` "--deletedir-- ERROR:please input the log dir and keep_days !"
 exit 1;
else 
   find $logdir -maxdepth 1 -mtime +$keep_day  -type f \( -name "*.csv" -o -name "*.log"  \) -exec rm -rf {} \;
   echo "--"`date "+%Y-%m-%d %H:%M:%S"` "--deletedir-- LOG:delete logfile in the $logdir! execute on host: `hostname`"
fi
}

mgrhost=adb01
mgrport=6433
log_keep_day=$1
alias pgsql='psql "port=$mgrport host=$mgrhost dbname=postgres options='\''-c command_mode=sql'\''"'

nodesql="select node.nodetype||'|'||node.nodename||'|'||host.hostaddr||'|'||node.nodepath
from pg_catalog.mgr_node node, pg_catalog.mgr_host host
where 1=1
and node.nodehost=host.oid
order by node.nodename;"

nodes=`pgsql -q -t -c "$nodesql"`

for node in ${nodes[@]}
do 
   nodetype=`echo $node |cut -f 1 -d '|'`
   nodetype=`trans_nodetype $nodetype `
   nodename=`echo $node |cut -f 2 -d '|'`
   nodeaddr=`echo $node |cut -f 3 -d '|'`
   nodepath=`echo $node |cut -f 4 -d '|'`
   pglogdir="${nodepath}/pg_log"
   #echo "nodetype:$nodetype,nodename:$nodename,nodeaddr:$nodeaddr,nodepath:$nodepath,pglogdir:$pglogdir"
   #echo "$nodeaddr hostname is :"`ssh $nodeaddr "$(typeset -f); test"`
   ssh $nodeaddr "$(typeset -f); del_file $pglogdir $log_keep_day"
done 


# remote host execute local shell function
# https://stackoverflow.com/questions/22107610/shell-script-run-function-from-script-over-ssh