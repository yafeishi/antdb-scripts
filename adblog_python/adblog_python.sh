python /data/hostmon/adblog_python/adblog_sqlinfo.py coord1 /data/adb/coord/pg_log 2018-01-30_151501 2018-01-30_160300
python /data/hostmon/adblog_python/adblog_sqlinfo.py coord2 /data/adb/coord/pg_log 2018-01-30_151501 2018-01-30_160300
python /data/hostmon/adblog_python/adblog_sqlinfo.py coord3 /data/adb/coord/pg_log 2018-01-30_151501 2018-01-30_160300
python /data/hostmon/adblog_python/adblog_sqlinfo.py coord4 /data/adb/coord/pg_log 2018-01-30_151501 2018-01-30_160300
python /data/hostmon/adblog_python/adblog_sqlinfo.py coord5 /data/adb/coord/pg_log 2018-01-30_151501 2018-01-30_160300
python /data/hostmon/adblog_python/adblog_sqlinfo.py coord6 /data/adb/coord/pg_log 2018-01-30_151501 2018-01-30_160300
python /data/hostmon/adblog_python/adblog_sqlinfo.py coord7 /data/adb/coord/pg_log 2018-01-30_151501 2018-01-30_160300
python /data/hostmon/adblog_python/adblog_sqlinfo.py coord8 /data/adb/coord/pg_log 2018-01-30_151501 2018-01-30_160300



python /data/hostmon/adblog_python/adblog_auth.py coord1 /data/adb/coord/pg_log 2017-12-28_120001 2017-12-28_130000
python /data/hostmon/adblog_python/adblog_auth.py coord2 /data/adb/coord/pg_log 2017-12-28_120001 2017-12-28_130000
python /data/hostmon/adblog_python/adblog_auth.py coord3 /data/adb/coord/pg_log 2017-12-28_120001 2017-12-28_130000
python /data/hostmon/adblog_python/adblog_auth.py coord4 /data/adb/coord/pg_log 2017-12-28_120001 2017-12-28_130000
python /data/hostmon/adblog_python/adblog_auth.py coord5 /data/adb/coord/pg_log 2017-12-28_120001 2017-12-28_130000
python /data/hostmon/adblog_python/adblog_auth.py coord6 /data/adb/coord/pg_log 2017-12-28_120001 2017-12-28_130000
python /data/hostmon/adblog_python/adblog_auth.py coord7 /data/adb/coord/pg_log 2017-12-28_120001 2017-12-28_130000
python /data/hostmon/adblog_python/adblog_auth.py coord8 /data/adb/coord/pg_log 2017-12-28_120001 2017-12-28_130000


cd /data/hostmon/adblog_python

alter table adblog_sqlinfo rename to adblog_sqlinfo_1225;

select nodename,count(*) from adblog_sqlinfo group by 1 order by 1;


select to_char(logtime,'yyyy-mm-dd hh24:mi:ss'),count(*),sum(duration)/count(*) 
from adblog_sqlinfo 
where 1=1 
and dbname='shhis' 
and username in ('so1','so2','base') 
--and command_tag='SELECT'  
and logtime between now() - interval '30 mins' and now() 
--and sqltext ilike '%bmsql_stock where%'
group by 1 
order by 1; 


select to_char(logtime,'yyyy-mm-dd hh24:mi'),count(*),sum(duration)/count(*) 
from adblog_sqlinfo 
where 1=1 
and dbname='shhis' 
and username in ('so1','so2','base') 
--and command_tag='SELECT'  
and to_char(logtime,'yyyy-mm-dd hh24:mi') between '2018-02-06 12:00' and '2018-02-06 23:00' 
and sqltext ilike '%sec_operator%'
--and sqltext ilike '%so_busi_log%user_id%'
group by 1 
order by 1; 



select to_char(logtime,'yyyy-mm-dd hh24:mi'),count(*),sum(duration)/count(*)
from adblog_sqlinfo
where 1=1
and dbname='shhis'
and username in ('so1','so2','base')
group by 1
order by 1;


select to_char(logtime,'yyyy-mm-dd hh24:mi:ss'),duration,substr(sqltext,0,100)
from adblog_sqlinfo
where 1=1
and dbname='shhis'
and username in ('so1','so2','base')
and to_char(logtime,'yyyy-mm-dd hh24:mi') between '2018-02-06 21:00' and '2018-02-6 21:30' 
and duration > 1000
--group by 1
order by 2;

select command_tag,count(*)
from adblog_sqlinfo
where 1=1
and dbname='shhis'
and username in ('so1','so2','base')
and to_char(logtime,'yyyy-mm-dd hh24:mi')='2017-12-25 11:57'
group by command_tag
--group by 1
order by 1;

select to_char(logtime,'yyyy-mm-dd hh24:mi'),command_tag,count(*)
from adblog_sqlinfo
where 1=1
and dbname='shhis'
and username in ('so1','so2','base')
and command_tag='SELECT'
--and to_char(logtime,'yyyy-mm-dd hh24:mi')='2017-12-25 11:57'
group by 1,2
order by 1,2;


select to_char(logtime,'yyyy-mm-dd hh24:mi:ss'),count(*),sum(duration)/count(*) 
from adblog_sqlinfo 
where 1=1 
and dbname='shhis' 
and username in ('so1','so2','base') 
and command_tag='SELECT' 
--and to_char(logtime,'yyyy-mm-dd hh24:mi')='2017-12-25 11:57' 
and to_char(logtime,'yyyy-mm-dd hh24:mi') between '2018-01-30 15:30' and '2018-01-30 16:03' 
and sqltext ilike '%UNION ALL%'
group by 1 
order by 1; 



select nodename,logtime,sqltext,duration
from adblog_sqlinfo 
where 1=1 
and dbname='shhis' 
and username in ('so1','so2','base') 
and command_tag='SELECT' 
--and to_char(logtime,'yyyy-mm-dd hh24:mi')='2017-12-25 11:57' 
and to_char(logtime,'yyyy-mm-dd hh24:mi') between '2018-01-30 10:20' and '2018-01-30 11:00'  
--and sqltext ilike '%UNION ALL%'
and duration > 10000
order by 1,2; 

select to_char(logtime,'yyyy-mm-dd hh24:mi:ss'),count(*),sum(duration)/count(*) 
from adblog_sqlinfo 
where 1=1 
and dbname='shhis' 
and username in ('so1','so2','base') 
and command_tag='SELECT' 
--and to_char(logtime,'yyyy-mm-dd hh24:mi')='2017-12-25 11:57' 
and to_char(logtime,'yyyy-mm-dd hh24:mi') between '2017-12-29 11:02' and '2017-12-29 11:30' 
group by 1 
order by 1; 



select to_char(logtime,'yyyy-mm-dd hh24:mi'),count(distinct connection)
from adblog_sqlinfo
where 1=1
and dbname='shhis'
and username in ('so1','so2','base')
and command_tag='SELECT'
--and to_char(logtime,'yyyy-mm-dd hh24:mi')='2017-12-25 11:57'
and to_char(logtime,'yyyy-mm-dd hh24:mi') between '2017-12-25 11:50' and '2017-12-25 12:00'
group by to_char(logtime,'yyyy-mm-dd hh24:mi')
--group by 1
order by 1;



select connection,count(*)
from adblog_sqlinfo
where 1=1
and dbname='shhis'
and username in ('so1','so2','base')
--and command_tag='SELECT'
--and to_char(logtime,'yyyy-mm-dd hh24:mi')='2017-12-25 11:57'
group by 1
order by 1;


select connection,count(*)
from adb_sqlinfo
where 1=1
and dbname='shhis'
and username in ('so1','so2','base')
--and command_tag='SELECT'
--and to_char(logtime,'yyyy-mm-dd hh24:mi')='2017-12-25 11:57'
group by 1
order by 1;


select to_char(logtime,'yyyy-mm-dd hh24:mi'),split_part(connection,':',1),count(*)
from adblog_sqlinfo
where 1=1
and dbname='shhis'
and username in ('so1','so2','base')
--and to_char(logtime,'yyyy-mm-dd hh24:mi') ='2017-12-25 11:58' 
and to_char(logtime,'yyyy-mm-dd hh24:mi') between '2017-12-25 11:50' and '2017-12-25 12:00'

group by 1,2
order by 1,2;



select min(logtime),max(logtime) from adb_sqlinfo;






select to_char(logtime,'yyyy-mm-dd hh24:mi'),count(*)
from adblog_auth
where 1=1
and dbname='shhis'
and username in ('so1','so2','base')
--and to_char(logtime,'yyyy-mm-dd hh24:mi') between '2017-12-25 11:50' and '2017-12-25 12:00'
group by 1
order by 1;


select to_char(logtime,'yyyy-mm-dd hh24:mi'),split_part(connection,':',1),count(*)
from adblog_auth
where 1=1
and dbname='shhis'
and username in ('so1','so2','base')
and to_char(logtime,'yyyy-mm-dd hh24:mi') between '2017-12-25 11:58' and '2017-12-25 11:59'
group by 1,2
order by 1,2;


select nodename,count(*)
from adblog_auth
where 1=1
and dbname='shhis'
and username in ('so1','so2','base')
and to_char(logtime,'yyyy-mm-dd hh24:mi') between '2017-12-25 11:58' and '2017-12-25 12:02'
group by 1
order by 1,2;


select to_char(logtime,'yyyy-mm-dd hh24:mi:ss'),username,count(*)
from adblog_auth
where 1=1
and dbname='shhis'
and username in ('so1','so2','base')
and to_char(logtime,'yyyy-mm-dd hh24:mi') between '2017-12-25 11:59' and '2017-12-25 11:59'
group by 1,2
order by 1,2;


select to_char(logtime,'yyyy-mm-dd hh24:mi'),split_part(connection,':',1),count(*)
from adblog_auth
where 1=1
and dbname='shhis'
--and username in ('so1','so2','base')
--and to_char(logtime,'yyyy-mm-dd hh24:mi') ='2017-12-25 11:58' 
group by 1,2
order by 1,2;



select to_char(logtime,'yyyy-mm-dd hh24:mi'),count(*)
from adblog_received
where 1=1
and connection like '10.10.108%'
--and to_char(logtime,'yyyy-mm-dd hh24:mi') between '2017-12-25 11:50' and '2017-12-25 12:00'
group by 1
order by 1;


select to_char(logtime,'yyyy-mm-dd hh24:mi'),count(*)
from adblog_sqlparsebind
where 1=1
and connection like '10.10.108%'
and command_tag = 'BIND'
--and to_char(logtime,'yyyy-mm-dd hh24:mi') between '2017-12-25 11:50' and '2017-12-25 12:00'
group by 1
order by 1;

