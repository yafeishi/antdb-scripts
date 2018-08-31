#/bin/bash
# ora2pg_mysql_data.sh
# 

source /data/emea/.bashrc

username=$1
tablelike=$2
tablecnt=$3
ora2pg_home='/data/emea/migrate/ora2pg'
confdir=${ora2pg_home}"/conf"
datadir=${ora2pg_home}"/data"
logdir=${ora2pg_home}"/log"
mkdir -p ${datadir}/${username}

#ora2pgcfgfile=${confdir}"/ora2pg_"$username"_data.conf"
ddlfile=${ddldir}"/"$username"_ddl.sql"
logfile=${logdir}"/log_"$username"_ddl.log"

function get_config
{
cat > $ora2pgcfgfile << EOF
ORACLE_HOME /usr/lib64/mysql/
ORACLE_DSN  dbi:mysql:host=ip;port=3306;database=${username};
ORACLE_USER root  
ORACLE_PWD  password
TYPE COPY
SKIP  fkeys
OUTPUT_DIR  ${datadir}/${username}
nls_lang utf8
ILE_PER_TABLE 1
SPLIT_FILE 1
DISABLE_SEQUENCE 1
STOP_ON_ERROR 0
ORACLE_COPIES 10
DATA_LIMIT  100000
SPLIT_LIMIT  10000000
PG_DSN dbi:Pg:dbname=emea;host=localhost;port=55432
PG_USER ${username}
PG_PWD ${username}
EOF
}

psqlconn="psql -p 55432 -d emea -U $username -q -t"
superconn="psql -p 55432 -d emea -q -t"

function init_tablecnt
{
if [ "x$tablecnt" == "x" ]; then
  echo "tablecnt apply init value:20"
  tablecnt=20
fi
running_sql="select count(*) from emea_tableinfo where is_export=1 and export_time is not null"
running_cnt=`$superconn -c "$running_sql"`
if [ $running_cnt -ge $tablecnt ];then
    tablecnt=0
else
   tablecnt=`echo $tablecnt - $running_cnt|bc`    
fi  
echo `date "+%Y-%m-%d %H:%M:%S"` "---- tablecnt is: $tablecnt"    
}


function ora2pg_background
{
 updatesql="update emea_tableinfo set is_export=1,export_time=now() where table_schema='$username' and table_name='$t'"
 $superconn -c "$updatesql"
 echo `date "+%Y-%m-%d %H:%M:%S"` "ora2pg export table data:  $username:$t" 
 ora2pg -c $ora2pgcfgfile -n $username -a"$t" -d > ${logdir}/"ora2pg_data_"$username"_"$t.log 2>&1
 updatesql="update emea_tableinfo set is_export=2,export_time=now() where table_schema='$username' and table_name='$t'"
 $superconn -c "$updatesql"
}

function ora2pg_execute
{
selectsql="select table_schema||'|'||table_name 
from emea_tableinfo 
where 1=1
and table_schema ilike '%$username%' 
and table_name like '%$tablelike%'
and m_cnt>0
and (is_export=0 or is_export is null)
order by table_schema,table_name
limit $tablecnt;"

tables=(`$superconn -c "$selectsql"`)
for table in ${tables[@]}
do
  username=`echo $table |cut -f 1 -d '|'`
  t=`echo $table |cut -f 2 -d '|'`
  ora2pgcfgfile=${confdir}"/ora2pg_"$username"_data.conf"
  get_config
  ora2pg_background 2>&1 &
done
}

init_tablecnt
ora2pg_execute