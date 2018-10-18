#!/bin/bash

source ${HOME}/.adb40.sh

function init_param
{
    adbhome="${HOME}/app/adb40"
    export PATH=$adbhome/bin:$PATH
    data1home="${HOME}/data/adb40/d1"
    data2home="${HOME}/data/adb40/d2"
    host1="localhost"
    mgr_home=${data1home}/mgr
    mgr_port=16432
    adbagent_port=27433
    adbuser="$USER"
    userpasswd="123"
    mgr_conn="psql -e  -v ON_ERROR_STOP=1 -d postgres -p $mgr_port"
    cd1port=11010
    cd2port=11011
    db1_1port=11020
    db1_2port=11021
    gtm1port=11018
    gtm2port=11019
    tmpport=11050
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
add host adb01 (address='$host1',agentport=$adbagent_port,adbhome='$adbhome',user='$adbuser');
alter host adb01 (agentport=$tmpport,adbhome='${adbhome}/tmp');
drop host adb01;
add host adb01 (address='$host1',agentport=$adbagent_port,adbhome='$adbhome',user='$adbuser');
deploy all password '$userpasswd';
start agent all password '$userpasswd';
add coordinator master cd1(path='${data1home}/cd1',host='adb01',port=$cd1port);
add datanode master db1_1(path='${data1home}/db1',host='adb01',port=$db1_1port);
add gtm master gtm1(path='${data1home}/gtm1',host='adb01',port=$gtm1port);
clean all;
init all;
EOF
}

function test_case_adddelnode
{
    $mgr_conn << EOF
stop agent all;
start agent all password '$userpasswd';
monitor agent all;
add gtm slave  gtm2 for gtm1(path='${data2home}/gtm2',host='adb01',port=$gtm2port);
clean gtm slave gtm2;
append gtm slave gtm2;
add datanode slave db1_2 for db1_1 (path='${data2home}/db1',host='adb01',port=$db1_2port);
clean datanode slave db1_2;
append datanode slave db1_2;
list node;
monitor all;
monitor ha;
switchover datanode slave db1_2;
switchover gtm slave gtm2;
switchover datanode slave db1_1 force;
switchover gtm slave gtm1 force;
set datanode all (wal_log_hints = on);
set gtm all (wal_log_hints = on);
stop all mode fast;
start all;
failover datanode db1_1;
failover gtm gtm1;
add gtm slave  gtm1 for gtm2(path='${data1home}/gtm1',host='adb01',port=$gtm1port);
rewind gtm slave gtm1;
add datanode slave db1_1 for db1_2 (path='${data1home}/db1',host='adb01',port=$db1_1port);
rewind datanode slave db1_1;
monitor ha;
switchover datanode slave db1_1 force;
switchover gtm slave gtm1 force;
list node;
failover datanode db1_1;
failover gtm gtm1;
add gtm slave  gtm1 for gtm2(path='${data1home}/gtm1',host='adb01',port=$gtm1port);
clean gtm slave gtm1;
append gtm slave gtm1;
add datanode slave db1_1 for db1_2 (path='${data1home}/db1',host='adb01',port=$db1_1port);
clean datanode slave db1_1;
append datanode slave db1_1;
switchover datanode slave db1_1 force;
switchover gtm slave gtm1 force;
add coordinator master cd2 (path='${data1home}/cd2',host='adb01',port=$cd2port);
clean coordinator master cd2;
append coordinator  master cd2;
list node;
stop coordinator master cd2;
remove coordinator master cd2;
clean coordinator master cd2;
append coordinator cd2 for cd1;
append activate coordinator cd2;
list node;
stop coordinator master cd2;
remove coordinator master cd2;
drop coordinator master cd2;
list node host adb01;
EOF
}

function test_case_changenodeport
{
    $mgr_conn << EOF
alter coordinator master cd1 (port=$tmpport);
alter coordinator master cd1 (port=$cd1port);
alter datanode master db1_1 (port=$tmpport);
alter datanode master db1_1 (port=$db1_1port);
alter gtm master gtm1 (port=$tmpport);
alter gtm master gtm1 (port=$gtm1port);
flush host;
alter gtm slave gtm2 (sync_state='async');
alter datanode slave db1_2 (sync_state='async');
alter gtm slave gtm2 (sync_state='sync');
alter datanode slave db1_2 (sync_state='sync');
list node;
EOF
}

function test_case_job
{
    $mgr_conn << EOF
add job usage_for_host (interval= 60,command = 'select monitor_get_hostinfo();');
add job usage_for_adb (interval= 60,command = 'select monitor_databaseitem_insert_data();');
add job tps_for_adb (interval= 60,command = 'select monitor_databasetps_insert_data();');
add job slowlog_for_adb (interval= 60,command = 'select monitor_slowlog_insert_data();');
alter job all (status=false);
list job;
alter job all (status=true);
list job;
EOF
}

function test_case_param
{
    $mgr_conn << EOF
show cd1 deadlock_timeout;
show db1_1 deadlock_timeout;
show gtm1 deadlock_timeout;
set coordinator master cd1 (deadlock_timeout='2000ms');
set coordinator  all (deadlock_timeout='2000ms');
set datanode master db1_1 (deadlock_timeout='2000ms');
set datanode  all (deadlock_timeout='2000ms');
set gtm master gtm1 (deadlock_timeout='2000ms');
set gtm  all (deadlock_timeout='2000ms');
show cd1 deadlock_timeout;
show db1_1 deadlock_timeout;
show gtm1 deadlock_timeout;
reset coordinator  all (deadlock_timeout);
reset datanode  all (deadlock_timeout);
reset gtm  all (deadlock_timeout);
show cd1 deadlock_timeout;
show db1_1 deadlock_timeout;
show gtm1 deadlock_timeout;
EOF
}


read -p  "are you sure init cluster,it will delete current cluster(yes/no):" choice
if [ "$choice" != "yes" ];then
    echo "your choice is: $choice,so process exit!"
    exit 1
fi       

echo "counitue"
init_param && \
mgr_stop_all && init_mgr && adbmgr_start && init_node && test_case_adddelnode \
test_case_changenodeport &&  test_case_job && test_case_param
