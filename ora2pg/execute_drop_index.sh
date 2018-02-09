#!/bin/bash
#sh execute_drop_index.sh so1 ins_des_user_ext_21 /data/ora2pg/ddl/index/so

dbname="postrgres"
tableowner=$1
tablelike=$2
filedir=$3
psqlconn="psql -d $dbname -U $tableowner -q -t "
selectsql="select tablename from pg_tables where 1=1 and tableowner='$tableowner' and tablename like '$tablelike%'"

tables=(`$psqlconn -c "$selectsql"`)

for t in ${tables[@]}
do 
echo `date "+%Y-%m-%d %H:%M:%S"` "----on port $port --- drop index on  table $tableowner.$t"
$psqlconn -f ${filedir}/'drop_index_'$tableowner'_'$t'.sql' >> drop_index_$tableowner.log 2>&1 
done