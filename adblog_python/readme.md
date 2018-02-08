本目录的脚本内容为：    
使用python脚本解析csvlog中的内容，并根据过滤条件入库。
目前的脚本比较简单，每个脚本处理不同的内容。
脚本的运行需要依赖python连接postgres的库：psycopg2,该库的使用可以参考：[《python 连接AntDB进行数据库操作》](https://yafeishi.com/archives/pythonconnectantdb.html)

涉及到连接实际环境的，请修改连接信息后再使用。

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

采集范围的begintime：上次执行成功的endtime为写入临时文件：/tmp/adblog_sqlinfo_endtime,作为下次执行的begintime。因为是入库成功后才会写这个tmp文件，所以中间如果出错，下次再执行，还是会去最后一次成功执行的时间。

采集范围的endtime：取当前时间。

`del_adblog_sqlinfo.sh` 为删除旧数据并创建明天新表的脚本。根据脚本的第一个参数来决定需要保留多少天的数据。

脚本执行示例在`adblog_python.sh`可以看到。

------

adblog_errlog_1min.py：
从日志中捞取错误日志，过滤条件为csvlog中 `error_severity` 字段值 不等于 `LOG`。
输出内容为：

```
writelogfields = ['nodename', 'log_time', 'user_name', 'database_name', 'connection_from', 'session_id', 'command_tag', 'error_severity', 'message', 'detail','query']
```
------
adblog_connreceived.py：捞出日志中接收连接请求的内容。

adblog_auth.py：捞出日志中授权连接请求的内容。


