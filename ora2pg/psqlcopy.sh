#!/bin/bash

source /home/adb/.bashrc

function check_dir
{
 if [ ! -d "$2" ]; then
     echo "the $1 direcory $2 does not exist!"
     exit 0
 fi
}


function usage
{
  echo "Usage: "
  echo "    `basename $0` -u username -d datadir -t tablename -l logdir"
  echo "    `basename $0` -u username -d datadir -s|S filecnt -l logdir"
  exit 0
}


function psql_copy_file
{
$psqlconn -f ${datadir}/$file"_importing" > ${logdir}/"psqlcopy_"$file.log 2>&1 
errcnt=`grep -E "ERROR|FATAL" ${logdir}/"psqlcopy_"$file.log | wc -l`
if [ "$errcnt" -gt 0 ];then
 echo `date "+%Y-%m-%d %H:%M:%S" `": file ${datadir}/$file"_importing" copy failed,please check log ${logdir}/"psqlcopy_"$file.log!" >> ${logdir}/"psqlcopy_error".log
elif [ "$errcnt" -eq 0 ]; then
 mv ${datadir}/$file"_importing" ${datadir}/import_done/$file"_done"
fi
}



function exe_psql_copy
{
 if [ $filecnt -gt 0 ]; then
   if [ $file_sort -eq 0 ]; then 
      lsopt="ls -rS"
   elif [ $file_sort -eq 1 ]; then
      lsopt="ls -S"
   fi
 fi

 if [ "x$tablelike" != "x" ]; then
  files=`$lsopt $datadir  |grep -E '*sql$' |grep -v tmp | grep -v done |grep -v import |grep $tablelike |head -$filecnt`
 else       
  files=`$lsopt $datadir  |grep -E '*sql$' |grep -v tmp | grep -v done |grep -v import |head -$filecnt`
 fi

# rename file to filename_importing
for file in ${files[@]}
do 
  mv ${datadir}/$file ${datadir}/$file"_importing"
done 

# execute copy, after move file to done dir
for file in ${files[@]}
do 
  echo `date "+%Y-%m-%d %H:%M:%S"` " execute file: $file ,file size :`du -sh ${datadir}/$file"_importing" |awk '{print $1}'`"
  #echo `date "+%Y-%m-%d %H:%M:%S"` " execute file: $file ,file size :`du -sh ${datadir}/$file |awk '{print $1}'`"

  # sh /data/ora2pg/scripts/psqlcopyfile.sh  $dbname $tableowner $file_dir $file >> ${logdir}/"psqlcopy".log 2>&1 &
  psql_copy_file &
done
}


function check_adb_conn
{
result==`$psqlconn -q -t -c "select 1"`
if [ "x$result" = "x" ];then
    echo "connect to adb is invalid,please check!"
    exit 1
fi
}


function dir_stat
{
exporting_cnt=`ls -rt $datadir  |grep  'exporting' |grep -v done |wc -l`
importing_cnt=`ls -rt $datadir  |grep  'importing' |grep -v done |wc -l`
noimport_cnt=`ls -rt $datadir  |grep -E '*sql$' |grep -v tmp | grep -v done |grep -v import |wc -l`
done_cnt=`ls -rt $datadir/import_done |grep "done" |wc -l`
echo `date "+%Y-%m-%d %H:%M:%S"` "data directory $datadir stat: exporting:$exporting_cnt,noimport:$noimport_cnt,importing:$importing_cnt,import_done:$done_cnt"
}

while getopts 'u:d:t:s:S:l:' OPT; do
    case $OPT in
        u)
            username="$OPTARG";;
        d)
            datadir="$OPTARG";;
        t)
            tablelike="$OPTARG";;
        s)
            file_sort=0
            filecnt="$OPTARG";;
        S)
            file_sort=1
            filecnt="$OPTARG";;            
        l)
            logdir="$OPTARG";;            
        ?)
            usage
    esac
done

check_dir "data" $datadir
check_dir "log" $logdir


# should use -t or -s|S option.
#if [ "x$tablelike" != "x" -a "x$filecnt" != "x" ]; then
#   echo "you should use -t or -s|S option."
#   usage
#fi   

if [ "x$filecnt" = "x" ];then
   filecnt=5
   file_sort=0
fi


dbname='postgres'
hostname='1.2.3.4'
port="5432"
psqlconn="psql -h $hostname -p $port -d $dbname -U $username "

echo "username:$username,datadir:$datadir,tablelike:$tablelike,file_sort:$file_sort,filecnt:$filecnt,logdir:$logdir"
check_adb_conn
exe_psql_copy
dir_stat