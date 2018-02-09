#!/bin/bash
# sh generate_create_index.sh so1 ins_des_user_ext_21 /data/ora2pg/ddl/index/so1

dbname="postgres"

tableowner=$1
tablelike=$2
filedir=$3
psqlconn="psql -d $dbname -U $tableowner -q -t"
selectsql="select tablename from pg_tables where 1=1 and tableowner='$tableowner' and tablename like '$tablelike%'"


#echo "$selectsql"

tables=(`$psqlconn -c "$selectsql"`)

for t in ${tables[@]}
do 
echo `date "+%Y-%m-%d %H:%M:%S"` "----generate  create index sql on  table $tableowner.$t"
$psqlconn << EOF > ${filedir}/'create_index_'$tableowner'_'$t'.sql' 2>&1 
\echo select now();
\echo '\\\timing on'
select a.indexdef||';'
from pg_indexes a,pg_index b
where 1=1
and a.indexname::regclass=b.indexrelid::regclass
and a.tablename::regclass=indrelid::regclass
and b.indisunique=false
and b.indisprimary=false
and a.schemaname not in ('pg_catalog','public')
and a.schemaname='$tableowner'
and a.tablename='$t'
;
\echo select now();
EOF
done