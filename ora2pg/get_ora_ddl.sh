#!/bin/bash 
# https://docs.oracle.com/cd/B28359_01/appdev.111/b28419/d_metada.htm#BGBJBFGE
# https://stackoverflow.com/questions/22018804/oracle-sql-developer-4-0-how-to-remove-double-quotes-in-scripts
# https://asktom.oracle.com/pls/asktom/f?p=100:11:0::::P11_QUESTION_ID:9534496000346133031
# https://blog.csdn.net/itmyhome1990/article/details/50380718

log_print()
{
    echo "--"`date "+%Y-%m-%d %H:%M:%S"` -- $1
}


get_object_ddl ()
{
sqlplus -silent /nolog <<EOF > /dev/null 2>${logfile}
conn ${ora_conn}
set echo off;
set heading off;
set feedback off;
set verify off;
set trimspool on;
set long 90000000;
col ddl_sql for a999;
set pagesize 0;
set linesize 20000;
set serveroutput off;
set longchunksize 20000;
exec DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'STORAGE',false); 
exec DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'TABLESPACE',false); 
exec DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'SEGMENT_ATTRIBUTES',false); 
exec dbms_metadata.set_transform_param(dbms_metadata.session_transform, 'PRETTY', true);
exec dbms_metadata.set_transform_param(dbms_metadata.session_transform, 'SQLTERMINATOR', true);
exec dbms_metadata.set_transform_param(dbms_metadata.session_transform, 'FORCE', false);
exec DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'EMIT_SCHEMA',false);
spool $outfile
select 
case when object_type in ('FUNCTION','PROCEDURE') then REGEXP_REPLACE(dbms_metadata.get_ddl(object_type,object_name) ,'${object_type}[[:space:]]? "(\w+?)"','${object_type} \1')
else
   replace(dbms_metadata.get_ddl(object_type,object_name),'"')
end
from  user_objects
where object_type=upper('$object_type');
spool off
EOF
}

check_type ()
{
object_type_lower=`echo $object_type |tr '[A-Z]' '[a-z]'`
object_type=`echo $object_type |tr '[a-z]' '[A-Z]'`
outfile=orcl_${username}_${object_type_lower}.sql
t_cnt=`sqlplus -S /nolog <<EOF
set heading off feedback off pagesize 0 verify off echo off
conn ${ora_conn}
select  count(*) 
from user_objects
where object_type=upper('$object_type');
exit
EOF`
if [ $t_cnt -eq 0 ]; then
    log_print "the count of $object_type in $username  is: $t_cnt,export process will continue to next type!"  
elif  [ $t_cnt -gt 0 ];then
    log_print "the count of $object_type in $username  is: $t_cnt,export file is ${outfile}!"  
    get_object_ddl
fi
}


get_all_objects ()
{
for object_type in ${object_types[@]}
do 
  check_type
done
}


check_ora_conn()
{
sqlplus -silent /nolog <<EOF  |grep antdb
conn ${ora_conn}
select 'antdb' from dual;
EOF
if [ $? -eq 0 ];then
   log_print 'source oracle connect is ok !'
else
   log_print 'source oracle connect not ok ,please check!'
   exit 1
fi
}

orahost=$1
#orasid='orcl'
orasid='adb'
oraport=1521
username=$2
password=$3
object_type=$4
object_types=(PROCEDURE function view)

ora_conn=${username}/${password}@${orahost}:${oraport}/${orasid}

logfile=ora_object_data_${username}.log

check_ora_conn

if [ "x$object_type" == "x" ];then
   log_print "because you can not input object type,so export ${object_types[@]}   default "
   get_all_objects
else
   check_type
fi