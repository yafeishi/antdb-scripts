本目录的脚本内容为：    
使用python脚本解析csvlog中的内容，并根据过滤条件入库。
目前的脚本比较简单，每个脚本处理不同的内容。
脚本的运行需要依赖python连接postgres的库：psycopg2,该库的使用可以参考：[《python 连接AntDB进行数据库操作》](https://yafeishi.com/archives/pythonconnectantdb.html)

------

adblog_sqlinfo.py:
从日志中捞出sql的相关信息：

```
postgres=# \d adblog_sqlinfo
             Table "public.adblog_sqlinfo"
   Column    |            Type             | Modifiers 
-------------+-----------------------------+-----------
 nodename    | text                        | 
 logtime     | timestamp without time zone | 
 username    | text                        | 
 dbname      | text                        | 
 connection  | text                        | 
 session_id  | text                        | 
 command_tag | text                        | 
 sqltext     | text                        | 
 param       | text                        | 
 duration    | numeric                     | 
```
然后就可以根据数据进行不同维度的分析。

其中 `adblog_sqlinfo_1min.py` 是 `adblog_sqlinfo.py` 的改进版本，配合使用linux的crontab，可以一分钟执行一次，采集最近一分钟的log内容并入库，入库的表为adblog_sqlinfo_20180208,即当天的表，日表继承自adblog_sqlinfo，所以当天的数据，只入当天的表，这种方式便于对历史数据管理，对N天之前的数据，只需要删除对应的表即可，如下；

```
postgres=# \d+ adblog_sqlinfo
                                 Table "public.adblog_sqlinfo"
   Column    |            Type             | Modifiers | Storage  | Stats target | Description 
-------------+-----------------------------+-----------+----------+--------------+-------------
 nodename    | text                        |           | extended |              | 
 logtime     | timestamp without time zone |           | plain    |              | 
 username    | text                        |           | extended |              | 
 dbname      | text                        |           | extended |              | 
 connection  | text                        |           | extended |              | 
 session_id  | text                        |           | extended |              | 
 command_tag | text                        |           | extended |              | 
 sqltext     | text                        |           | extended |              | 
 param       | text                        |           | extended |              | 
 duration    | numeric                     |           | main     |              | 
Child tables: adblog_sqlinfo_20180205,
              adblog_sqlinfo_20180206,
              adblog_sqlinfo_20180207,
              adblog_sqlinfo_20180208
Has OIDs: no
Distribute By: HASH(nodename)
Location Nodes: ALL DATANODES
```


