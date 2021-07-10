#!/bin/bash

export TERM=xterm
export ORACLE_BASE=/u01/app/oracle
export ORACLE_HOME=$ORACLE_BASE/product/11.2.0/dbhome_1
export ORACLE_SID=s268925
export NLS_LANG=RUSSIAN_CIS.AL32UTF8
export PATH="$PATH:$ORACLE_HOME/bin"
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$ORACLE_HOME/lib"
export DB_NAME=dryfish
export ORADATA=/u01/xom10/dryfish
export DATAPUMP_DIR=$ORADATA/dumps/dpdumps
export DUMPS_DIR=$ORADATA/dumps
export SCRIPTS_DIR=~/ryabikin_scripts

DATE=$(date +"%Y-%m-%d-%H-%M-%S")

expdp system/admin full=y directory=DATAPUMP_DIR dumpfile=dp_${DATE}.dmp logfile=dp_${DATE}.log flashback_time=SYSTIMESTAMP

scp $DATAPUMP_DIR/dp_${DATE}.dmp oracle@db101:$DATAPUMP_DIR

ssh oracle@db101 "$SCRIPTS_DIR/data_pump_imp.sh dp_${DATE}.dmp"