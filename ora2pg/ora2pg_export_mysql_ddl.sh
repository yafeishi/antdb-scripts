#/bin/bash
# ora2pg_mysql_ddl.sh

username=$1
ora2pg_home='/data/emea/migrate/ora2pg'
confdir=${ora2pg_home}"/conf"
ddldir=${ora2pg_home}"/ddl"
logdir=${ora2pg_home}"/log"


ora2pgcfgfile=${confdir}"/ora2pg_"$username"_ddl.conf"
ddlfile=${ddldir}"/"$username"_ddl.sql"
logfile=${logdir}"/log_"$username"_ddl.log"

cat > $ora2pgcfgfile << EOF
ORACLE_HOME /usr/lib64/mysql/
ORACLE_DSN  dbi:mysql:host=ip;port=3306;database=${username};
ORACLE_USER root  
ORACLE_PWD  password
TYPE TABLE,VIEW,SEQUENCE,GRANT,PARTITION,PROCEDURE,FUNCTION
SKIP fkeys
nls_lang utf8
DISABLE_COMMENT 1
PKEY_IN_CREATE 1
INDEXES_RENAMING 1
ENABLE_MICROSECOND 0
STOP_ON_ERROR  0
PG_NUMERIC_TYPE    0  
PG_INTEGER_TYPE    1  
DEFAULT_NUMERIC float  
EOF

psqlconn="psql -p 55432 -d emea -U $username -q -t"
superconn="psql -p 55432 -d emea"

function export_import
{
    ora2pg -m mysql -c $ora2pgcfgfile -n $username  -o $ddlfile -d
    $superconn -c "create user $username"
    $superconn -c "drop schema $username cascade"
    $superconn -c "create schema AUTHORIZATION $username"
    $psqlconn -f $ddlfile
}

export_import > $logfile 2>&1 &