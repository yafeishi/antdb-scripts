#!/bin/bash
# find /data/ora2pg/data/shhis/so1 -maxdepth 1 -name "ORD_BUSI_PRICE_F*.sql" -exec ls -lrt {} \;|awk 'BEGIN {sum7=0}{sum7+=$5} END {print sum7/1024/1024/1024}'

sqldir="/data/ora2pg/data/shhis"
owner=$1
type=$2
tablelike=(ORD_BUSI_PRICE_F
ORD_CUST_F ORD_OFFER_F
ORD_OFF_ORD_USER_F
ORD_PROD_F
ORD_PROD_ORD_SRV_F
ORD_SRV_ATTR_F
ORD_USER_F SO_BUSI_LOG
SO_BUSI_LOG_EXT
SO_CHAG_OFFER_RECORD
ORD_USER_EXT_F
ORD_CUST_EXT_F
ORD_DSMP_SWITCH_F
ORD_ACCREL_F
ORD_DTL_INFO_F
ORD_PRICE_ATTR_F
ORD_USER_OS_STATE_F
ORD_OFFER_RELAT_F
INS_ACCREL_H
I_OPEN_RADIUS_H
I_OPEN_RADIUS_IDX_H )


psqlconn="psql -d postgres -U $owner -q -t"


for t in ${tablelike[@]}
do
$psqlconn << EOF
select '$t',schemaname,count(*)
from $type a
where 1=1
and a.schemaname='$owner'
and upper(a.tablename) like '$t%'
group by schemaname;
EOF