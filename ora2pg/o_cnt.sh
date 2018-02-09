#/bin/bash
# sh o.sh so1 ins_des_user_ext_210 > o_cnt.log 2>&1 &


dbname="postgres"
owner=$1
tablename=$2


psqlconn="psql -d $dbname -U adb -q -t"
selectsql="select tablename 
from t_ora2adb_tableinfo
where dbname='$dbname' 
and owner='$owner' 
and tablename ilike '$tablename%'
--and o_cnt is null or o_cnt=0
"

usertns="username/passwd"
oracleparallel=3


tables=(`$psqlconn -c "$selectsql"`)
# oracle count
for t in ${tables[@]}
do 
# oracle count
o_cnt=`sqlplus -S /nolog <<EOF
set heading off feedback off pagesize 0 verify off echo off
conn $usertns
select /*+ parallel($oracleparallel)*/ count(*) from $owner.$t;
exit
EOF`

# oracle size 
o_size_m=`sqlplus -S /nolog <<EOF
set heading off feedback off pagesize 0 verify off echo off
conn $usertns
select round(sum(bytes)/1024/1024,2)  
from dba_segments
--from user_segments
where 1=1
and owner=upper('$owner')
and segment_name=upper('$t');
exit
EOF`

echo `date "+%Y-%m-%d %H:%M:%S"` "table_cnt on oracle: $owner:$t:$o_cnt:$o_size_m MB"
$psqlconn << EOF
update t_ora2adb_tableinfo set o_cnt=$o_cnt,o_size_m=$o_size_m,o_cnt_time=now() 
where 1=1
and owner='$owner' 
and tablename like '$t'
;
EOF
done