#!/bin/bash
keep_days=$1
find  /data/hostmon/nmon -maxdepth 1 -mtime +$keep_days  -type f \( -name "*.nmon"  \) -exec rm -rf {} \;