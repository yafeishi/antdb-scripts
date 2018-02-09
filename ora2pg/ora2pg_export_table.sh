#!/bin/bash


function check_ora2pgcfg
{
  if [ -f "$configfile" ]; then
        return 0
  else
        echo "ora2pg config file does not exist!"
        exit
  fi
}


function usage
{
echo "sh ora2pg_export_table.sh configfile username tablename  logdir "
exit
}


function check_tablename
{
  if [ "x$tablelike" = "x" ]; then
    echo "must input table name"
    usage
  fi
}



function ora2pg_background
{
 ora2pg -c $configfile -n $tableowner -a"$tablelike" -d > ${logdir}/"ora2pg_"$tableowner_$tablelike.log 2>&1 &
 echo "ora2pg to export table: $tableowner.$tablelike logfile is : ${logdir}/"ora2pg_"$tableowner_$tablelike.log"
}

configfile=$1
username=$2
tablelike=$3
logdir=$4

tableowner="$username"
dbname="postgres"

psqlconn="psql -d $dbname -U $tableowner -q -t"

check_ora2pgcfg
check_tablename
ora2pg_background