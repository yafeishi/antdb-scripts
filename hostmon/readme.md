本目录存放运维使用到的一些脚本。

-------
下面的脚本为日常使用：

remote_cmd.sh: 在集群环境、多台主机、主机互信免密的情况下，该脚本可以在一台主机发起命令，在多台主机上执行，非常方便。

remote_scp.sh: 在集群环境、多台主机、主机互信免密的情况下，该脚本可以将本机上一个文件复制到配置的所有主机上。注意:文件需要给定绝对路径。

adb_greplog.sh: 给定关键字、日志目录，输出grep 关键字的结果。

------
下面的需要配合crontab进行。

adb_clean_monitor_data.sh: 删除antdb manage中存放的历史监控数据。

create_barrier.sh: 执行`create barrier`操作，barrerid为当前时间。

delete_archive_file.sh: 删除归档文件。

delete_logfile.sh： 删除antdb各个节点的pg_log目录下的文件，脚本会连接antdb mgr 获取各个节点的信息，通过ssh免密连接到对应主机执行相关操作。

delete_nmonfile.sh:删除nmon采集文件。

drop_cache.sh: 清理内存中的缓存，在内存free小于10G，但是大于5G的时候，执行`drop_caches 2`,在内存free小于5G的时候，执行`drop_caches 3`。


