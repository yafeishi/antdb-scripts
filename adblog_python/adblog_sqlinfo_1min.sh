#!/bin/bash

source /home/adb/.bashrc
python /data/hostmon/adblog_python/adblog_sqlinfo_1min.py coord5 /data/adb/coord/pg_log >> /data/hostmon/adblog_python/log_adblog_sqlinfo_1min.log 2>&1

