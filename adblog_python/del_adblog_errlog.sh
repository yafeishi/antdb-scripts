#!/bin/bash

source /home/adb/.bashrc

keep_day=$1

dbname="shhis"
port=5432
user="adbadmin"
psqlconn="psql -d $dbname -p $port -U $user"
base_tablename="adblog_errlog"
keep_day=`echo "0-$keep_day"|bc`
drop_tablename=${base_tablename}"_"`date -d "$keep_day day"  "+%Y%m%d"`
create_tablename=${base_tablename}"_"`date -d "1 day"  "+%Y%m%d"`

$psqlconn << EOF
DROP TABLE  IF EXISTS $drop_tablename;
create table $create_tablename () INHERITS ($base_tablename);
EOF

