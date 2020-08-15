

############################ adbmgr
initmgr -D /home/danghb/adb22/adbmgr
mgr_ctl start -D /home/danghb/adb22/adbmgr &
mgr_ctl stop -D /home/danghb/adb22/adbmgr -m fast
adbmgrd -D /home/danghb/adb22/adbmgr &

add host host201(port=22,protocol='ssh',pghome='/home/danghb/adb22/pgsql_xc',address="10.20.16.201",agentport=7632,user='danghb');
add host host200(port=22,protocol='ssh',pghome='/home/danghb/adb22/pgsql_xc',address="10.20.16.200",agentport=7632,user='danghb');

deploy all
start agent all

# add
1、	添加coordinator信息：
add coordinator coord1(path = '/home/danghb/adb22/pgsql_data/coord', host='host200', port=7642);
add coordinator coord2(path = '/home/danghb/adb22/pgsql_data/coord', host='host201', port=7642);

2、	添加datanode master信息：
add datanode master db1(path = '/home/danghb/adb22/pgsql_data/dn01', host='host200', port=7652);
add datanode master db2(path = '/home/danghb/adb22/pgsql_data/dn02', host='host201', port=7652);

3、	添加datanode slave信息，添加slave的时候，由于slave与master同名，所以在master关键字后面写上刚才添加的master名字即可。
add datanode slave  db2(host='host200',port=7653,path = '/home/danghb/adb22/pgsql_data/dn02');
4、	添加gtm信息
add gtm master gtm(host='host200',port=7766, path='/home/danghb/adb22/pgsql_data/gtm');
add gtm slave gtm(host='host201',port=7766, path='/home/danghb/adb22/pgsql_data/gtm');


start agent all;

ssh danghb@host201 "echo host all all 0.0.0.0/0 trust >> /home/danghb/adb22/pgsql_data/dn01/pg_hba.conf "

alias pgsql='psql "port=7532 dbname=postgres options='\''-c command_mode=sql'\''"'
psql "port=7532 dbname=postgres options='-c command_mode=sql'"

update pg_catalog.mgr_node set nodeincluster=true;
update pg_catalog.mgr_node set nodeinited=true;

# alter
alter datanode master db2(path = '/home/danghb/adb22/pgsql_data/dn02');

# drop
drop datanode master db1;

# stop
stop datanode master db2;
# set
set datanode master all (log_destination='csvlog');
set coordinator master all (log_destination='csvlog');
set coordinator master all(shared_preload_libraries = 'pg_stat_statements',pg_stat_statements.track = all,pg_stat_statements.save=true)
set coordinator  all(pg_stat_statements.max = 101) force;
set datanode master all(shared_buffers = '1024MB',work_mem='50MB');


set coordinator  coord1 (dang.adb = 10) force;



set datanode master all(lock_timeout = '60s');


pg_ctl start -D /home/danghb/adb22/pgsql_data/coord -Z coordinator -o -i -w -c -l /home/danghb/adb22/pgsql_data/coord/logfile
pg_ctl stop -D /home/danghb/adb22/pgsql_data/coord -Z coordinator -m smart -o -i -w -c -l /home/danghb/adb22/pgsql_data/coord/logfile

# restoremode
pg_ctl restart -Z restoremode -D /data/danghb//data/adb40/d1/cd6 -R coordinator -o -i -w -c -l /data/danghb//data/adb40/d1/cd6/logfile


############################ adbmgr


create user user01;
create schema user01 AUTHORIZATION user01;

create database testdb;
create database testdb with owner=user01 encoding='utf8' tablespace=tbs_test;

create table danghb.test(id int, name text) distribute by replication;
create table danghb.test(id int, name text) distribute by hash(id)  ;
create table test(id int, name text) distribute by ROUNDROBIN;
create table test(id int, name text) distribute by hash(id) to node (datanode1,datanode2);


alter table test distribute by hash(id);

insert into test values (1,'dang'),(2,'dang'),(3,'dang'),(4,'dang');
INSERT INTO numbers (num) VALUES ( generate_series(1,1000));
select substr('abcdefghijklmnopqrstuvwxyz',(random()*26)::integer,(random()*26)::integer)

create tablespace tbs_test owner user01 location '/postgres/adb2_1/tbs/tbs_test';


CREATE OR REPLACE FUNCTION add(a numeric, b integer)
 RETURNS numeric
 LANGUAGE sql
AS $function$
SELECT a+b;
$function$;

create or replace function test_delete_trigger()
returns trigger as $$
begin 
	insert into  test_delete values (old.id,old.name);
	return old;
end;
$$ language plpgsql;



do language plpgsql $$  
declare  
  v_sql text;  
begin  
  for i in 1..1000 loop  
    v_sql := 'create table test_'||i||'(id int, info text)';  
    execute v_sql;  
    v_sql := 'insert into test_'||i||'(id,info) select generate_series(1,1000),''test''';  
    execute v_sql;  
  end loop;  
end;  
$$;

create trigger  delete_test_trigger
before delete on  test
for each row execute procedure  test_delete_trigger();


select sum(hashtext(t.*::text)) from $tab as t

# pgxc_ctl

stop all 顺序：
coordinator
datanode
gtm proxy
GTM master

start all 顺序：
GTM master
gtm_proxy
coordinator
datanode

deploy all
deploy localhost3


add gtm slave gtm_s host201 7666 /home/danghb/adb21/pgsql_data/gtm
add gtm_proxy gtm_proxy2 host201 6677 /home/danghb/adb21/pgsql_data/gtm_proxy


cat > $datanode1SpecificExtraConfig <<EOF
archive_command = 'cp -i %p /home/danghb/adb21/pgsql_data/archive/dn01/%f'
EOF

archive_command = 'cp -i %p /home/danghb/adb21/pgsql_data/archive/dn01/%f'
add datanode slave datanode1 host200 /home/danghb/adb21/pgsql_data/dn01 /home/danghb/adb21/pgsql_data/archive/dn01
add datanode slave datanode2 host201 /home/danghb/adb21/pgsql_data/dn02 /home/danghb/adb21/pgsql_data/archive/dn02

add coordinator slave coord1 localhost3 /home/danghb/adb21/pgsql_data/cn01 /home/danghb/adb21/pgsql_data/archive/cn01
add coordinator slave coord2 localhost3 /home/danghb/adb21/pgsql_data/cn02 /home/danghb/adb21/pgsql_data/archive/cn02


add coordinator master coord3 localhost4 7434 20073  /home/danghb/adb21/pgsql_data/cn03
add datanode master datanode3 localhost4 17434 /home/danghb/adb21/pgsql_data/dn03 

remove gtm slave
remove datanode slave datanode1
remove datanode master datanode3
remove coordinator master coord3 
remove coordinator slave coord3 

start datanode slave datanode1

show configure all
show configure datanode


## failover 之后都需要add相应的slave

failover gtm
failover coordinator nodename |
failover datanode datanode1 


##psql select
select pgxc_pool_reload();
select pg_relation_filepath('root.tabletest');
select pg_database_size('bmsql');   
select pg_database.datname, 
pg_database_size(pg_database.datname) AS size 
from pg_database; 
select pg_database.datname, 
pg_size_pretty(pg_database_size(pg_database.datname)) AS size 
from pg_database; 
select pg_size_pretty(pg_database_size('hongpay')); 
select pg_relation_size('test');  # table size
select pg_size_pretty(pg_relation_size('test'));
select pg_size_pretty(pg_total_relation_size('test')); 
select spcname from pg_tablespace;  
select pg_size_pretty(pg_tablespace_size('pg_default'));
SELECT pg_size_pretty(SUM(pg_total_relation_size(quote_ident(schemaname) || '.' || quote_ident(tablename)))::BIGINT) 
FROM pg_tables WHERE schemaname = 'weian';

SELECT d.datname as "Name",
       pg_catalog.pg_get_userbyid(d.datdba) as "Owner",
       pg_catalog.pg_encoding_to_char(d.encoding) as "Encoding",
       d.datcollate as "Collate",
       d.datctype as "Ctype",
       pg_catalog.array_to_string(d.datacl, E'\n') AS "Access privileges",
       CASE WHEN pg_catalog.has_database_privilege(d.datname, 'CONNECT')
            THEN pg_catalog.pg_size_pretty(pg_catalog.pg_database_size(d.datname))
            ELSE 'No Access'
       END as "Size",
       t.spcname as "Tablespace",
       pg_catalog.shobj_description(d.oid, 'pg_database') as "Description"
FROM pg_catalog.pg_database d
  JOIN pg_catalog.pg_tablespace t on d.dattablespace = t.oid
ORDER BY 1;


SELECT schema_name, 
       pg_size_pretty(sum(table_size)),
       trunc((sum(table_size) / database_size) * 100,2)||'%'
FROM (
  SELECT pg_catalog.pg_namespace.nspname as schema_name,
         pg_relation_size(pg_catalog.pg_class.oid) as table_size,
         sum(pg_relation_size(pg_catalog.pg_class.oid)) over () as database_size
  FROM   pg_catalog.pg_class
     JOIN pg_catalog.pg_namespace ON relnamespace = pg_catalog.pg_namespace.oid
) t
GROUP BY schema_name, database_size
order by  schema_name
;

select s.schema_name,s.relname,pg_size_pretty(s.table_size)
from 
(
SELECT n.nspname as schema_name,
       c.relname as relname,
       pg_relation_size(c.oid) as table_size
FROM   pg_catalog.pg_class c,
       pg_catalog.pg_namespace n
where 1=1
and c.relowner=n.nspowner
and n.nspname='so1'
and c.relkind = 'r'
and relname not like 'pg_%'
order by 3 desc 
) s
;

SELECT
   relname AS table_name,
   pg_size_pretty(pg_total_relation_size(relid)) AS total,
   pg_size_pretty(pg_relation_size(relid)) AS internal,
   pg_size_pretty(pg_table_size(relid) - pg_relation_size(relid)) AS external,
   pg_size_pretty(pg_indexes_size(relid)) AS indexes
    FROM pg_catalog.pg_statio_user_tables ORDER BY pg_total_relation_size(relid) DESC;



SELECT n.nspname as schema_name,
       c.relname,
       pg_size_pretty(pg_relation_size(c.oid)) as table_size,
       'VACUUM ANALYZE '||n.nspname||'.'||c.relname||';'
FROM   pg_catalog.pg_class c,
       pg_catalog.pg_namespace n
where 1=1
and c.relowner=n.nspowner
and n.nspname='so1'
and c.relkind = 'r'
and relname not like 'pg_%'
order by 2  ;


select *
from (
select 
  n.nspname,
  c.relname,
	a.attname,
	t.typname,
	a.attlen
from 
	pg_class c,
	pg_attribute a,
	pg_type t,
	pg_namespace n
where 1=1
and a.atttypid=t.oid
and c.oid=a.attrelid
and c.relnamespace = n.oid
and c.relkind = 'r'
and n.nspname like '%public%'
and c.relname not like 'pg_%'
and a.attnum > 0
order by 
  n.nspname,
	c.relname,
	a.attnum
) typ
where typname='bytea';


select relkind,count(*)
from pg_class
where 1=1
group by relkind
order by 2 desc;


select *
from 
(
SELECT n.nspname as "Schema",
  c.relname as "Name",
  pg_catalog.pg_get_userbyid(c.relowner) as "Owner",
  pg_catalog.pg_total_relation_size(c.oid)/1024/1024 as Size_MB
  FROM pg_catalog.pg_class c
     LEFT JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
WHERE c.relkind IN ('r')
      AND n.nspname <> 'pg_catalog'
      AND n.nspname <> 'information_schema'
      AND n.nspname !~ '^pg_toast'
) as s
order by s.Size_MB desc;

SELECT n.nspname,c.relkind,count(*)
FROM   pg_catalog.pg_class c,
       pg_catalog.pg_namespace n
where 1=1
and c.relowner=n.nspowner
and n.nspname='public'
group by n.nspname,c.relkind
order by 3 desc;


-- pgxc_class
select n.nspname,c.relname,xc.pclocatortype
from pg_class c,pg_namespace n,pgxc_class xc
where 1=1
and c.relnamespace=n.oid
and c.oid=xc.pcrelid
and c.relkind='r'
--and n.nspname='weian'
and xc.pclocatortype<>'H';


EXECUTE DIRECT ON (db1) 'select now()';
SELECT current_database();
SELECT current_user;
select current_schema;
select current_date;
select current_time;
select current_schemas(true);
SELECT pg_ls_dir('pg_log');
SELECT txid_current();
select txid_current_snapshot();
select pg_current_xlog_location();
select pg_last_xlog_replay_location();
select pg_last_xact_replay_timestamp();
select pg_xlogfile_name('1/58AA17B0');
select * from pg_xlogfile_name_offset('1/F8002B70');
select * from pg_xlogfile_name_offset(pg_current_xlog_location());

select  pg_xlogfile_name_offset(pg_current_xlog_location())
union all
select pg_xlogfile_name_offset(replay_location)
from pg_stat_replication;

./check_postgres_hot_standby_delay --dbhost=host201,host200 --dbport=17433,17433  --dbuser=danghb --dbname=bmsql --warning='1'


select pg_xlog_location_diff(pg_stat_replication.sent_location, pg_stat_replication.replay_location)
from pg_stat_replication;


SELECT CASE WHEN pg_last_xlog_receive_location() = pg_last_xlog_replay_location()
              THEN 0
            ELSE EXTRACT (EPOCH FROM now() - pg_last_xact_replay_timestamp())
       END AS log_delay;
       
select * from pg_proc; 
select * from pg_proc where proname like '%loca%';

select * from pg_stat_replication ;

select pg_get_function_arguments('bt_page_stats'::regproc);
select pg_get_function_identity_arguments('bt_page_stats'::regproc);

SELECT proargnames from pg_proc where proname ='bt_page_stats';

select datname,datfrozenxid,age(datfrozenxid) from pg_database;
select b.nspname,a.relname,a.relfrozenxid,age(a.relfrozenxid) 
from pg_class a, pg_namespace b 
where a.relnamespace=b.oid and a.relkind='r' 
order by a.relfrozenxid::text::int8 limit 10;

select extract(epoch FROM (date2 - date1)) from test_time;


# parameter 
PostgreSQL的不同配置参数在修改后有不同生效方式和类别，各种分类如下：
    Postmaster: 需要PostgreSQL服务器重启。
    Sighup：需要操作系统发出挂起信号类，这可以通过执行 kill -HUP，pg_ctl reload 或是select pg_reload_conf()来实现。
    User：可以根据不同的用户会话进行设置，仅在当前会话中生效。
    Internal: 在PostgreSQL自身编译时设置，以后不可以修改。
    Backend: 仅可以在用户会话启动前设置。
    Superuser: 可以由超级用户在运行时设置。
    
set para_name to value;
RESET max_connections;


share buffer host_mem*0.25

select distinct category from pg_settings order by 1;
select name,setting,unit,context,short_desc,category
from pg_settings 
where category like 'Query Tuning%'
order by 6,1;


watch -n 1 psql -c \"\\l+\"

set session authorization user01;

#  grant
grant all on schema user01 to user01;
grant all privileges on all tables in schema user01 to user01;  


#pg_ctl
pg_ctl reload -D /postgres/adb2_1/pgdata_xc/coord1  
pg_ctl restart -D /postgres/adb2_1/pgdata_xc/coord1  
pg_ctl restart -Z coordinator -D /postgres/adb2_1/pgdata_xc/coord1  



# statistics
analyze test;
analyze verbose test;
analyze test (id);
analyze verbose test (name);

select relpages,reltuples 
from pg_class where relname = 'test'; 

SELECT relname, relkind, reltuples, relpages 
FROM pg_class WHERE relname LIKE '%test%';


SELECT tablename,attname, inherited, n_distinct,
array_to_string(most_common_vals, E'\n') as most_common_vals 
FROM pg_stats WHERE tablename like '%test%';


SELECT histogram_bounds FROM pg_stats
WHERE tablename='test' AND attname='unique1';

SELECT null_frac, n_distinct, most_common_vals, most_common_freqs FROM pg_stats
WHERE tablename='tenk1' AND attname='stringu1';


seq scan cost = relpages * seq_page_cost + reltuples * cpu_tuple_cost


ALTER TABLE <table> ALTER COLUMN <column> SET STATISTICS <number>;

# mon
## 连接数
psql -p 5432 -t -c "select round(numbackends/(select current_setting('max_connections'))::numeric,2)*100 from pg_stat_database where datname = 'postgres'" -h 10.78.187.108


# buffer
select c.relname,pg_size_pretty(count(*) * 8192) as pg_buffered, 
       round(100.0 * count(*) / 
           (select setting 
            from pg_settings 
            where name='shared_buffers')::integer,1)
       as pgbuffer_percent,
       round(100.0*count(*)*8192 / pg_table_size(c.oid),1) as percent_of_relation,
       ( select round( sum(pages_mem) * 4 /1024,0 )
         from pgfincore(c.relname::text) ) 
         as os_cache_MB , 
         round(100 * ( 
               select sum(pages_mem)*4096 
               from pgfincore(c.relname::text) )/ pg_table_size(c.oid),1) 
         as os_cache_percent_of_relation,
         pg_size_pretty(pg_table_size(c.oid)) as rel_size 
 from pg_class c 
 inner join pg_buffercache b on b.relfilenode=c.relfilenode 
 inner join pg_database d on (b.reldatabase=d.oid and d.datname=current_database()
            and c.relnamespace=(select oid from pg_namespace where nspname='public')) 
 group by c.oid,c.relname 
 order by 3 desc limit 30;
 
 
SELECT c.relname,count(*) AS buffers
    FROM pg_class c INNER JOIN pg_buffercache b
    ON b.relfilenode=c.relfilenode INNER JOIN pg_database d
    ON (b.reldatabase=d.oid AND 
    d.datname=current_database())
    GROUP BY c.relname ORDER BY 2 DESC LIMIT 100; 
 
SELECT                                                  
c.relname,
pg_size_pretty(count(*) * (select setting from pg_settings where name='block_size')::integer ) as buffered,
round(100.0 * count(*) /
(SELECT setting FROM pg_settings
WHERE name='shared_buffers')::integer,1)
AS buffers_percent,
round(100.0 * count(*) * (select setting from pg_settings where name='block_size')::integer /
pg_relation_size(c.oid),1)
AS percent_of_relation
FROM pg_class c
INNER JOIN pg_buffercache b
ON b.relfilenode = c.relfilenode
INNER JOIN pg_database d
ON (b.reldatabase = d.oid AND d.datname = current_database())
GROUP BY c.oid,c.relname
ORDER BY 3 DESC
LIMIT 10;

SELECT c.relname, count(*) AS buffers
 FROM pg_class c INNER JOIN pg_buffercache b
 ON b.relfilenode = c.relfilenode INNER JOIN pg_database d
 ON (b.reldatabase = d.oid AND d.datname = current_database())
 where c.relname='reqmatrixlist'
 GROUP BY c.relname
 ORDER BY 2 DESC LIMIT 10; 
 
 
SELECT 
  sum(heap_blks_read) as heap_read,
  sum(heap_blks_hit)  as heap_hit,
  sum(heap_blks_hit) / (sum(heap_blks_hit) + sum(heap_blks_read)) as ratio
FROM 
  pg_statio_user_tables; 


  
SELECT 
  relname, 
  100 * idx_scan / (seq_scan + idx_scan) percent_of_times_index_used, 
  n_live_tup rows_in_table
FROM 
  pg_stat_user_tables
WHERE 
    seq_scan + idx_scan > 0 
ORDER BY 
  n_live_tup DESC;  
  
SELECT 
  sum(idx_blks_read) as idx_read,
  sum(idx_blks_hit)  as idx_hit,
  (sum(idx_blks_hit) - sum(idx_blks_read)) / sum(idx_blks_hit) as ratio
FROM 
  pg_statio_user_indexes;
  
select blks_read,blks_hit, 
       blks_hit::numeric / (blks_read + blks_hit ) as ratio 
from   pg_stat_database 
where  datname = 'manu_db' ;    



# invalid index
select indrelid::regclass,indexrelid::regclass,indkey
from pg_index
where indisvalid =false
order by 1,2;


# execute plan
user01@testdb:5532 > explain select * from test where id=1;
                              QUERY PLAN                              
----------------------------------------------------------------------
 Index Scan using test_pkey on test  (cost=0.42..8.44 rows=1 width=9)
   Index Cond: (id = 1)
(2 rows)

explain select * from test where id=1;
explain analyze select * from test where id=1;
explain (analyze,buffers) select * from test where id=1;
explain (analyze,verbose,timing,buffers,costs) select * from test where id<1001;


explain (verbose,costs false)  

select pg_cancel_backend(8880);
select pg_terminate_backend();


# sessionid

SELECT to_hex(EXTRACT(EPOCH FROM backend_start)::integer) || '.' ||
       to_hex(pid)
FROM pg_stat_activity;


SELECT to_hex(EXTRACT(EPOCH FROM backend_start)::integer) || '.' ||
       to_hex(pid)
FROM pg_stat_activity
where pid=30117;

SELECT to_hex(EXTRACT(EPOCH FROM backend_start)::integer) || '.' ||
       to_hex(pid)
FROM pg_stat_activity
where pid=35341;


SELECT to_hex(EXTRACT(EPOCH FROM backend_start)::integer) || '.' ||
       to_hex(pid)
FROM pg_stat_activity
where pid=6383;


postgres=# SELECT to_hex(EXTRACT(EPOCH FROM backend_start)::integer) || '.' ||
postgres-#        to_hex(pid)
postgres-# FROM pg_stat_activity
postgres-# where pid=33080;
   ?column?    
---------------
 584d5fae.8138
(1 row)

postgres=# 
postgres=# SELECT to_hex(EXTRACT(EPOCH FROM backend_start)::integer) || '.' ||
postgres-#        to_hex(pid)
postgres-# FROM pg_stat_activity
postgres-# where pid=35341;
   ?column?    
---------------
 584d5fb0.8a0d
 
 
postgres=# SELECT to_hex(EXTRACT(EPOCH FROM backend_start)::integer) || '.' ||
postgres-#        to_hex(pid)
postgres-# FROM pg_stat_activity
postgres-# where pid=6383;
   ?column?    
---------------
 584d69e7.18ef
(1 row)


# 数据库创建时间： 
SELECT to_timestamp(((6433246529934850987>>32) & (2^32 -1)::bigint)); 
 
 

# pg_dump/pg_dumpall


pg_dump -Fc hongpay --verbose -f hongpay.dump
pg_dump -Fp hongpay --verbose -f hongpay.sql

pg_dumpall -s -f hongpay_metadata.sql 

pg_dump -d dmp -U qcsdmp02 -t tasknode -f tasknode.sql -v
pg_dump -d dmp -U qcsdmp02 -t task_status -f task_status.sql -v  --inserts

pg_dump -d dmp -U qcsdmp02 -s -f qcsdmp02_metadata.sql -v
date;
pg_dump -Fd -f /home/antdb/danghb/dump_qcsdmp02 -j 20  -a -v -d dmp -U qcsdmp02  ;
date


nohup sh dump.sh > dump.log 2>&1 &

pg_dumpall -d dmp -U antdb -s -f dmpall_metadata.sql -v
pg_dumpall -d dmp -U antdb -s -f dmpall_metadata.sql -v


#!/bin/bash

date "+%Y-%m-%d %H:%M:%S" 



# pg_restore
pg_restore -Fd /home/antdb/danghb/dump_qcsdmp02 -j 20  -d dmp -U qcsdmp02 -p 18432 -v -a

# view object
-- all objects
select 
	n.nspname,
	c.relname as "Name",
	CASE c.relkind WHEN 'r' THEN 'table' WHEN 'v' THEN 'view' WHEN 'm' THEN 'materialized view' WHEN 'i' THEN 'index' WHEN 'S' THEN 'sequence' WHEN 's' THEN 'special'	WHEN 'f' THEN 'foreign table' 
		END as "Type",
	c.relpages
from 
	pg_class c,
	pg_namespace n
where 1=1
	and c.relnamespace = n.oid
	and n.nspname like '%user%'
	and c.relname like '%%';

select c.owner,c.Type,count(*)
from
(
select 
	n.nspname as owner,
	c.relname as Name,
	CASE c.relkind WHEN 'r' THEN 'table' WHEN 'v' THEN 'view' WHEN 'm' THEN 'materialized view' WHEN 'i' THEN 'index' WHEN 'S' THEN 'sequence' WHEN 's' THEN 'special'	WHEN 'f' THEN 'foreign table' 
		END as Type,
	c.relpages
from 
	pg_class c,
	pg_namespace n
where 1=1
	and c.relnamespace = n.oid
	and n.nspname like '%ucr_sta%'
	and c.relname like '%%'
) c
group by  c.owner,c.Type
order by  c.owner,c.Type
;
 
-- table
select * 
from pg_tables
where schemaname like '%user%';

-- table column
select 
  n.nspname,
  c.relname,
	a.attname,
	t.typname,
	a.attlen,
	a.attnum,
case a.attnotnull when 't' then 'NOT NULL' when 'f' then 'NULLABLE' end as "IsNotNull",
  s.n_distinct,
  s.avg_width,
  array_to_string(s.most_common_vals, E'\n') as most_common_vals
from 
	pg_class c,
	pg_attribute a,
	pg_type t,
	pg_namespace n,
	pg_stats s
where 1=1
and a.atttypid=t.oid
and c.oid=a.attrelid
and c.relnamespace = n.oid
and s.schemaname=n.nspname
and s.tablename=c.relname
and s.attname=a.attname
and c.relkind = 'r'
and c.relname like '%pgbench_accounts%'
and a.attnum > 0
order by 
  n.nspname,
	c.relname,
	a.attnum;


-- index
select *
from pg_indexes 
where 1=1
and schemaname like '%user%'
and tablename like '%test%';

--- index column 
select
    t.relname as table_name,
    i.relname as index_name,
    ix.indisunique,
    ix.indisprimary,
    array_to_string(array_agg(a.attname), ', ') as column_names    
from
    pg_class t,
    pg_class i,
    pg_index ix,
    pg_attribute a
where 1=1
    and t.oid = ix.indrelid
    and i.oid = ix.indexrelid
    and a.attrelid = t.oid
    and a.attnum = ANY(ix.indkey)
    and t.relkind = 'r'
    and t.relname like 't2%'
group by
    t.relname,
    i.relname,
    ix.indisunique,
    ix.indisprimary
order by
    t.relname,
    i.relname;
    
    
select
    t.relname as table_name,
    i.relname as index_name,
    a.attname as column_names,
    a.attname
from
    pg_class t,
    pg_class i,
    pg_index ix,
    pg_attribute a
where 1=1
    and t.oid = ix.indrelid
    and i.oid = ix.indexrelid
    and a.attrelid = t.oid
    and a.attnum = ANY(ix.indkey)
    and t.relkind = 'r'
    and t.relname like 'test%'
group by
    t.relname,
    i.relname,
    a.attname
order by
    t.relname,
    i.relname; 
    
# pkey
select pg_constraint.conname as pk_name,pg_attribute.attname as colname,pg_type.typname as typename from 
pg_constraint  inner join pg_class 
on pg_constraint.conrelid = pg_class.oid 
inner join pg_attribute on pg_attribute.attrelid = pg_class.oid 
and  pg_attribute.attnum = pg_constraint.conkey[1]
inner join pg_type on pg_type.oid = pg_attribute.atttypid
where pg_class.relname in 
(
'test_case_run'
,'test_case_run_info'
,'test_task_run'
,'test_biz_run'
,'biz_plan_info'
,'biz_sub_type'
,'biz_schedule'
,'proemployee'
,'employee'
,'flownode'
,'sys_para_value'
,'sys_province'
,'reqmatrix'
,'reqmatrixlist'
,'biz_sub_type_cust'
,'biz_type'
,'sys_trade'
,'tasknode'
,'reqmatrixlistrelation'
,'biz_node_cust'
,'biz_status'
,'taskplan'
,'biz_branch'
,'product'
,'modeltype'
,'pro_product'
,'biz_rel_type'
,'biz_plan'
,'biz_sub_type'
,'biz_operate_history'
,'biz_history_info'
,'biz_detail'
,'sys_para_define'
,'task_emp'
)
and pg_constraint.contype='p'
    
SELECT 
 n.nspname,c.relname,pg_size_pretty(pg_relation_size(c.oid)),
 c.relkind, c.reltuples, c.relpages,
 pg_stat_get_live_tuples(c.oid) AS n_live_tup,  
 pg_stat_get_dead_tuples(c.oid) AS n_dead_tup,  
 pg_stat_get_last_vacuum_time(c.oid) AS last_vacuum,  
 pg_stat_get_last_autovacuum_time(c.oid) AS last_autovacuum,  
 pg_stat_get_last_analyze_time(c.oid) AS last_analyze,  
 pg_stat_get_last_autoanalyze_time(c.oid) AS last_autoanalyze
FROM pg_class c,pg_namespace n
WHERE 1=1
and c.relnamespace=n.oid
and c.relkind = 'r'
and c.relname LIKE '%pgbench_accounts%';	
  

		
select 
  n.nspname,
  c.relname,
	a.attname,
	t.typname,
	a.attlen,
	a.attnum,
case a.attnotnull when 't' then 'NOT NULL' when 'f' then 'NULLABLE' end as "IsNotNull",
  s.n_distinct,
  s.avg_width,
  array_to_string(s.most_common_vals, E',') as most_common_vals
from 
	pg_class c,
	pg_attribute a,
	pg_type t,
	pg_namespace n,
	pg_stats s
where 1=1
and a.atttypid=t.oid
and c.oid=a.attrelid
and c.relnamespace = n.oid
and s.schemaname=n.nspname
and s.tablename=c.relname
and s.attname=a.attname
and c.relkind = 'r'
and c.relname like '%pgbench_accounts%'
and a.attnum > 0
order by 
  n.nspname,
	c.relname,
	a.attnum;
	
	
select
    n.nspname,
    t.relname as table_name,
    i.relname as index_name,
    pg_size_pretty(pg_relation_size(i.oid)),
    ix.indisunique,
    array_to_string(array_agg(a.attname), ', ') as column_names
from
    pg_class t,
    pg_class i,
    pg_index ix,
    pg_attribute a,
    pg_namespace n
where 1=1
    and t.oid = ix.indrelid
    and i.oid = ix.indexrelid
    and a.attrelid = t.oid
    and t.relnamespace=n.oid
    and a.attnum = ANY(ix.indkey)
    and t.relkind = 'r'
    and i.relkind = 'i'
    and t.relname like '%pgbench_%'
group by
    n.nspname,
    t.relname,
    i.relname,
    pg_size_pretty(pg_relation_size(i.oid)),
    ix.indisunique
order by
    t.relname,
    i.relname;	       


-- view
select *
from pg_views 
where 1=1
and schemaname like '%user%'
and viewname like '%test%'

-- trigger
select * 
from pg_trigger
where 1=1
and tgname like '%t%'; 

-- function
select 
	n.nspname,
	p.proname,
	pg_get_functiondef(p.oid)
from 
	pg_proc p,
	pg_namespace n
where 1=1
	and p.proowner =n.nspowner
	and p.proname like '%test%'
	and n.nspname like 'user%';


select 
	proname,p.pronamespace,p.proowner,
	pg_get_functiondef(p.oid)
from 
	pg_proc p
where 1=1
	and p.proname like '%test%';


-- plorasql function 
select p.pronamespace::regnamespace,l.lanname,p.proname,p.proargmodes,p.proargnames
from pg_proc p ,pg_language l
where 1=1
and p.prolang=l.oid
and l.lanname='plorasql'
and p.pronamespace::regnamespace::text like 'ucr_sta1';
	
-- constraints

--- using index constraint
select
	t.relname as "TableName",
	c.conname as "ConName",
	case c.contype when 'p' then 'primary key' when 'c' then 'check' when 'f' then 'foreign key' when 'u' then 'unique key' when 't' then 'constraint trigger'when 'x' then 'exclusion'
	end as "ConType",
	idx.relname as "UsingIndex"
from 
	pg_constraint c,
	pg_class t,
	pg_class idx
where 1=1
	and c.conrelid=t.oid
	and t.relkind='r'
	and c.conindid=idx.oid
	and idx.relkind='i'
	--and c.conname like '%test%'
	and t.relname like '%test%';
	
	
--- normal constraint	
select
	t.relname as "TableName",
	c.conname as "ConName",
	case c.contype when 'p' then 'primary key' when 'c' then 'check' when 'f' then 'foreign key' when 'u' then 'unique key' when 't' then 'constraint trigger'when 'x' then 'exclusion'
	end as "ConType"
from 
	pg_constraint c,
	pg_class t 
where 1=1
	and c.conrelid=t.oid
	and t.relkind='r' 
	--and c.conname like '%test%'
	and t.relname like '%test%';	
	

-- tablespace
select * from pg_tablespace;

-- datafile


## db basic information
\echo PostgreSQL 版本:
select version();
\echo 集群节点信息
select * from pgxc_node;
\echo cluster中有哪些数据库
select datname from pg_database;
\l
\echo 数据库启动时间
select pg_postmaster_start_time() as db_start_time;
\echo 数据库运行时间
select date_trunc('second',current_timestamp-pg_postmaster_start_time()) as up_time;
\echo 数据库服务的数据文件
show data_directory ;
\echo 数据库服务的日志文件
show log_directory ;
\echo 列出扩展模块
select * from pg_extension;
\echo 数据库中的schema
\dn 
\echo 每个schema中的 size Top 10 object
\echo Top 10 size table
select 
	tablename,
	pg_size_pretty(pg_relation_size(schemaname||'.'||tablename)) as size
from pg_tables
where 1=1
	and schemaname not in ('pg_catalog','information_schema')
	order by size desc
	limit 10;
\echo Top 10 size index	
select 
	tablename,
	indexname,
	pg_size_pretty(pg_relation_size(schemaname||'.'||indexname)) as size
from pg_indexes
where 1=1
	and schemaname not in ('pg_catalog','information_schema')
	order by size desc
	limit 10
	;	
\echo Top 10 size object		
select 
	n.nspname,c.relname as "Name",
	CASE c.relkind WHEN 'r' THEN 'table' WHEN 'm' THEN 'materialized view' WHEN 'i' THEN 'index' END as "type",
	pg_size_pretty(pg_relation_size(n.nspname||'.'||c.relname)) as size
from 
	pg_class c,
	pg_namespace n
where 1=1
	and c.relnamespace = n.oid
	and c.relkind in ('r','i','m')
	and n.nspowner<>10
	order by size desc
	limit 10
	;		
\echo schema中的对象类别和数量
select a.nspname,a.type,count(*)
from
(
select 
	n.nspname,
	c.relname as "Name",
	CASE c.relkind WHEN 'r' THEN 'table' WHEN 'v' THEN 'view' WHEN 'm' THEN 'materialized view' WHEN 'i' THEN 'index' WHEN 'S' THEN 'sequence' WHEN 's' THEN 'special'	WHEN 'f' THEN 'foreign table' END as "type"
from 
	pg_class c,
	pg_namespace n
where 1=1
	and c.relnamespace = n.oid
	and n.nspowner<>10
union
select 
	n.nspname,
	p.proname,
	'function' as type
from 
	pg_proc p,
	pg_namespace n
where 1=1
	and p.proowner =n.nspowner
	and n.nspowner<>10
) a
group by 
	nspname,
	a.type
order by 
	nspname,
	a.type;
	


-- Oracle兼容 jdbc配置：
jdbc:postgresql://10.78.187.108:5432/postgres?binaryTransfer=False&forceBinary=False&grammar=oracle
set grammar = postgres    or   set grammar = oracle	



# benchmarksql
# v4.1.1
conn=jdbc:postgresql://host200:7432/bmsql?binaryTransfer=False&forceBinary=False&assumeMinServerVersion=9.0
create database bmsql;
\c bmsql
create user bmsql1 superuser;
create schema bmsql1 authorization bmsql1;

./runSQL.sh props.adb2 sqlTableDrops
./runSQL.sh props.adb2 sqlTableCreates
./runSQL.sh props.adb2 sqlTableCopies_100w
./runSQL.sh props.adb2 sqlIndexCreates

./runSQL.sh props.adb sqlTableCreates
./runSQL.sh props.adb sqlTableCopies
./runSQL.sh props.adb sqlIndexCreates
./runSQL.sh props.adb sqlIndexDrops
./runSQL.sh props.adb sqlTableTruncates
./runSQL.sh props.adb sqlTableDrops

./runLoader.sh props.adb numWarehouses 100 fileLocation /tmp/adb/
./runBenchmark.sh  props.adb

2016-10-14 07:21:18,817  INFO - Term-00, 
2016-10-14 07:21:18,817  INFO - Term-00, 
2016-10-14 07:21:18,817  INFO - Term-00, Measured tpmC (NewOrders) = 110.39
2016-10-14 07:21:18,817  INFO - Term-00, Measured tpmTOTAL = 247.19
2016-10-14 07:21:18,817  INFO - Term-00, Session Start     = 2016-10-13 19:06:29
2016-10-14 07:21:18,817  INFO - Term-00, Session End       = 2016-10-14 07:21:18
2016-10-14 07:21:18,817  INFO - Term-00, Transaction Count = 181648

grep "ERROR: current transaction is aborted" 12h.log |wc -l
grep "ERROR: Abort transaction for gxid" 12h.log |wc -l


## lock
SELECT blocked_locks.pid     AS blocked_pid,
         blocked_activity.usename  AS blocked_user,
         blocking_locks.pid     AS blocking_pid,
         blocking_activity.usename AS blocking_user,
         blocked_activity.query    AS blocked_statement,
         blocking_activity.query   AS current_statement_in_blocking_process,
         blocked_activity.application_name AS blocked_application,
         blocking_activity.application_name AS blocking_application
   FROM  pg_catalog.pg_locks         blocked_locks
    JOIN pg_catalog.pg_stat_activity blocked_activity  ON blocked_activity.pid = blocked_locks.pid
    JOIN pg_catalog.pg_locks         blocking_locks 
        ON blocking_locks.locktype = blocked_locks.locktype
        AND blocking_locks.DATABASE IS NOT DISTINCT FROM blocked_locks.DATABASE
        AND blocking_locks.relation IS NOT DISTINCT FROM blocked_locks.relation
        AND blocking_locks.page IS NOT DISTINCT FROM blocked_locks.page
        AND blocking_locks.tuple IS NOT DISTINCT FROM blocked_locks.tuple
        AND blocking_locks.virtualxid IS NOT DISTINCT FROM blocked_locks.virtualxid
        AND blocking_locks.transactionid IS NOT DISTINCT FROM blocked_locks.transactionid
        AND blocking_locks.classid IS NOT DISTINCT FROM blocked_locks.classid
        AND blocking_locks.objid IS NOT DISTINCT FROM blocked_locks.objid
        AND blocking_locks.objsubid IS NOT DISTINCT FROM blocked_locks.objsubid
        AND blocking_locks.pid != blocked_locks.pid
    JOIN pg_catalog.pg_stat_activity blocking_activity ON blocking_activity.pid = blocking_locks.pid
   WHERE NOT blocked_locks.GRANTED;

select c.relname,
       l.mode,
       l.pid,
       l.granted,
       substr(a.query,1,100),
       a.xact_start,
       a.client_addr,
       a.state,
       to_hex(EXTRACT(EPOCH FROM a.backend_start)::integer) || '.' ||
       to_hex(a.pid) as "session_id"
from pg_class c,
     pg_locks l,
     pg_stat_activity a
where c.oid = l.relation
and c.relnamespace >= 2200
and l.pid=a.pid
and c.relname like 'abp_ord%'
; 


select distinct l.relation,l.node_name,
       l.pid,
       l.mode,
       l.granted,
       substr(a.query,1,100),
    --    a.query,
       a.xact_start,
       a.client_addr,
       a.state
from 
     gv_locks l,
     gv_stat_activity a
where 1=1
and l.node_oid=a.node_oid
and l.pid=a.pid
and l.relation like '%tb_settle_toll_error%'
order by 1,2,3
; 

select locktype,relation::regclass,pid,mode,granted
from pg_locks where relation::regclass::text='tablename'


select locktype,relation::regclass,pid,mode,granted
from (select * from gv_locks ) a;


select relation::regclass,pid,count(*)
from pg_locks
group by 1,2;

select relation::regclass,count(*)
from pg_locks
group by 1;
   
## optimization
select
 left(query, 50),
  round(sum(total_time/1000)::numeric, 6)as "sum",
  round((sum(total_time/1000)/sum(calls))::numeric, 6) as average,
  sum(calls) as "count",
  round(100.0*(sum(total_time/tot))::numeric, 2) as percent
from (
  select sum(total_time) as tot
  from pg_stat_statements
) as x, pg_stat_statements
group by query order by sum(total_time) desc limit 10;   

select datname, usename, application_name, client_addr,
             client_hostname, client_port, state_change as end_time,
             state_change-query_start as response_time, query
      from pg_stat_activity where state = 'idle' and waiting = 'f';   
      
      

select datname, usename, application_name, client_addr,
             client_hostname, client_port, state_change as end_time,
             state_change-query_start as response_time, query,wait_event
      from pg_stat_activity where state <>'idle';   
      
      
# sequence 
2.PG序列的应用 
查看当前会话的序列值
SELECT currval('seq_doss') ;
查看下一个序列值
SELECT nextval('seq_doss') ;
查看全局的最后一个序列值
select last_value from person_id_seq;
重置序列值
select setval(seq_name,new_seq_value);
select now(),sequencename,last_value,increment_by from pg_sequences where sequencename in 
alter sequence seq_doss restart with 300000000;

      
      
#  函数属性：
select proname,provolatile,proargtypes,prosrc 
from pg_proc 
where proname like '%mod%' 
order by  proname ,provolatile;

select proname,count(*) 
from pg_proc
group by proname
order by 2 desc;
      
#pgxc_clean
select * from pg_prepared_xacts;

select pg_xact_status(50996670) ;

select pg_xact_status(substr(gid,2)::bigint) from pg_prepared_xacts;

select substr(gid,2) from pg_prepared_xacts;

select 'rollback prepared '''||gid||''';' from pg_prepared_xacts where  to_char(prepared,'yyyy-mm-dd hh24:mi') ='2020-07-17 14:30';

rollback prepared 'T784168121';

rollback prepared T80224196


select transaction,'rollback prepared '''||gid||';',prepared,owner,database
from pg_prepared_xacts;



select 'rollback prepared '''||gid||';'
from pg_prepared_xacts;

连接命令
-v 打印信息
-N 不操作
-a 所有库
-f 强制

先用-v，看状态

./pgxc_clean -U benchmarksql -a  -p 8032 -h localhost1 -v -N

pgxc_clean -v -a -p 15433-U

pgxc_clean -U so1 -d shcrm1  -f -v -a -p 5432 

 
---- gp
--表数据在segment上的分布
select gp_segment_id,count(*) from lineitem   group by gp_segment_id order by 1;   
--查看segment所在主机磁盘剩余
select dfhostname, dfspace,dfdevice from gp_toolkit.gp_disk_free order by dfhostname;    
-- 查看数据倾斜
select * from  gp_toolkit.gp_skew_coefficients;  
-- 当前配置
select * from gp_segment_configuration ;
  
select count(*) from supplier   ;
select pg_size_pretty(pg_relation_size('supplier'));

--tpc-h
RESULTS=$1
DBNAME=$2
USER=$3
PORT=$4

./run_tpch.sh  ./danghb-0519 postgres danghb 7732 > 1.out 2>&1 &

-- gp expend  在现在有





# 
select 'alter table '||schemaname||'.'||tablename||' owner to smart;'--,tablename,schemaname,tableowner
from pg_tables
where 1=1
and schemaname='iot'
and tableowner='postgres';

# 赋权
grant usage on schema bmsql5_ora_fdw to adb_meishan;
grant select on all tables in schema bmsql5_ora_fdw to adb_meishan;
alter default privileges for user bmsql5_ora_fdw in schema bmsql5_ora_fdw grant select on tables to adb_meishan;


--测试磁盘速度
drop table b1;
create table b1 (id int primary key);
insert into b1 select generate_series(1, 100000);
INSERT 0 100000
Time: 757.204 ms
drop table b2;
create table b2 (id int primary key);
insert into b2 select generate_series(1, 1000000);
INSERT 0 1000000
Time: 4981.259 ms (00:04.981)
drop table b3;
create table b3 (id int );
insert into b3 select generate_series(1, 1000000);
INSERT 0 1000000
Time: 3139.900 ms (00:03.140)


#psql  PROMPT1
\set PROMPT1 '(%n@%M:%>) %[%033[00;33m%]%`date +%H:%M:%S`%[%033[00m%] [%[%033[01;31m%]%/%[%[%033[00m%]] > '
\set PROMPT1 '%`date +%H:%M:%S` >'
(bmsql5@[local]:11010) 16:25:44 [bmsql5] > 
\set PROMPT1 '(%n@@%/:%>) `date +%H:%M:%S` %#'


# session
select pid,usename,client_addr,xact_start,wait_event,state,query
from pg_stat_activity 
where state<>'idle';


select  to_hex(EXTRACT(EPOCH FROM a.backend_start)::integer) || '.' ||
       to_hex(a.pid) as "session_id",pid,now()-xact_start as xact_duration,now()-query_start as query_duration,client_addr,wait_event,state,substr(query,1,70)  
from pg_stat_activity  a  
where state<>'idle'  
order by 3 desc;  


select  nodename,application_name,pid,now()-xact_start as xact_duration,now()-query_start as query_duration,client_addr,wait_event,state,substr(query,1,70)  
from all_activity  a  
where state<>'idle' 
and nodename like 'c%' 
order by 3 desc;  

select pid,now()-xact_start as duration,client_addr,wait_event,state,query
from pg_stat_activity 
where 1=1
and state<>'idle'
and client_addr::text like '192.168.15.21%'
order by 2 desc;  



select pid,now()-xact_start as duration,wait_event,state,substr(query,1,50)
from pg_stat_activity 
where state<>'idle';

# get function cursor out
begin;
select AP_LAST_FREEZING_REVIEW('2018','12','118P9006');

FETCH all in "<unnamed portal 1>";
rollback;

# 表数据分布
select n.node_name,count(*) 
from dr_gprs_731_3_202007 e,pgxc_node n
where e.xc_node_id=n.node_id 
group by 1;


create node dn2_1 with (type='datanode',host='130.10.8.220',port=14551);
create node dn3_1 with (type='datanode',host='130.10.8.221',port=14561);


# haproxy
make PREFIX=/data/antdb/haproxy TARGET=linux2628
make install PREFIX=/data/antdb/haproxy
mkdir -p /data/antdb/haproxy/conf

global
	log 127.0.0.1 local2
	daemon
	maxconn 4000
	pidfile /data/antdb/haproxy/conf/haproxy.pid
defaults
	mode tcp
	retries 5
	log global
	option redispatch
	timeout connect 600s
	timeout client  600s
	timeout server  600s
listen  antdb
bind 0.0.0.0:5432
mode tcp
balance roundrobin
server cd1 197.0.3.166:5432 check
server cd2 197.0.3.167:5432 check
server cd3 197.0.3.168:5432 check
server cd4 197.0.3.169:5432 check

vi /etc/rsyslog.conf
# udp
$ModLoad imudp
$UDPServerRun 514
#haproxy
local2.*                                 /var/log/haproxy.log


haproxy -f /data/antdb/haproxy/conf/haproxy.cfg -sf `cat haproxy.pid`


# plpgsql do
do $$
DECLARE cur record;
begin
    for cur in (select * from t_proc_test where id < 5) loop
        raise notice 'test cursor loop, id is: %s',cur.id;
    end loop;
    for cur in (select * from t_proc_test where id < 5) loop
        raise notice 'test cursor loop, id is: %s',cur.id;
    end loop;
end$$;


# ora_cast
select  castsource::regtype,casttarget::regtype,castfunc::regproc,casttruncfunc::regproc,castcontext from ora_cast order by 1;
select  castsource::regtype,casttarget::regtype,castfunc::regproc,castcontext,castmethod from pg_cast order by 1;


# table without pk
select relname
from pg_class c1
where 1=1
and c1.oid not in (
  select conrelid 
  from pg_constraint c2
  where c2.contype in ('p')
  )
and c1.relkind='r'
and c1.relowner::regrole::text='dmpcs';

# jit test data
CREATE TABLE t_llvm1(a int4, b int4, info text, ctime timestamp(6) without time zone);
INSERT INTO t_llvm1 (a,b,info,ctime) SELECT n,n*2,n||'_llvm1',clock_timestamp() FROM generate_series(1,50000000) n;
EXPLAIN ANALYZE SELECT count(*),sum(a) FROM t_llvm1 WHERE (a+b) > 10;

# psql bind plan
PREPARE q1 (numeric) AS
     select * from reqmatrixlist req where req.biztype = $1;
explain (analyze,verbose) EXECUTE  q1(7);
deallocate q1;


# pg_log
grep -rn -Eo "duration: [0-9.]+" postgresql-2019-11-01_1*.csv | awk -F ':' '{if ($3 > 3000) {print $1, $3;}}'
grep -rn -Eo "duration: [0-9.]+" postgresql-2019-11-01_1*.csv | awk -F ':' '{if ($3 > 30000) {print $0}}'
cat 1 |grep duration|awk -F ',' '{print $14}'|awk '{print $2}'|sort -n|awk '{sum+=$1} END {print sum}'
grep "connect by" postgresql-2019-08-26*.csv|awk -F ',' '{print $14}'|awk -F ':' '{print $2}'|sort |uniq -c|wc -l
grep -E "ERROR|FATAL" postgresql-2020-04-21_16*.csv|awk -F ',' '{print $1,$14,$20}'|more
grep -E "ERROR|FATAL" postgresql-2020-04-21_16*.csv|awk -F ',' '{print $14}'|sort |uniq -c
grep "double get"  postgresql-2020-04-21*.csv|awk -F ',' '{print $9}'|sort |uniq -c

# pg_prewarm
create extension pg_prewarm;
select * from pg_prewarm('tasknode'::regclass);


# gdb
gdb  pg_basebackup
set args -h 10.21.20.17125 -p 52414 -U danghb -D /data/danghb//data/adb40/d1/db6 -Xs -Fp -R --nodename db6 

# wal
SELECT pg_size_pretty(pg_wal_lsn_diff(pg_current_wal_lsn() , lsn)) as lsn_lag,now()-(data::json -> 'timestamp')::text::timestamp as replay_lag
FROM pg_logical_slot_peek_changes('to_ora_116', NULL, 1);
SELECT pg_wal_lsn_diff(pg_current_wal_lsn() , confirmed_flush_lsn)/1024/1024 as sync_lag 
FROM pg_replication_slots  where slot_name = 'to_ora_116';
SELECT pg_size_pretty(pg_current_wal_lsn() - '0/00000000'::pg_lsn);

pg_basebackup -h adb05 -p 6432 -U antdb -D /data/antdb/mgr --nodename mgr -Xs -Fp -R


2019-10-12 17:40:23.413 CST,"qcsdmp02","dmp",2046,"10.21.20.85:58020",5da18505.7fe,43101,"SELECT",2019-10-12 15:47:17 CST,29/10665,0,LOG,00000,"duration: 906464.425 ms",,,,,,,,,"PostgreSQL JDBC Driver"
grep "5da18505.7fe,43100" postgresql-2019-10-12_170530.csv




DECLARE
    V_SQL    VARCHAR2(1000);
    V_FOUND  NUMBER := 0;
BEGIN
    FOR X IN (select TABLE_NAME, COLUMN_NAME
                from dba_tab_columns
               where owner = 'QCSDMP02'
                 and DATA_TYPE = 'NUMBER'
                 and (DATA_SCALE IS NULL or DATA_SCALE >= 18)
                 AND TABLE_NAME not IN (select VIEW_NAME from dba_views)
                 AND TABLE_NAME not IN (select mVIEW_NAME from dba_mviews)
                 AND TABLE_NAME NOT LIKE 'BIN$%'
               order by TABLE_NAME
             )
    LOOP
        V_SQL := 'SELECT COUNT(1) FROM QCSDMP02.'
              || X.TABLE_NAME
              || ' where trunc("'||X.COLUMN_NAME||'", 18) != "'||X.COLUMN_NAME||'"';
        BEGIN
            EXECUTE IMMEDIATE V_SQL INTO V_FOUND;
            IF V_FOUND >= 1
            THEN
                DBMS_OUTPUT.PUT_LINE(RPAD(V_FOUND, 10)||X.TABLE_NAME||'.'||X.COLUMN_NAME);
            END IF;
        EXCEPTION
            WHEN OTHERS
            THEN
                DBMS_OUTPUT.PUT_LINE('Error Check: '||V_SQL);
        END;
    END LOOP;
END;
/

SELECT pg_wal_lsn_diff(pg_current_wal_lsn() , confirmed_flush_lsn)/1024/1024 as sync_lag 
FROM pg_replication_slots  where slot_name = 'to_ora_116';


# alter table 
ALTER TABLE bsw_menu ALTER COLUMN isenabled DROP DEFAULT;
ALTER TABLE bsw_menu ALTER COLUMN isenabled TYPE boolean USING (isenabled::boolean);
ALTER TABLE bsw_menu ALTER COLUMN isenabled set DEFAULT true;



create table t_test (fee varchar, feegroup varchar);
insert into t_test values ('60','10|20|30');
insert into t_test values ('85','15|60');

select fee,
(select sum(col::int) from (SELECT regexp_split_to_table(replace(feegroup,'|',' '),' ') as col) as b) as feegroup_sum
from t_test;


# show_param
drop function show_param;
create or replace function show_param(param text) returns  TABLE (
    name text
   ,setting text
   ,unit text) AS
$$
 select name,setting,unit from pg_settings where name ~  $1;
$$ LANGUAGE 'sql';

