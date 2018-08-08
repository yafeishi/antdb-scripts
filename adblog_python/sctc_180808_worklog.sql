检查toast数量
select relname,reltoastrelid
from pg_class c,
pg_namespace n
where 1=1
and c.relnamespace=n.oid
and n.nspname='dctest'
--and relname ilike '%i_wt_offer_indi_d_tmp_20180804%'
and (c.reltoastrelid is not null and c.reltoastrelid<>0)
and  pg_relation_size(c.reltoastrelid) > 0
order by 1;

(547 rows)  dctest 有547 张表有toastid
但是toast大小大于0的没有。


统计慢SQL：
python adblog_sqlinfo.py cd1 /data2/antdb/data/cd/pg_log   2018-08-08_00000  2018-08-08_105000
python adblog_sqlinfo.py cd2 /data2/antdb/data/cd/pg_log   2018-08-06_00000  2018-08-08_140500
python adblog_sqlinfo.py cd3 /data2/antdb/data/cd/pg_log   2018-08-06_00000  2018-08-08_140500
python adblog_sqlinfo.py cd4 /data2/antdb/data/cd/pg_log   2018-08-06_00000  2018-08-08_140500

psql -d dcrptdb -U dctest

create table adblog_sqlinfo
(
nodename text,    
logtime timestamp,
username text,
dbname text,
connection text,
session_id text,
command_tag text,
sqltext text,
param  text,
duration numeric
)  
;

then execute "copy adblog_sqlinfo from '/data2/antdb/tools/dang/adblog_sqlinfo_cd1_2018-08-08_00000_2018-08-08_105000.csv'  delimiter '^' csv;" to load csv data 

select count(*)
from adblog_sqlinfo
where duration is not null
and sqltext is not null;



个人觉得比较合适的参数设置：
set coordinator all (log_duration = off);
set coordinator all (log_statement=ddl);
set coordinator all (log_min_duration_statement = 50); # 自定
set coordinator all (adb_log_query = on);

首先，要想耗时跟语句打印在一行，则log_statement不能设置为all或者mod，需要设置为ddl或者none。
log_duration不能打开，否则所有的操作都要记录，日志量很大。
adb_log_query=on的时候，execute 阶段的语句会全部打印，不管耗时多少。parse和bind阶段的语句还是受本身log_min_duration_statement参数的影响。
且adb_log_query为on的时候，log_statement 为DDL或者none，否则execute语句会打印两遍。
扩展协议下，parse bind 的日志会比较多。


dcrptdb=# select pg_size_pretty(pg_relation_size('i_wt_offer_indi_d_tmp_20180804'));
 pg_size_pretty 
----------------
 193 GB
(1 row)

dcrptdb=#  select count(*) from i_wt_offer_indi_d_tmp_20180804;
   count   
-----------
 480783205
(1 row)
Time: 498354.096 ms

dcrptdb=# explain (analyze,verbose) select count(*) from i_wt_offer_indi_d_tmp_20180804;    
                                                                                 QUERY PLAN                                                                                  
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 Finalize Aggregate  (cost=3466405.03..3466405.04 rows=1 width=8) (actual time=503027.590..503027.590 rows=1 loops=1)
   Output: count(*)
   ->  Cluster Gather  (cost=3466392.42..3466404.93 rows=40 width=8) (actual time=3191.895..503027.545 rows=48 loops=1)
         Remote node: 16387,16388,16389,16390,360893,360894,360895,360896
         ->  Gather  (cost=3466392.42..3466392.93 rows=5 width=8) (actual time=0.368..0.398 rows=6 loops=1)
               Output: (PARTIAL count(*))
               Workers Planned: 5
               Workers Launched: 5
               Node 360895: (actual time=3191.816..3191.901 rows=6 loops=1)
               Node 16390: (actual time=10176.440..10176.462 rows=6 loops=1)
               Node 16388: (actual time=20089.594..20089.633 rows=6 loops=1)
               Node 360893: (actual time=20359.414..20359.503 rows=6 loops=1)
               Node 16389: (actual time=37774.245..37774.298 rows=6 loops=1)
               Node 360894: (actual time=38723.152..38723.231 rows=6 loops=1)
               Node 360896: (actual time=153248.251..153248.331 rows=6 loops=1)
               Node 16387: (actual time=503024.975..503025.067 rows=6 loops=1)
               ->  Partial Aggregate  (cost=3465392.42..3465392.43 rows=1 width=8) (actual time=0.007..0.007 rows=1 loops=6)
                     Output: PARTIAL count(*)
                     Worker 0: actual time=0.008..0.008 rows=1 loops=1
                     Worker 1: actual time=0.008..0.008 rows=1 loops=1
                     Worker 2: actual time=0.008..0.008 rows=1 loops=1
                     Worker 3: actual time=0.008..0.008 rows=1 loops=1
                     Worker 4: actual time=0.008..0.008 rows=1 loops=1
                     Node 360895: (actual time=3184.980..3184.980 rows=1 loops=6)
                       Worker 0: actual time=3181.928..3181.929 rows=1 loops=1
                       Worker 1: actual time=3181.459..3181.459 rows=1 loops=1
                       Worker 2: actual time=3184.536..3184.536 rows=1 loops=1
                       Worker 3: actual time=3184.441..3184.441 rows=1 loops=1
                       Worker 4: actual time=3185.998..3185.998 rows=1 loops=1
                     Node 16390: (actual time=10170.293..10170.293 rows=1 loops=6)
                       Worker 0: actual time=10166.772..10166.772 rows=1 loops=1
                       Worker 1: actual time=10167.897..10167.898 rows=1 loops=1
                       Worker 2: actual time=10169.134..10169.134 rows=1 loops=1
                       Worker 3: actual time=10170.374..10170.374 rows=1 loops=1
                       Worker 4: actual time=10171.439..10171.440 rows=1 loops=1
                     Node 16388: (actual time=20083.404..20083.404 rows=1 loops=6)
                       Worker 0: actual time=20079.846..20079.846 rows=1 loops=1
                       Worker 1: actual time=20081.489..20081.489 rows=1 loops=1
                       Worker 2: actual time=20082.093..20082.093 rows=1 loops=1
                       Worker 3: actual time=20083.864..20083.864 rows=1 loops=1
                       Worker 4: actual time=20083.867..20083.867 rows=1 loops=1
                     Node 360893: (actual time=20353.549..20353.549 rows=1 loops=6)
                       Worker 0: actual time=20350.019..20350.019 rows=1 loops=1
                       Worker 1: actual time=20351.624..20351.624 rows=1 loops=1
                       Worker 2: actual time=20352.021..20352.022 rows=1 loops=1
                       Worker 3: actual time=20354.113..20354.113 rows=1 loops=1
                       Worker 4: actual time=20354.399..20354.399 rows=1 loops=1
                     Node 16389: (actual time=37768.101..37768.101 rows=1 loops=6)
                       Worker 0: actual time=37764.970..37764.971 rows=1 loops=1
                       Worker 1: actual time=37766.178..37766.178 rows=1 loops=1
                       Worker 2: actual time=37766.386..37766.387 rows=1 loops=1
                       Worker 3: actual time=37768.442..37768.442 rows=1 loops=1
                       Worker 4: actual time=37768.709..37768.709 rows=1 loops=1
                     Node 360894: (actual time=38717.130..38717.130 rows=1 loops=6)
                       Worker 0: actual time=38713.018..38713.018 rows=1 loops=1
                       Worker 1: actual time=38714.132..38714.132 rows=1 loops=1
                       Worker 2: actual time=38716.978..38716.978 rows=1 loops=1
                       Worker 3: actual time=38717.798..38717.798 rows=1 loops=1
                       Worker 4: actual time=38718.012..38718.012 rows=1 loops=1
                     Node 360896: (actual time=153228.902..153228.903 rows=1 loops=6)
                       Worker 0: actual time=153225.227..153225.228 rows=1 loops=1
                       Worker 1: actual time=153225.125..153225.125 rows=1 loops=1
                       Worker 2: actual time=153224.923..153224.923 rows=1 loops=1
                       Worker 3: actual time=153224.918..153224.919 rows=1 loops=1
                       Worker 4: actual time=153225.264..153225.264 rows=1 loops=1
                     Node 16387: (actual time=502965.188..502965.188 rows=1 loops=6)
                       Worker 0: actual time=502953.188..502953.188 rows=1 loops=1
                       Worker 1: actual time=502953.346..502953.346 rows=1 loops=1
                       Worker 2: actual time=502953.296..502953.296 rows=1 loops=1
                       Worker 3: actual time=502953.214..502953.215 rows=1 loops=1
                       Worker 4: actual time=502953.461..502953.461 rows=1 loops=1
                     ->  Parallel Seq Scan on dctest.i_wt_offer_indi_d_tmp_20180804  (cost=0.00..3405291.54 rows=24040354 width=0) (actual time=0.002..0.002 rows=0 loops=6)
                           Remote node: 16387,16388,16389,16390,360893,360894,360895,360896
                           Worker 0: actual time=0.001..0.001 rows=0 loops=1
                           Worker 1: actual time=0.002..0.002 rows=0 loops=1
                           Worker 2: actual time=0.002..0.002 rows=0 loops=1
                           Worker 3: actual time=0.001..0.001 rows=0 loops=1
                           Worker 4: actual time=0.002..0.002 rows=0 loops=1
                           Node 360895: (actual time=114.502..3105.097 rows=902055 loops=6)
                             Worker 0: actual time=111.082..3101.656 rows=905316 loops=1
                             Worker 1: actual time=110.543..3102.401 rows=926737 loops=1
                             Worker 2: actual time=115.084..3104.932 rows=894095 loops=1
                             Worker 3: actual time=115.124..3105.057 rows=867304 loops=1
                             Worker 4: actual time=115.197..3104.460 rows=924717 loops=1
                           Node 16390: (actual time=0.465..9878.559 rows=3460438 loops=6)
                             Worker 0: actual time=0.501..9872.175 rows=3500655 loops=1
                             Worker 1: actual time=0.510..9879.194 rows=3419143 loops=1
                             Worker 2: actual time=0.516..9874.699 rows=3489884 loops=1
                             Worker 3: actual time=0.563..9875.298 rows=3507808 loops=1
                             Worker 4: actual time=0.577..9880.955 rows=3422170 loops=1
                           Node 16388: (actual time=0.464..19551.725 rows=6190990 loops=6)
                             Worker 0: actual time=0.543..19543.164 rows=6291429 loops=1
                             Worker 1: actual time=0.511..19554.641 rows=6159097 loops=1
                             Worker 2: actual time=0.517..19546.139 rows=6296741 loops=1
                             Worker 3: actual time=0.515..19557.366 rows=6028308 loops=1
                             Worker 4: actual time=0.555..19556.589 rows=6165830 loops=1
                           Node 360893: (actual time=0.527..19802.818 rows=6446483 loops=6)
                             Worker 0: actual time=0.850..19803.374 rows=6427989 loops=1
                             Worker 1: actual time=0.556..19796.772 rows=6543039 loops=1
                             Worker 2: actual time=0.518..19799.225 rows=6345856 loops=1
                             Worker 3: actual time=0.534..19805.843 rows=6447706 loops=1
                             Worker 4: actual time=0.566..19799.292 rows=6526153 loops=1
                           Node 16389: (actual time=27.071..36752.495 rows=11781988 loops=6)
                             Worker 0: actual time=24.053..36753.732 rows=11815587 loops=1
                             Worker 1: actual time=25.258..36755.185 rows=11662403 loops=1
                             Worker 2: actual time=25.383..36755.500 rows=11640338 loops=1
                             Worker 3: actual time=27.519..36743.990 rows=11895761 loops=1
                             Worker 4: actual time=27.762..36744.736 rows=11871291 loops=1
                           Node 360894: (actual time=58.314..37974.722 rows=8722615 loops=6)
                             Worker 0: actual time=54.396..37969.877 rows=8736161 loops=1
                             Worker 1: actual time=55.312..37975.647 rows=8665019 loops=1
                             Worker 2: actual time=58.271..37972.039 rows=8759530 loops=1
                             Worker 3: actual time=59.033..37974.554 rows=8753222 loops=1
                             Worker 4: actual time=59.372..37972.557 rows=8802766 loops=1
                           Node 360896: (actual time=12.657..149752.541 rows=39761720 loops=6)
                             Worker 0: actual time=11.921..149739.292 rows=39850052 loops=1
                             Worker 1: actual time=11.838..149743.973 rows=39883497 loops=1
                             Worker 2: actual time=12.000..149761.877 rows=39449158 loops=1
                             Worker 3: actual time=11.997..149748.515 rows=39656557 loops=1
                             Worker 4: actual time=11.912..149726.567 rows=39924346 loops=1
                           Node 16387: (actual time=4.796..502699.295 rows=2864245 loops=6)
                             Worker 0: actual time=5.677..502686.833 rows=2927048 loops=1
                             Worker 1: actual time=5.744..502687.722 rows=2831639 loops=1
                             Worker 2: actual time=5.766..502688.177 rows=2865223 loops=1
                             Worker 3: actual time=5.644..502687.507 rows=2831758 loops=1
                             Worker 4: actual time=5.805..502688.209 rows=2849968 loops=1
 Planning time: 0.151 ms
 Execution time: 503028.494 ms
(128 rows)

Time: 503038.135 ms

select a.org_level3_name,a.zbk_latn_id,b.DATE_NO,'当日销售品解约' as zbname,coalesce(SUM(D_OFFER_LEAV_NUM),0)
from I_DIM_SUB_MG_ORG a left join BM_OFFER_INDI_D b on a.zbk_sub_org_id=b.OFFER_DVLP_CHANNEL_TO_SUB_ORG  
where b.DATE_NO >='20180802' and b.DATE_NO<='20180802'  
group by a.zbk_latn_id,a.org_level3_name,b.DATE_NO 
order by a.zbk_latn_id;

这个sql：(21 rows) Time: 54354.528 ms



sudo yum install -y blktrace
sudo blktrace -d /dev/sdb
sudo blkparse -i sdb -d sdb.blktrace.bin
sudo btt -i sdb.blktrace.bin|more


[adb@pgdn4 /data2/antdb/tools/dang]$ sudo btt -i sdb.blktrace.bin|more
==================== All Devices ====================

            ALL           MIN           AVG           MAX           N
--------------- ------------- ------------- ------------- -----------

Q2Q               0.000000056   0.006855069   0.060262543      168206
Q2G               0.000000370   0.000001118   0.001216107      167850
S2G               0.000083922   0.000716399   0.001215356           6
G2I               0.000000153   0.000001573   0.000269139      167850
Q2M               0.000000242   0.000000559   0.000031989         357
I2D               0.000000264   0.000001133   0.000043994      167850
M2D               0.000000893   0.000069915   0.000229312         357
D2C               0.000023820   0.003009895   0.293356075      168207
Q2C               0.000025599   0.003013860   0.293358481      168207

==================== Device Overhead ====================

       DEV |       Q2G       G2I       Q2M       I2D       D2C
---------- | --------- --------- --------- --------- ---------
 (  8, 16) |   0.0370%   0.0521%   0.0000%   0.0375%  99.8684%
---------- | --------- --------- --------- --------- ---------
   Overall |   0.0370%   0.0521%   0.0000%   0.0375%  99.8684%

==================== Device Merge Information ====================

       DEV |       #Q       #D   Ratio |   BLKmin   BLKavg   BLKmax    Total
---------- | -------- -------- ------- | -------- -------- -------- --------
 (  8, 16) |   168207   167850     1.0 |        8      118      512 19874208

==================== Device Q2Q Seek Information ====================

       DEV |          NSEEKS            MEAN          MEDIAN | MODE           
---------- | --------------- --------------- --------------- | ---------------
 (  8, 16) |          168207    4580357575.8               0 | 0(36050)
---------- | --------------- --------------- --------------- | ---------------
   Overall |          NSEEKS            MEAN          MEDIAN | MODE           
   Average |          168207    4580357575.8               0 | 0(36050)

==================== Device D2D Seek Information ====================

       DEV |          NSEEKS            MEAN          MEDIAN | MODE           
---------- | --------------- --------------- --------------- | ---------------
 (  8, 16) |          167850    4589914418.8               0 | 0(35695)
---------- | --------------- --------------- --------------- | ---------------
   Overall |          NSEEKS            MEAN          MEDIAN | MODE           
   Average |          167850    4589914418.8               0 | 0(35695)

==================== Plug Information ====================

       DEV |    # Plugs # Timer Us  | % Time Q Plugged
---------- | ---------- ----------  | ----------------
 (  8, 16) |     121156(         0) |   0.011871220%

       DEV |    IOs/Unp   IOs/Unp(to)
---------- | ----------   ----------
 (  8, 16) |        1.0          0.0
---------- | ----------   ----------
   Overall |    IOs/Unp   IOs/Unp(to)
   Average |        1.0          0.0

==================== Active Requests At Q Information ====================

       DEV |  Avg Reqs @ Q
---------- | -------------
 (  8, 16) |           0.2

==================== I/O Active Period Information ====================

       DEV |     # Live      Avg. Act     Avg. !Act % Live
---------- | ---------- ------------- ------------- ------
 (  8, 16) |     104455   0.004267004   0.006771918  38.65
---------- | ---------- ------------- ------------- ------
 Total Sys |     104455   0.004267004   0.006771918  38.65

# Total System
#     Total System : q activity
  0.000000495   0.0
  0.000000495   0.4
1153.063728161   0.4
1153.063728161   0.0

#     Total System : c activity
  0.004062041   0.5
  0.004062041   0.9
1153.063762374   0.9
1153.063762374   0.5


[adb@pgdn3 /data2/antdb/tools/dang]$ sudo btt -i sdb.blktrace.bin|more
==================== All Devices ====================

            ALL           MIN           AVG           MAX           N
--------------- ------------- ------------- ------------- -----------

Q2Q               0.000000067   0.006769612   0.083953926       58229
Q2G               0.000000375   0.000001260   0.001764698       58097
S2G               0.000016965   0.000407820   0.001764273          38
G2I               0.000000173   0.000001872   0.000157635       58097
Q2M               0.000000246   0.000000511   0.000001534         133
I2D               0.000000271   0.000001151   0.000038229       58097
M2D               0.000001743   0.000063087   0.000124829         133
D2C               0.000024985   0.001280517   0.058683294       58230
Q2C               0.000026332   0.001284935   0.058685743       58230

==================== Device Overhead ====================

       DEV |       Q2G       G2I       Q2M       I2D       D2C
---------- | --------- --------- --------- --------- ---------
 (  8, 16) |   0.0978%   0.1454%   0.0001%   0.0894%  99.6561%
---------- | --------- --------- --------- --------- ---------
   Overall |   0.0978%   0.1454%   0.0001%   0.0894%  99.6561%

==================== Device Merge Information ====================

       DEV |       #Q       #D   Ratio |   BLKmin   BLKavg   BLKmax    Total
---------- | -------- -------- ------- | -------- -------- -------- --------
 (  8, 16) |    58230    58097     1.0 |        1      178      512 10379658

==================== Device Q2Q Seek Information ====================

       DEV |          NSEEKS            MEAN          MEDIAN | MODE           
---------- | --------------- --------------- --------------- | ---------------
 (  8, 16) |           58230    3875854164.5               0 | 16(6932)
---------- | --------------- --------------- --------------- | ---------------
   Overall |          NSEEKS            MEAN          MEDIAN | MODE           
   Average |           58230    3875854164.5               0 | 16(6932)

==================== Device D2D Seek Information ====================

       DEV |          NSEEKS            MEAN          MEDIAN | MODE           
---------- | --------------- --------------- --------------- | ---------------
 (  8, 16) |           58097    3884037750.4               0 | 16(6934)
---------- | --------------- --------------- --------------- | ---------------
   Overall |          NSEEKS            MEAN          MEDIAN | MODE           
   Average |           58097    3884037750.4               0 | 16(6934)

==================== Plug Information ====================

       DEV |    # Plugs # Timer Us  | % Time Q Plugged
---------- | ---------- ----------  | ----------------
 (  8, 16) |      19608(         0) |   0.013683272%

       DEV |    IOs/Unp   IOs/Unp(to)
---------- | ----------   ----------
 (  8, 16) |        1.2          0.0
---------- | ----------   ----------
   Overall |    IOs/Unp   IOs/Unp(to)
   Average |        1.2          0.0

==================== Active Requests At Q Information ====================

       DEV |  Avg Reqs @ Q
---------- | -------------
 (  8, 16) |           0.2

==================== I/O Active Period Information ====================

       DEV |     # Live      Avg. Act     Avg. !Act % Live
---------- | ---------- ------------- ------------- ------
 (  8, 16) |      24395   0.001860861   0.014298273  11.52
---------- | ---------- ------------- ------------- ------
 Total Sys |      24395   0.001860861   0.014298273  11.52

# Total System
#     Total System : q activity
  0.000000652   0.0
  0.000000652   0.4
394.187740060   0.4
394.187740060   0.0

#     Total System : c activity
  0.000075765   0.5
  0.000075765   0.9
394.187797274   0.9
394.187797274   0.5

drop table BM_C_SERV_INDI_D_ZBK_MONTH_NO_201808_DATE_NO_20180806_tmp;
create table if not exists BM_C_SERV_INDI_D_ZBK_MONTH_NO_201808_DATE_NO_20180806_tmp as 
 select
LATN_ID,
I_WT_C_SERV_INDI_D.UN_OFFER_FLAG,
I_WT_C_SERV_INDI_D.PAYMENT_MODE_CD,
I_WT_C_SERV_INDI_D.BUSI_TYPE_ID,
I_WT_C_SERV_INDI_D.AREA_ID,
I_WT_C_SERV_INDI_D.LOST_TYPE_ID,
STOP_TYPE,
I_WT_C_SERV_INDI_D.GIS_ORG_ID,
I_WT_C_SERV_INDI_D.GIS_ORG_URBAN_RURAL_ID,
I_WT_C_SERV_INDI_D.GIS_SUB_ORG_ID,
DVLP_CHANNEL_ID,
I_WT_C_SERV_INDI_D.DVLP_CHANNEL_TO_SUB_ORG,
DVLP_SUB_URBAN_RURAL_ID,
I_WT_C_SERV_INDI_D.DVLP_CHANNEL_TYPE_ID,
I_WT_C_SERV_INDI_D.CO_CHANNEL_TYPE_ID,
DVLP_CHANNEL_FORM_ID,
I_WT_C_SERV_INDI_D.DVLP_CHANNEL_DISTINCT_BUSI_CD,
I_WT_C_SERV_INDI_D.DVLP_CHANNEL_OPERATE_TYPE,
to_number(SUB_ORG_ID,
'9999999999') as SUB_ORG_ID,
SUB_ORG_URBAN_RURAL_ID,
CO_CHANNEL_ID,
I_WT_C_SERV_INDI_D.CO_CHANNEL_TO_SUB_ORG,
I_WT_C_SERV_INDI_D.CO_SUB_URBAN_RURAL_ID,
I_WT_C_SERV_INDI_D.CO_CHANNEL_FORM_ID,
I_WT_C_SERV_INDI_D.CO_CHANNEL_DISTINCT_BUSI_CD,
I_WT_C_SERV_INDI_D.CO_CHANNEL_OPERATE_TYPE,
I_WT_C_SERV_INDI_D.SERVICE_AGE,
EXISTS_TYPE_ID,
I_WT_C_SERV_INDI_D.SERV_ZWXX_STAFF_FLAG,
I_WT_C_SERV_INDI_D.KD_LD_C_FLAG,
I_WT_C_SERV_INDI_D.IS_SEC_FLAG,
I_WT_C_SERV_INDI_D.NO_VALUE_FLAG,
I_WT_C_SERV_INDI_D.IS_WX_FLAG,
I_WT_C_SERV_INDI_D.IS_WXZJ_FLAG,
I_WT_C_SERV_INDI_D.CHARGE_CARD_FLAG,
ZHUFU_TYPE,
I_WT_C_SERV_INDI_D.CO_NO_VALUE_FLAG,
I_WT_C_SERV_INDI_D.M_SERV_SIGN_GROUP_LV1_ID,
I_WT_C_SERV_INDI_D.M_SERV_SIGN_GROUP_LV2_ID,
I_WT_C_SERV_INDI_D.M_SERV_SIGN_GROUP_LV3_ID,
I_WT_C_SERV_INDI_D.M_SERV_SIGN_GROUP_LV4_ID,
I_WT_C_SERV_INDI_D.SING_COMP_FLAG,
I_WT_C_SERV_INDI_D.M_SERV_SIGN_GROUP_ID,
I_WT_C_SERV_INDI_D.M_SERV_SIGN_OFFER_SPEC_ID,
I_WT_C_SERV_INDI_D.M_SERV_SIGN_GRADE,
I_WT_C_SERV_INDI_D.M_SERV_LEAV_GROUP_LV1_ID,
I_WT_C_SERV_INDI_D.M_SERV_LEAV_GROUP_LV2_ID,
I_WT_C_SERV_INDI_D.M_SERV_LEAV_GROUP_LV3_ID,
I_WT_C_SERV_INDI_D.M_SERV_LEAV_GROUP_LV4_ID,
I_WT_C_SERV_INDI_D.LEAV_COMP_FLAG,
I_WT_C_SERV_INDI_D.M_SERV_LEAV_GROUP_ID,
I_WT_C_SERV_INDI_D.M_SERV_LEAV_OFFER_SPEC_ID,
I_WT_C_SERV_INDI_D.M_SERV_LEAV_GRADE,
I_WT_C_SERV_INDI_D.M_SERV_ARR_GROUP_LV1_ID,
I_WT_C_SERV_INDI_D.M_SERV_ARR_GROUP_LV2_ID,
I_WT_C_SERV_INDI_D.M_SERV_ARR_GROUP_LV3_ID,
I_WT_C_SERV_INDI_D.M_SERV_ARR_GROUP_LV4_ID,
I_WT_C_SERV_INDI_D.ARR_COMP_FLAG,
I_WT_C_SERV_INDI_D.M_SERV_ARR_GROUP_ID,
I_WT_C_SERV_INDI_D.M_SERV_ARR_OFFER_SPEC_ID,
I_WT_C_SERV_INDI_D.M_SERV_ARR_GRADE,
I_WT_C_SERV_INDI_D.HHR_DVLP_FLAG,
sum( D_TY_LOST_SERV_NUM) as D_TY_LOST_SERV_NUM,
sum( D_TY_STOP_SERV_NUM) as D_TY_STOP_SERV_NUM,
sum( D_TY_INC_SERV_NUM) as D_TY_INC_SERV_NUM,
sum( D_TY_UN_INC_SERV_NUM) as D_TY_UN_INC_SERV_NUM,
sum( D_C_INC_SERV_NUM) as D_C_INC_SERV_NUM,
sum( D_TY_SACLE_SERV_NUM) as D_TY_SACLE_SERV_NUM,
sum( D_TY_VALUE_SERV_NUM) as D_TY_VALUE_SERV_NUM,
sum( D_TY_ARR_SERV_NUM) as D_TY_ARR_SERV_NUM,
sum( D_TY_NET_SERV_NUM) as D_TY_NET_SERV_NUM, 
'201808' as ZBK_MONTH_NO ,
'20180806' as DATE_NO
from
dctest.I_WT_C_SERV_INDI_D
where
date_no = '20180806'
group by
LATN_ID,
UN_OFFER_FLAG,
PAYMENT_MODE_CD,
BUSI_TYPE_ID,
AREA_ID,
LOST_TYPE_ID,
STOP_TYPE,
GIS_ORG_ID,
GIS_ORG_URBAN_RURAL_ID,
GIS_SUB_ORG_ID,
DVLP_CHANNEL_ID,
DVLP_CHANNEL_TO_SUB_ORG,
DVLP_SUB_URBAN_RURAL_ID,
DVLP_CHANNEL_TYPE_ID,
CO_CHANNEL_TYPE_ID,
DVLP_CHANNEL_FORM_ID,
DVLP_CHANNEL_DISTINCT_BUSI_CD,
DVLP_CHANNEL_OPERATE_TYPE,
to_number(SUB_ORG_ID,
'9999999999'),
SUB_ORG_URBAN_RURAL_ID,
CO_CHANNEL_ID,
CO_CHANNEL_TO_SUB_ORG,
CO_SUB_URBAN_RURAL_ID,
CO_CHANNEL_FORM_ID,
CO_CHANNEL_DISTINCT_BUSI_CD,
CO_CHANNEL_OPERATE_TYPE,
SERVICE_AGE,
EXISTS_TYPE_ID,
SERV_ZWXX_STAFF_FLAG,
KD_LD_C_FLAG,
IS_SEC_FLAG,
NO_VALUE_FLAG,
IS_WX_FLAG,
IS_WXZJ_FLAG,
CHARGE_CARD_FLAG,
ZHUFU_TYPE,
CO_NO_VALUE_FLAG,
M_SERV_SIGN_GROUP_LV1_ID,
M_SERV_SIGN_GROUP_LV2_ID,
M_SERV_SIGN_GROUP_LV3_ID,
M_SERV_SIGN_GROUP_LV4_ID,
SING_COMP_FLAG,
M_SERV_SIGN_GROUP_ID,
M_SERV_SIGN_OFFER_SPEC_ID,
M_SERV_SIGN_GRADE,
M_SERV_LEAV_GROUP_LV1_ID,
M_SERV_LEAV_GROUP_LV2_ID,
M_SERV_LEAV_GROUP_LV3_ID,
M_SERV_LEAV_GROUP_LV4_ID,
LEAV_COMP_FLAG,
M_SERV_LEAV_GROUP_ID,
M_SERV_LEAV_OFFER_SPEC_ID,
M_SERV_LEAV_GRADE,
M_SERV_ARR_GROUP_LV1_ID,
M_SERV_ARR_GROUP_LV2_ID,
M_SERV_ARR_GROUP_LV3_ID,
M_SERV_ARR_GROUP_LV4_ID,
ARR_COMP_FLAG,
M_SERV_ARR_GROUP_ID,
M_SERV_ARR_OFFER_SPEC_ID,
M_SERV_ARR_GRADE,
HHR_DVLP_FLAG ;


6亿数据，group by 结果是 2659 万  耗时 17688.068 secs


postgres 11337 40398 31 16:45 ?        00:05:52 postgres: itete etedb pgdn6(53499 #local process port) REMOTE SUBPLAN (cd247:29301 #remote cn pid) (D:dn245:12384)

postgres 11337 40398 41 16:45 ?        00:10:54 postgres: itete etedb pgdn6(53499) REMOTE SUBPLAN (cd247:29301) (D:dn245:12384)
postgres 12384 40398  0 16:50 ?        00:00:01 postgres: itete etedb pgdn8(4707) REMOTE SUBPLAN (cd247:29301) (C:cd247:29301)



fio -filename=/data2/antdb/tools/dang/fiodata/test -direct=1 -iodepth=100 -thread -rw=randread -ioengine=psync -bs=8k -size=100G -numjobs=20 -runtime=100 -group_reporting -name=randread  > randread_100s.log				
fio -filename=/data2/antdb/tools/dang/fiodata/test  -direct=1 -iodepth=100 -thread -rw=read -ioengine=psync -bs=8k -size=100G -numjobs=20 -runtime=100 -group_reporting -name=seq_read	> seq_read_100s.log			 		
fio -filename=/data2/antdb/tools/dang/fiodata/test  -direct=1 -iodepth=100 -thread -rw=write -ioengine=psync -bs=8k -size=100G -numjobs=20 -runtime=100 -group_reporting -name=seq_write > seq_write_100s.log						
fio -filename=/data2/antdb/tools/dang/fiodata/test  -direct=1 -iodepth=100 -thread -rw=randwrite -ioengine=psync -bs=8k -size=100G -numjobs=20 -runtime=100 -group_reporting -name=randwrite > randwrite_100s.log						
fio -filename=/data2/antdb/tools/dang/fiodata/test  -direct=1 -iodepth=100 -thread -rw=randrw -rwmixwrite=30 -ioengine=psync -bs=8k -size=100G -numjobs=20 -runtime=100 -group_reporting -name=randrw_w30 > randrw_w30_100s.log						
fio -filename=/data2/antdb/tools/dang/fiodata/test  -direct=1 -iodepth=100 -thread -rw=randrw -rwmixwrite=70 -ioengine=psync -bs=8k -size=100G -numjobs=20 -runtime=100 -group_reporting -name=randrw_w70 > randrw_w70_100s.log						
