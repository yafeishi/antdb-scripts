#!/bin/bash
# sh a.sh so1 ins_des_user_ext_210 > o_cnt.log 2>&1 &

source /home/adb/.bashrc
# init parameter
dbnname="postgres"
owner=$1
tablename=$2

# oracle connect info

# adb connect info
updatepsqlconn="psql -d $dbnname -U adb -q -t"
cntpsqlconn="psql -d $dbnname -U $owner -q -t"
selectsql="select tablename 
from t_ora2adb_tableinfo
where dbname='$dbnname' 
and owner='$owner' 
and tablename ilike '$tablename%'
--and o_cnt>0
and (a_cnt is null or a_cnt=0 or o_minus_a <> 0)
"



tables=(`$updatepsqlconn -c "$selectsql"`)
# oracle count
for t in ${tables[@]}
do 
a_cnt=`$cntpsqlconn << EOF 
select count(*) from $owner.$t;
EOF`
a_size_m=`$cntpsqlconn << EOF 
select pg_relation_size('$owner.$t')/1024/1024;
EOF`
echo `date "+%Y-%m-%d %H:%M:%S"` "table_cnt on adb: $owner:$t:$a_cnt:$a_size_m MB"
$updatepsqlconn << EOF
update t_ora2adb_tableinfo set a_cnt=$a_cnt,a_size_m=$a_size_m,a_cnt_time=now() 
where 1=1
and owner='$owner' 
and tablename like '$t'
;
EOF
done 
$updatepsqlconn -c "update t_ora2adb_tableinfo_cnt set o_minus_a=o_cnt-a_cnt;"