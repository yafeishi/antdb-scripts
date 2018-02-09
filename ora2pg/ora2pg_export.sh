#!/bin/bash 
# ora2pg export 
# ora2pg config: shhis_data.conf
# sh ora2pg_export.sh owner tablenamelike tablecnt

# sh ora2pg_export.sh configfile username tablename  logdir tablecnt
 
function check_ora_conn
{
conn_tag=`sqlplus -S /nolog <<EOF
set heading off feedback off pagesize 0 verify off echo off
conn $oraconn
select * from dual;
exit
EOF`
if [ "x$conn_tag" = "x" ]; then
  echo "the oracle connection is invalid!"
        exit
else
        echo "the oracle connection is ok!"
fi
}


function check_ora2pg
{
  which ora2pg
  if [ $? -eq 0 ]; then
        return 0
  else
        echo "ora2pg execute program not find!"
        exit        
  fi
}


function check_ora2pgcfg
{
  if [ -f "$configfile" ]; then
        return 0
  else
        echo "ora2pg config file does not exist!"
        exit        
  fi
}

function init_tablecnt
{
if [ "x$tablecnt" = "x" ]; then
  echo "tablecnt apply init value:5"
  tablecnt=5
fi
}


function ora2pg_background
{
selectsql="select upper(tablename) 
from t_ora2adb_tableinfo 
where dbname='$dbname' 
and owner='$tableowner' 
and tablename ilike '%$tablelike%'
and is_export=0
limit $tablecnt;"

tables=(`$psqlconn -c "$selectsql"`)
for t in ${tables[@]}
do
 updatesql="update t_ora2adb_tableinfo set is_export=1,export_time=now() where owner='$tableowner' and upper(tablename)='$t'"
 $psqlconn -c "$updatesql"
 ora2pg -c $configfile -n $tableowner -a"$t" -d > ${logdir}/"ora2pg_"$tableowner_$t.log 2>&1 &
 echo "ora2pg to export table: $tableowner.$t"
done
}


# init parameter

configfile=$1
username=$2
tablelike=$3
logdir=$4
tablecnt=$5

tableowner="$username"
dbname="postgres"

# Make sure this option is correct,If the oracle database is not connected, the program will exit 
oraconn="user/passwd"


psqlconn="psql -d $dbname -U $tableowner -q -t"

check_ora2pg
check_ora2pgcfg
init_tablecnt
ora2pg_background