#!/bin/bash
# clean monitor data

source /home/adb/.bashrc

keep_days=$1
mgr_conn="psql -p 6433 -d postgres -h adb01"
clean_cmd="clean monitor $keep_days"

$mgr_conn -c "$clean_cmd"