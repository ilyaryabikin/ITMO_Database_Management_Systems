#!/bin/bash

rm -rf /u01/xom10

export TERM=xterm
export ORACLE_BASE=/u01/app/oracle
export ORACLE_HOME=$ORACLE_BASE/product/11.2.0/dbhome_1
export ORACLE_SID=s268925
export NLS_LANG=RUSSIAN_CIS.AL32UTF8
export PATH="$PATH:$ORACLE_HOME/bin"
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$ORACLE_HOME/lib"

export DB_NAME=dryfish

mkdir -p /u01/xom10/$DB_NAME
chown -R oracle:oinstall /u01/xom10
export ORADATA=/u01/xom10/dryfish
mkdir $ORADATA/node01
mkdir $ORADATA/node02
mkdir $ORADATA/node03
mkdir $ORADATA/node04

orapwd file=$ORACLE_HOME/dbs/orapw$ORACLE_SID force=y

echo "db_name='$DB_NAME'
db_block_size=8192
sga_target=740M
memory_target=1G
control_files=($ORADATA/control01.ctl, $ORADATA/control02.ctl)
" > $ORACLE_HOME/dbs/init$ORACLE_SID.ora

echo "CONNECT SYS AS SYSDBA;
CREATE SPFILE FROM PFILE;
STARTUP NOMOUNT;

CREATE DATABASE $DB_NAME
    USER SYS IDENTIFIED BY admin
    USER SYSTEM IDENTIFIED BY admin
LOGFILE GROUP 1 ('$ORADATA/redo01a.log', '$ORADATA/redo01b.log') SIZE 10M,
        GROUP 2 ('$ORADATA/redo02a.log', '$ORADATA/redo02b.log') SIZE 10M
CONTROLFILE REUSE
CHARACTER SET AL32UTF8
NATIONAL CHARACTER SET UTF8
EXTENT MANAGEMENT LOCAL
DATAFILE '$ORADATA/node04/exawi69.dbf' SIZE 10M REUSE AUTOEXTEND ON
SYSAUX DATAFILE '$ORADATA/node01/lez6.dbf' SIZE 10M REUSE AUTOEXTEND ON,
                '$ORADATA/node03/zax62.dbf' SIZE 10M REUSE AUTOEXTEND ON
DEFAULT TABLESPACE users DATAFILE '$ORADATA/node01/eragica970.dbf' SIZE 10M REUSE AUTOEXTEND ON
DEFAULT TEMPORARY TABLESPACE tempts1 TEMPFILE '$ORADATA/node01/tempts1.dbf' SIZE 20M REUSE AUTOEXTEND ON MAXSIZE UNLIMITED
UNDO TABLESPACE undotbs1 DATAFILE '$ORADATA/node01/undotbs1.dbf' SIZE 20M REUSE AUTOEXTEND ON MAXSIZE UNLIMITED;

CREATE TABLESPACE LONG_PINK_NEWS DATAFILE
    '$ORADATA/node02/longpinknews01.dbf' SIZE 10M,
    '$ORADATA/node03/longpinknews02.dbf' SIZE 10M,
    '$ORADATA/node04/longpinknews03.dbf' SIZE 10M,
    '$ORADATA/node02/longpinknews04.dbf' SIZE 10M,
    '$ORADATA/node02/longpinknews05.dbf' SIZE 10M;

CREATE TABLESPACE EVIL_GREEN_LOVE DATAFILE
    '$ORADATA/node01/evilgreenlove01.dbf' SIZE 10M,
    '$ORADATA/node04/evilgreenlove02.dbf' SIZE 10M,
    '$ORADATA/node01/evilgreenlove03.dbf' SIZE 10M;

CREATE TABLESPACE OLD_GREEN_LAKE DATAFILE
    '$ORADATA/node02/oldgreenlake01.dbf' SIZE 10M,
    '$ORADATA/node02/oldgreenlake02.dbf' SIZE 10M,
    '$ORADATA/node04/oldgreenlake03.dbf' SIZE 10M,
    '$ORADATA/node04/oldgreenlake04.dbf' SIZE 10M,
    '$ORADATA/node02/oldgreenlake05.dbf' SIZE 10M;

CREATE TABLESPACE LEFT_WHITE_DATA DATAFILE
    '$ORADATA/node02/leftwhitedata01.dbf' SIZE 10M,
    '$ORADATA/node02/leftwhitedata02.dbf' SIZE 10M;

grant sysdba to sys;
@?/rdbms/admin/catalog.sql
@?/rdbms/admin/catproc.sql
@?/sqlplus/admin/pupbld.sql
" > $ORADATA/script.sql

sqlplus /nolog @$ORADATA/script.sql

echo "База данных $DB_NAME создана"