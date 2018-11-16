# cat
cat /proc/145561/environ | xargs -0 -n 1


# rpm -prefix

rpm -qpi redhat-lsb-1.3-3.1.EL3.i386.rpm
rpm -ivh --prefix=/opt rsync-2.5.7-5.3E.i386.rpm
----  error: package mysql-community-client is not relocatable
rpm -ql rsync   --查看安装路径

rpm -qa | grep namexx

rpm -e 需要卸载的安装包
rpm -ivh --force --nodeps  telnet-server-0.17-38.el5.i386.rpm 

rpm -ivh --force --nodeps *.rpm


# yum
yum install -y flex
yum repolist
yum list
yum info
yum deplist package1 #查看程序package1依赖情况
yum list installed #列出所有已安装的软件包 
yum list extras  #列出所有已安装但不在 Yum Repository 内的软件包 
yum info extras #列出所有已安装但不在 Yum Repository 内的软件包信息 


# chkconfig
chkconfig --list

#ln
ln -s sqluldr2linux64.bin sqluldr2


# user group
groupadd postgres
useradd –g postgres –d /postgres –s /bin/bash –m postgres

Usage: useradd [options] LOGIN

groupdel postgres
userdel [-f] postgres 

# disk
mount /dev/sdb1 /postgres
umount /dev/sdb1


sg3_utils
sginfo -g /dev/cciss/c0d0



# shell命令运行符号& ; &&区别
command1&command2&command3     三个命令同时执行 
command1;command2;command3     不管前面命令执行成功没有，后面的命令继续执行 
command1&&command2             只有前面命令执行成功，后面命令才继续执行
command1 || command2           ||则与&&相反。如果||左边的命令（命令1）未执行成功，那么就执行||右边的命令（命令2）

# vi
0  行首
$ 行尾
G 文档尾部
gg 文档首部
I 在光标的行首
A 在光标的行尾
d0 删除至行首
yy 复制整行
p 粘贴至游标后
P 粘贴至光标前
nu 显示行号

set fileencoding


# 目录下的最新文件名
ls -lrt | grep csv| tail -n 1 | awk '{print $9}'

ls -lrt | grep csv| head -1

ldd 查看程序依赖库


# date
date "+%Y-%m-%d %H:%M:%S" 
date "+%Y%m%d%H%M%S" 
# date minus
ftp_start=`date "+%s"`
ftp_end=`date "+%s"`
ftp_time=$(expr  $ftp_end - $ftp_start)


# ps
命令参数
a 显示所有进程
-a 显示同一终端下的所有程序
-A 显示所有进程
c 显示进程的真实名称
-N 反向选择
-e 等于“-A”
e 显示环境变量
f 显示程序间的关系
-H 显示树状结构
r 显示当前终端的进程
T 显示当前终端的所有程序
u 指定用户的所有进程
-au 显示较详细的资讯
-aux 显示所有包含其他使用者的行程
-C<命令> 列出指定命令的状况
–lines<行数> 每页显示的行数
–width<字符数> 每页显示的字符数
–help 显示帮助信息
–version 显示版本显示



1.CPU占用最多的前10个进程： 
ps auxw|sort -rn -k3|head -10 
2.内存消耗最多的前10个进程 
ps auxw|head -1;ps auxw|sort -rn -k4|head -10 
3.虚拟内存使用最多的前10个进程 
ps auxw|head -1;ps auxw|sort -rn -k5|head -10

ps -eo pid,lstart,etime,cmd | grep 16088 
ps auxw|head -1;ps auxw | grep pg_dump 
ps auxw|head -1;ps auxw|sort -rn -k10|head -10 

cat /proc/2736/status ; echo -e "\n"; cat /proc/11184/stack

ps -weo pid,stat,wchan:32,args | grep postgres


# sar
# 查看指定文件CPU使用记录
sar -f /var/log/sa/sa03
#查看指定文件1/5/15分钟平均负载记录
sar -q -f /var/log/sa/sa03
#查看指定文件7点到9点CPU使用记录，如要看负载加参数-q
sar -s 07:00:00 -e 10:00:00 -f /var/log/sa/sa03

sar -q: 查看平均负载
sar -r： 指定-r之后，可查看物理内存使用状况；
sar -W：查看页面交换发生状况

sar参数说明
-A 汇总所有的报告
-a 报告文件读写使用情况
-B 报告附加的缓存的使用情况
-b 报告缓存的使用情况
-c 报告系统调用的使用情况
-d 报告磁盘的使用情况
-g 报告串口的使用情况
-h 报告关于buffer使用的统计数据
-m 报告IPC消息队列和信号量的使用情况
-n 报告命名cache的使用情况
-p 报告调页活动的使用情况
-q 报告运行队列和交换队列的平均长度
-R 报告进程的活动情况
-r 报告没有使用的内存页面和硬盘块
-u 报告CPU的利用率
-v 报告进程、i节点、文件和锁表状态
-w 报告系统交换活动状况
-y 报告TTY设备活动状况


# 查看硬件信息
lscpu
hdparm  -i /dev/sda1  
hdparm -tT /dev/sdb1
dd if=/dev/zero of=toto bs=8k count=244140
grep -E '^model name|^cpu MHz' /proc/cpuinfo

## centos 7 防火墙
systemctl stop firewalld.service
systemctl disable firewalld.service

# fio test disk  iops
fio -filename=/dev/vdd -direct=1 -iodepth 32 -thread -rw=randrw -rwmixread=70 -ioengine=libaio -bs=8k -size=200G -numjobs=30 -runtime=100 -group_reporting -name=mytest -ioscheduler=noop


# df
df -h |grep adbdata | awk -F ' ' '{print $5}'
df -h |grep adbdata | awk -F ' ' '{print $5}'|cut -d % -f 1

# du
du -k $@ | sort -n | awk '
BEGIN {
  split("K,M,G,T", Units, ",");
  FS="\t";
  OFS="\t";
}
{
  u = 1;
  while ($1 >= 1024) {
    $1 = $1 / 1024;
    u += 1
  }
  $1 = sprintf("%.1f%s", $1, Units[u]);
  sub(/\.0/, "", $1);
  print $0;
}'

du -sh * | sort -h
du -sh * | sort -h
du -sh * | sort -rh |head -3

du -sh /adbdata/pgxc_data/db1/pg_xlog |awk '{print $1}'



# 比较
-eq 等于,如:if [ "$a" -eq "$b" ]   
-ne 不等于,如:if [ "$a" -ne "$b" ]   
-gt 大于,如:if [ "$a" -gt "$b" ]   
-ge 大于等于,如:if [ "$a" -ge "$b" ]   
-lt 小于,如:if [ "$a" -lt "$b" ]   
-le 小于等于,如:if [ "$a" -le "$b" ]   
<   小于(需要双括号),如:(("$a" < "$b"))   
<=  小于等于(需要双括号),如:(("$a" <= "$b"))   
>   大于(需要双括号),如:(("$a" > "$b"))   
>=  大于等于(需要双括号),如:(("$a" >= "$b"))  



# scp
scp -r pgsql_xc danghb@192.168.1.1:/home/danghb/adb21
scp datanodeExtraConfig danghb@192.168.1.1:/home/danghb/pgxc_ctl


# awk
awk 'NR%2==0' test2 | sed 's/[ ][ ]*/ /g' 可以重定向 
awk 'NR%5==0'  1209-cmbase-oracle.log.bak | sed 's/[[:space:]][[:space:]]*//g' > 1209cmoracnt && more 1209cmoracnt
awk -F, '{if($13="ERROR") print $0}'  postgresql-2016-12-10_073229.csv | more

# 将每一行前导的“空白字符”（空格，制表符）删除
# 使之左对齐
sed 's/^[ \t]*//'

du -h * | sort -h| tail -10 |sed -e 's/^/WARN：/' 


grep ERROR /data/pgxc_data/coord1/pg_log/postgresql-2016-12-10*.csv  > ~/error_dir/coord1_121011_error 
grep ERROR /data/pgxc_data/db1/pg_log/postgresql-2016-12-10*.csv  > ~/error_dir/db1_121011_error 

grep ERROR /data/pgxc_data/coord2/pg_log/postgresql-2016-12-10*.csv  > ~/error_dir/coord2_121011_error 
grep ERROR /data/pgxc_data/db2/pg_log/postgresql-2016-12-10*.csv  > ~/error_dir/db2_121011_error 
 
grep FATAL /data/pgxc_data/coord2/pg_log/postgresql-2016-12-10*.csv  > ~/error_dir/coord2_121011_fatal 
grep FATAL /data/pgxc_data/db2/pg_log/postgresql-2016-12-10*.csv  > ~/error_dir/db2_121011_fatal 
  
  
# curl
curl -X GET http://localhost:9200/  
 
# find
find . -name "*" -type f -size 0c | xargs -n 1 rm -f
find /data/pgxc_data -name 'core*' | xargs ls -lrt
find /usr/local/backups -mtime +10 -name "*.*" -exec rm -rf {} \;


# touch
touch -t 201211142234.50 log.log

## for
value=$1
count=$2
for k in $( seq 1 $count  )
do
  psql -p 5432 -d postgres -U zjcmc -c "insert into test_kpi values ($value)"
done

#/bin/bash
psqlconn="psql -p 7642 -d db1 "

for file in `ls /home/danghb/tools/fortest | grep -E '*sql$'`
do
	$psqlconn -f $file
done


#!/bin/bash

source ~/.bashrc


for file in `ls /home/danghb/zjcmc/1221/cd2 | grep csv`
do
	cpsql="COPY coord2_pg_log FROM '/home/danghb/zjcmc/1221/cd2/$file' WITH csv;"
	psql -p 7642 -d db1 -c "$cpsql"
done


#/bin/bash
for i in `seq 10` 
do
  echo $i
done 

#/bin/bash
for i in `seq 10` 
do
  echo "select now(),$i;" > $i.sql
done 

# for 数组
filters=(ERROR FATAL)

for f in ${filters[@]}
do 
  outputfile=${outputdir}/${node}_${now}_${f}
  grep ${f} $node_log > $outputfile
done 

i=0
while [ $i -lt ${ #array[@] } ]
do
    echo ${ array[$i] }
    let i++
done

echo ${#array[@]}    #查看数组中有几个元素（length），${#i}能查看变量i的字符长度。
array[0]="1"
array[1]="2"
array[2]="3"



cat > iplist <<EOF
root password 192.168.1.1 dang dang
root password 192.168.1.1 dang dang
root password 192.168.1.1 dang dang
root password 192.168.1.1 dang dang
EOF


## while
cat $1|while read line; do
rootuser=`awk 'BEGIN {split("'"$line"'",arr);print arr[1]}'`
rootpasswd=`awk 'BEGIN {split("'"$line"'",arr);print arr[2]}'`
ipaddr=`awk 'BEGIN {split("'"$line"'",arr);print arr[3]}'`
newusername=`awk 'BEGIN {split("'"$line"'",arr);print arr[4]}'`
newuserpasswd=`awk 'BEGIN {split("'"$line"'",arr);print arr[5]}'`
# execute add user
echo "---------------add user $newusername on host $ipaddr-------------"
expect exp_adduser.exp $rootuser $rootpasswd $ipaddr $newusername $newuserpasswd
done

## 死循环
while true; do
  something
done	


## 重定向
echo log > /dev/null 2>&1
/dev/null ：代表空设备文件
>  ：代表重定向到哪里，例如：echo "123" > /home/123.txt
1  ：表示stdout标准输出，系统默认值是1，所以">/dev/null"等同于"1>/dev/null"
2  ：表示stderr标准错误
&  ：表示等同于的意思，2>&1，表示2的输出重定向等同于1

1 > /dev/null 2>&1 语句含义：
1 > /dev/null ： 首先表示标准输出重定向到空设备文件，也就是不输出任何信息到终端，说白了就是不显示任何信息。
2>&1 ：接着，标准错误输出重定向（等同于）标准输出，因为之前标准输出已经重定向到了空设备文件，所以标准错误输出也重定向到空设备文件。


# type
type cd
cd is a shell builtin
type cat
cat is /bin/cat

## version
cat /etc/redhat-release 

## ssh  no password
ssh-keygen
ssh-copy-id -i .ssh/id_rsa.pub host201
ssh-copy-id -i .ssh/id_rsa.pub localhost3
## 禁止root远程登录
/etc/ssh/sshd_config
PermitRootLogin no
# 登录后的欢迎信息
Banner /etc/ssh/ssh_banner



# perl
perl -MFile::Find=find -MFile::Spec::Functions -Tlwe 'find { wanted => sub { print canonpath $_ if /\.pm\z/ }, no_chdir => 1 }, @INC' > installed.sql

## perl module
perldoc -t perllocal | grep "Module" |grep Ora2pg
perl uninstall_perl_module.pl Ora2Pg

perl -MDBI -le  'print $DBI::VERSION;'  

http://www.cpan.org/modules/by-module/DBD/


## kill
ps -ef | grep dang_test |awk '{if($3!="1") print "kill -9 "$2}'|sh

ps -ef | grep postgres |awk '{if($3="22997") print "kill -9 "$2}'|sh



ps -ef | grep out_xa |awk '{if($3="1") print "kill -9 "$2}'|sh

## crontab
https://crontab.guru/

每五分钟执行  */5 * * * *
每小时执行     0 * * * *
每天执行        0 0 * * *
每周执行       0 0 * * 0
每月执行        0 0 1 * *
每年执行       0 0 1 1 *



# grep
grep -rn -Eo "duration: [0-9.]+" postgresql-2016-12-12_163730.csv | awk -F ':' '{if ($3 > 3000) {print $1, $3;}}'

egrep -v "^#|^$" /etc/ora2pg/ora2pg.conf.dist

## strings

tmp_dir=/home/dang/tmp/
echo ${#tmp_dir}
echo ${tmp_dir:0:${#tmp_dir}-1}

tmp_dir=${tmp_dir:0:${#tmp_dir}-1}
copysql_name=${copysql_name:0:${#copysql_name}-1}

sh gene_copysql.sh   /home/dang/tmp/ copy_test


## nmon
nmon
nmon -h
nmon -f -t -s 60 -f 43200
nmon -f -T -s 30 -f 180


## iostat
iostat -x -m 5
iostat -dx 1


## netstat
netstat -n | awk '/^tcp/ {++S[$NF]} END {for(a in S) print a, S[a]}'

## tcpdump
tcpdump -i em1 src host 10.20.16.200 
tcpdump -i em1 dst host 10.20.16.200 
tcpdump -i em1 port  46831
tcpdump -i eth1 net 192.168
tcpdump -i eth1 tcp
tcpdump tcp port 5432 -i eno16777728 -nnX -s0  -w 1234.cap

非 : ! or "not" (去掉双引号)  
且 : && or "and"  
或 : || or "or"

tcpdump -v -i em1 '((src host 10.20.16.200) and (port 48503)) and (ip[2:2] > 300)'
tcpdump -i eth1 'ip[2:2] > 600'
tcpdump -v -i em1 '((src host 10.20.16.200) and (port 48503))' -nnX
# -nnX 显示acsii码
tcpdump -v -i em1 '((src host 10.20.16.200) and (port 48503))' -s 0 -w tcptest
time tcpdump -nn -i eth0 'tcp[tcpflags] = tcp-syn' -c 10000 > /dev/null
# 上面的命令计算抓10000个SYN包花费多少时间，可以判断访问量大概是多少。
tcpdump tcp -i eth1 -t -s 0 -c 100 and dst port ! 22 and src net 192.168.1.0/24 -w ./target.cap
(1)tcp: ip icmp arp rarp 和 tcp、udp、icmp这些选项等都要放到第一个参数的位置，用来过滤数据报的类型
(2)-i eth1 : 只抓经过接口eth1的包
(3)-t : 不显示时间戳
(4)-s 0 : 抓取数据包时默认抓取长度为68字节。加上-S 0 后可以抓到完整的数据包
(5)-c 100 : 只抓取100个数据包
(6)dst port ! 22 : 不抓取目标端口是22的数据包
(7)src net 192.168.1.0/24 : 数据包的源网络地址为192.168.1.0/24
(8)-w ./target.cap : 保存成cap文件，方便用ethereal(即wireshark)分析

开启网卡的混杂模式：
ifconfig en0 promisc

http://www.ha97.com/4550.html
http://www.jianshu.com/p/8d9accf1d2f1

# sysctl
cat /proc/sys/kernel/sem
cat /etc/sysctl.conf
sysctl -w kernel.sem="50100 64128000 50100 1280"
SEMMSL SEMMNS SEMMOP SEMMNI
SEMMNI > ceil((max_connections + autovacuum_max_workers + 4) / 16)
SEMMNS > ceil((max_connections + autovacuum_max_workers + 4) / 16) * 17
SEMMOP=SEMMSL
# 查看配置
sysctl -a 
# 生效
sysctl -p


# tar
tar cvf adb-2.1.tar.gz adb-2.1
tar czvf adb-2.1.tar.gz adb-2.1

# lsof
lsof /bin/bash   查找某个文件相关的进程
lsof -u username  列出某个用户打开的文件信息
lsof -c mysql  列出某个程序进程所打开的文件信息
lsof  -u test -c mysql   列出某个用户以及某个进程所打开的文件信息
lsof -p 11968 通过某个进程号显示该进程打开的文件 
lsof -i  列出所有的网络连接
lsof -i tcp 列出所有tcp 网络连接信息
lsof -i :3306 列出谁在使用某个端口
lsof -a -u test -i 列出某个用户的所有活跃的网络端口
lsof -d 3 | grep PARSER1  根据文件描述列出对应的文件信息
lsof -i 4 -a -p 1234  列出被进程号为1234的进程所打开的所有IPV4 network files
lsof -i @nf5260i5-td:20,21,80 -r 3  列出目前连接主机nf5260i5-td上端口为：20，21，80相关的所有文件信息，且每隔3秒重复执行


# top
top -c
top 界面 按1，显示每个cpu的详细使用情况

下面列出一些常用的 top命令操作指令

q：退出top命令
<Space>：立即刷新
s：设置刷新时间间隔
c：显示命令完全模式
t:：显示或隐藏进程和CPU状态信息
m：显示或隐藏内存状态信息
l：显示或隐藏uptime信息
f：增加或减少进程显示标志
S：累计模式，会把已完成或退出的子进程占用的CPU时间累计到父进程的MITE+
P：按%CPU使用率排行
T：按MITE+排行
M：按%MEM排行
u：指定显示用户进程
r：修改进程renice值
kkill：进程
i：只显示正在运行的进程
W：保存对top的设置到文件^/.toprc，下次启动将自动调用toprc文件的设置。
h：帮助命令。
q：退出

在top基本视图中,按键盘“b”（打开/关闭加亮效果）；


# strace
http://linuxtools-rst.readthedocs.io/zh_CN/latest/tool/strace.html
strace -T -r -c -p 30654

strace -tt -T -v -f  -o /data/strace.log -s 1024 -p 21634

strace -f -F -o ~/straceout.txt myserver
-f -F选项告诉strace同时跟踪fork和vfork出来的进程，-o选项把所有strace输出写到~/straceout.txt里 面，myserver是要启动和调试的程序。
strace -o output.txt -T -tt -e trace=all -p 28398
跟踪28979进程的所有系统调用（-e trace=all），并统计系统调用的花费时间，以及开始时间（并以可视化的时分秒格式显示），最后将记录结果存在output.txt文件里面。
[root@adb02 ~]# strace -T -r -c -p 28398
Process 30838 attached
^CProcess 30838 detached
% time     seconds  usecs/call     calls    errors syscall
------ ----------- ----------- --------- --------- ----------------
 35.69    1.050134          64     16456           recvfrom
 35.45    1.043139          16     63648           write
 19.19    0.564677          19     30272           sendto
  3.52    0.103608         129       801           fdatasync
  1.50    0.044203          18      2409           semop
  1.00    0.029568          13      2260           brk
  0.74    0.021781          29       749        60 open
  0.62    0.018143          13      1380           lseek
  0.52    0.015171          19       799           kill
  0.51    0.014981          25       604           select
  0.50    0.014858          22       691           close
  0.44    0.013068          46       287           unlink
  0.17    0.004932          17       287           read
  0.14    0.004153          14       287           fstat
  0.00    0.000000           0         1           mmap
  0.00    0.000000           0         1           munmap
------ ----------- ----------- --------- --------- ----------------
100.00    2.942416                120932        60 total


# 测试cpu性能
time echo "scale=5000; 4*a(1)" | bc -l -q

# dstat
dstat -amlspt
dstat -tcdrgilmns 
usr sys idl wai hiq siq| read  writ| recv  send|  in   out | int   csw | used  buff  cach  free| 1m   5m  15m | used  free|run blk new|     time     
  7   1  91   0   0   0| 844k 1664k|   0     0 |  16k   15k|7240  7699 |5276M 43.5M 57.4G  369M|7.12 6.93 4.83|2633M 5431M|0.0   0 4.2|23-03 17:53:54
 20   6  70   0   0   3|   0    11M|2947k 6771k|   0     0 |  45k   69k|5284M 43.5M 57.4G  356M|7.12 6.93 4.83|2633M 5431M| 15   0 6.0|23-03 17:53:55
 18   6  73   0   0   3|   0    13M|2973k 7475k|   0     0 |  47k   74k|5278M 43.5M 57.4G  351M|7.11 6.93 4.84|2633M 5431M| 11   0 4.0|23-03 17:53:56
dstat --top-mem --top-io --top-cpu
nohup dstat -amlspt  --output  /home/sh2.2/hostmon/dstat.csv  --noupdate 5 8640 2>&1 &
dstat -c -y -l --proc-count --top-cpu
dstat -g -l -m -s --top-mem

dstat -tc --top-cpu -dr --top-io -glm --top-mem -ns --output t.csv
# pagesize 
/usr/bin/time -v date
getconf PAGE_SIZE
 
  
# numa
 Redhat或者Centos系统中可以通过命令判断bios层是否开启numa
grep -i numa /var/log/dmesg
numactl --hardware
      
# ipcs
ipcs -a |grep postgres|cut -d' ' -f2|xargs -n1 ipcrm -s
ipcs -m
ipcs -s      


$ GLIBC_
strings /lib64/libc.so.6 |grep GLIBC_  



#sysdig
sysdig -c bottlenecks 
sysdig -c spectrogram 500
sysdig -cl
sysdig -i 

https://www.sysdig.org/wiki/sysdig-examples/#performance



#netstat
netstat -n | awk '/^tcp/ {++S[$NF]} END {for(a in S) print a, S[a]}'
TIME_WAIT的连接数是需要注意的一点。此值过高会占用大量连接，影响系统的负载能力。需要调整参数，以尽快的释放time_wait连接。

echo -e '\xf'  # 从乱码中恢复
echo -e '\xe'  # 变乱码


yum install -y blktrace
blktrace -d /dev/sdb1
blkparse -i sdb1 -d sdb1.blktrace.bin
btt -i sdb1.blktrace.bin|more




# PS1
export PS1='[\u@\h \W]\$'