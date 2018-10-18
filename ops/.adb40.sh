~/.adb40.sh

export ADBHOME=${HOME}/app/adb40
export LD_LIBRARY_PATH=${ADBHOME}/lib:$LD_LIBRARY_PATH
export PATH=${ADBHOME}/bin:$PATH
export PGPORT=11010
export PGDATABASE=postgres

export MGR_HOME=${HOME}/data/adb40/d1/mgr
alias adbmgr="psql -d postgres -p 16432"
alias mgr_start="mgr_ctl start -D $MGR_HOME"
alias mgr_stop="mgr_ctl stop -D $MGR_HOME -m fast"