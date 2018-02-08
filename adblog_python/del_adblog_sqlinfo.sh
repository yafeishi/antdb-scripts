#!/bin/bash

source /home/sh2.2/.bashrc

keep_day=$1

dbname="postgres"
port=17322
user="sh2.2"
psqlconn="psql -d $dbname -p $port -U $user"
base_tablename="adblog_sqlinfo"
keep_day=`echo "0-$keep_day"|bc`
drop_tablename=${base_tablename}"_"`date -d "$keep_day day"  "+%Y%m%d"`
create_tablename=${base_tablename}"_"`date -d "1 day"  "+%Y%m%d"`

$psqlconn << EOF
DROP TABLE  IF EXISTS $drop_tablename;
create table $create_tablename () INHERITS ($base_tablename);
EOF

