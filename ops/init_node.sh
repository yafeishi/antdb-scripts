#!/bin/bash

source ${HOME}/.adb40.sh

function init_param
{
    adbhome="${HOME}/app/adb40"
    export PATH=$adbhome/bin:$PATH
    data1home="${HOME}/data/adb40/d1"
    data2home="${HOME}/data/adb40/d2"
    mgr_home=${data1home}/mgr
    mgr_port=16432
    adbagent_port=27433
    adbuser="$USER"
    userpasswd="123"
    mgr_conn="psql -v ON_ERROR_STOP=1 -d postgres -p $mgr_port"
}


function init_mgr
{
    rm -rf $mgr_home
    initmgr -D $mgr_home
    cat << EOF >> $mgr_home/postgresql.conf
port = ${mgr_port}
listen_addresses = '*'
log_directory = 'pg_log'
log_destination ='csvlog'
logging_collector = on
log_min_messages = error
max_wal_senders = 3
hot_standby = on
wal_level = hot_standby
EOF

cat << EOF >> $mgr_home/pg_hba.conf
host    all             all             0.0.0.0/0            trust
EOF
}


function adbmgr_start
{  
    echo "---------------------------------------------mgr start"
    mgr_ctl start -D $mgr_home
    sleep 5
}

function mgr_stop_all
{
    $mgr_conn << EOF
    stop all mode f;
    stop agent all ;
EOF
    mgr_ctl stop -D $mgr_home
    sleep 5
}

function init_node
{
    $mgr_conn << EOF
add host adb01 (address='localhost',agentport=$adbagent_port,adbhome='$adbhome',user='$adbuser');
deploy all password '$userpasswd';
start agent all password '$userpasswd';
add coordinator master cd1(path='${data1home}/cd1',host='adb01',port=11010);
add coordinator master cd2(path='${data1home}/cd2',host='adb01',port=11011);
add coordinator master cd3(path='${data1home}/cd3',host='adb01',port=11012);
add datanode master db1_1(path='${data1home}/db1',host='adb01',port=11020);
add datanode master db2_1(path='${data1home}/db2',host='adb01',port=11030);
add datanode master db3_1(path='${data1home}/db3',host='adb01',port=11040);
add gtm master gtm_1(path='${data1home}/gtm1',host='adb01',port=11018);
add gtm slave  gtm_2 for gtm_1(path='${data2home}/gtm2',host='adb01',port=11019);
add datanode slave db1_2 for db1_1 (path='${data2home}/db1',host='adb01',port=11021);
add datanode slave db2_2 for db2_1 (path='${data2home}/db2',host='adb01',port=11031);
add datanode slave db3_2 for db3_1 (path='${data2home}/db3',host='adb01',port=11041);
clean all;
init all;
monitor all;
add job usage_for_host (interval= 60,command = 'select monitor_get_hostinfo();');
add job usage_for_adb (interval= 60,command = 'select monitor_databaseitem_insert_data();');
add job tps_for_adb (interval= 60,command = 'select monitor_databasetps_insert_data();');
add job slowlog_for_adb (interval= 60,command = 'select monitor_slowlog_insert_data();');
list job;
EOF
}


function init_pgbench
{
    createdb db1
    pgbench -i -F 100 -s 50 db1
}

function install_extension
{
    psql -d postgres -c "create extension pg_stat_statements;"
    psql -d db1 -c "create extension pg_stat_statements;"
$mgr_conn << EOF
set coordinator all (shared_preload_libraries='pg_stat_statements');
stop all mode f;
start all;
\! sleep 3
show cd1 shared_preload_libraries;
EOF
}

read -p  "are you sure init cluster,it will delete current cluster(yes/no):" choice
if [ "$choice" != "yes" ];then
    echo "your choice is: $choice,so process exit!"
    exit 1
fi       

echo "counitue"
init_param && mgr_stop_all && \
init_mgr && adbmgr_start && init_node && \
init_pgbench && install_extension