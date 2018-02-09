#!/bin/bash
# sh a.sh so1 ins_des_user_ext_210 > o_cnt.log 2>&1 &

source /home/adb/.bashrc
# init parameter
dbnname="postgres"
owner=$1
tablename=$2

# oracle connect info

# adb connect info
cntpsqlconn="psql -d $dbnname -U adb -q -t"
selectsql="select tablename 
from t_ora2adb_tableinfo
where dbname='$dbnname' 
and owner='$owner' 
and tablename ilike '$tablename%'
"



tables=(`$cntpsqlconn -c "$selectsql"`)
for t in ${tables[@]}
do 
echo echo `date "+%Y-%m-%d %H:%M:%S"` "vacuum analyze $owner.$t; "
$cntpsqlconn << EOF 
\timing on
vacuum analyze $owner.$t;
EOF
done