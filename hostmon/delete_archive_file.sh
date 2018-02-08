#!/bin/bash
# sh delete_archive_file.sh 0
# 0 3 * * * sh /data/hostmon/shell/delete_archive_file.sh 7 >> /data/hostmon/log/log_delete_archive_file.log


function del_file
{
logdir=$1
keep_day=$2
echo "logdir is $logdir"
if [ "x$logdir" = "x" -o "x$keep_day" = "x" ]; then
 echo "--"`date "+%Y-%m-%d %H:%M:%S"` "--deletedir-- ERROR:please input the log dir and keep_days !"
 exit 1;
else 
   find $logdir -maxdepth 1 -mtime +$keep_day  -type f  -exec rm -rf {} \;
   echo "--"`date "+%Y-%m-%d %H:%M:%S"` "--deletedir-- LOG:delete archive file in the $logdir! execute on host: `hostname`"
fi
}


archive_dir=/data/adb/archive
file_keep_day=$1

for dir in `find $archive_dir -type d -name 'db*'`
do
        del_file $dir $file_keep_day
done