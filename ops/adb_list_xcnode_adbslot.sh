#!/bin/bash


mgrhost=$1
mgrport=$2

alias pgsql='psql "port=$mgrport host=$mgrhost dbname=postgres options='\''-c command_mode=sql'\''"'

masternodesql="select host.hostaddr||'|'||host.hostname||'|'||node.nodetype||'|'||node.nodename||'|'||node.nodeport
from pg_catalog.mgr_node node, pg_catalog.mgr_host host
where 1=1
and node.nodehost=host.oid
and node.nodetype  in ('c','d')
order by node.nodename;"

masternodes=`pgsql -q -t -c "$masternodesql"`

for m_node in ${masternodes[@]}
do 
   hostaddr=`echo $m_node |cut -f 1 -d '|'`
   hostname=`echo $m_node |cut -f 2 -d '|'`
   nodetype=`echo $m_node |cut -f 3 -d '|'`
   nodename=`echo $m_node |cut -f 4 -d '|'`
   nodeport=`echo $m_node |cut -f 5 -d '|'`
   echo `date`"----  get pgxc_node  of node $nodename,host is $hostaddr, port is $nodeport "
   conn="psql -h $hostaddr -p $nodeport -d postgres -U $USER -q -t"
   ${conn} -c "select * from pgxc_node order by 1 " 
   echo `date`"----  get slotnodename  of node $nodename,host is $hostaddr, port is $nodeport "
   ${conn} -c "select distinct slotnodename from adb_slot order by 1 " 
   sleep 2
done