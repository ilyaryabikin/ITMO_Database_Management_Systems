#!/bin/bash
export TERM=xterm
export DB_NAME=dryfish
export ORADATA=/u01/xom10/dryfish
export ORACLE_BASE=/u01/app/oracle

# ASM env
export ORACLE_HOME=/u01/app/11.2.0/grid
export ORACLE_SID=ASM.268925
export PATH="$PATH:/usr/sbin:$ORACLE_HOME/bin"
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$ORACLE_HOME/lib"

# RDBMS env
export ORACLE_HOME=$ORACLE_BASE/product/11.2.0/dbhome_1
export ORACLE_SID=s268925
export PATH="$PATH:/usr/sbin:$ORACLE_HOME/bin"
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$ORACLE_HOME/lib"

# RDBMS init
echo "db_name='$DB_NAME'
db_block_size=8192
sga_target=740M
memory_target=1G
control_files=($ORADATA/control01.ctl, $ORADATA/control02.ctl)
" > $ORACLE_HOME/dbs/init$ORACLE_SID.ora

# ASM init
echo "instance_type=ASM
asm_power_limit=8
_asm_allow_only_raw_disks=false
asm_diskstring=('/u01/crazyelephant/*', '/u01/bravedog/*', '/u01/luckyrabbit/*', '/u01/oldpanda/*', '/u01/sadrat/*', '/u01/richlion/*', '/u01/oldwolf/*')
asm_diskgroups=crazyelephant,bravedog,luckyrabbit,oldpanda,sadrat,richlion,oldwolf
" > $ORACLE_HOME/dbs/init$ORACLE_SID.ora

crsctl status resource
crsctl start res ora.cssd

mkdir /u01/crazyelephant
mkfile -n 500M /u01/crazyelephant/crazyelephant0
mkfile -n 500M /u01/crazyelephant/crazyelephant1
mkfile -n 500M /u01/crazyelephant/crazyelephant2
mkfile -n 500M /u01/crazyelephant/crazyelephant3
mkfile -n 500M /u01/crazyelephant/crazyelephant4
mkfile -n 500M /u01/crazyelephant/crazyelephant5
mkfile -n 500M /u01/crazyelephant/crazyelephant6

mkdir /u01/bravedog
mkfile -n 500M /u01/bravedog/bravedog0
mkfile -n 500M /u01/bravedog/bravedog1
mkfile -n 500M /u01/bravedog/bravedog2
mkfile -n 500M /u01/bravedog/bravedog3
mkfile -n 500M /u01/bravedog/bravedog4
mkfile -n 500M /u01/bravedog/bravedog5

set pagesize 300
column name format a20
column path format a35
select name, path, mount_status from v$asm_disk order by path;

create diskgroup crazyelephant normal redundancy disk
'/u01/crazyelephant/crazyelephant0' name crazyelephant0,
'/u01/crazyelephant/crazyelephant1' name crazyelephant1,
'/u01/crazyelephant/crazyelephant2' name crazyelephant2,
'/u01/crazyelephant/crazyelephant3' name crazyelephant3,
'/u01/crazyelephant/crazyelephant4' name crazyelephant4,
'/u01/crazyelephant/crazyelephant5' name crazyelephant5,
'/u01/crazyelephant/crazyelephant6' name crazyelephant6;

create diskgroup bravedog normal redundancy disk
'/u01/bravedog/bravedog0' name bravedog0,
'/u01/bravedog/bravedog1' name bravedog1,
'/u01/bravedog/bravedog2' name bravedog2,
'/u01/bravedog/bravedog3' name bravedog3,
'/u01/bravedog/bravedog4' name bravedog4,
'/u01/bravedog/bravedog5' name bravedog5;

# Перенос управляющих файлов и файлов данных существующей RDBMS в ASM
startup;
select name from v$datafile;
select name from v$controlfile;
select member from v$logfile;
alter system set control_files='+CRAZYELEPHANT' scope=spfile;
alter system set db_create_file_dest='+CRAZYELEPHANT' scope=spfile;
alter system set db_recovery_file_dest='+CRAZYELEPHANT' scope=spfile;
alter system set db_recovery_file_dest_size=100M scope=spfile;
shutdown immediate;
startup nomount;

rman target /
restore controlfile from '/u01/xom10/dryfish/control01.ctl';
restore controlfile from '/u01/xom10/dryfish/control02.ctl';

alter databse mount;
rman target /
backup as copy database format '+CRAZYELEPHANT';
switch database to copy;

select name from v$tempfile;
rman target /
run
{
set newname for tempfile '/u01/xom10/dryfish/node01/tempts1.dbf' to '+CRAZYELEPHANT';
switch tempfile all;
}

alter database open;
select group#, status from v$log;
set pagesize 300
set linesize 250
column member format a30
select group#, member from v$logfile;
alter database drop logfile group 2;
alter database add logfile group 2 size 10m;
alter system switch logfile;
alter system checkpoint;
alter database drop logfile group 1;
alter database add logfile group 1 size 10m;

# Одной командой удалить дисковую группу bravedog и добавить новую дисковую группу luckyrabbit[3]"; размер AU - 16 М
mkdir /u01/luckyrabbit
mkfile -n 500M /u01/luckyrabbit/luckyrabbit0
mkfile -n 500M /u01/luckyrabbit/luckyrabbit1
mkfile -n 500M /u01/luckyrabbit/luckyrabbit2
drop diskgroup bravedog;
create diskgroup luckyrabbit normal redundancy disk
'/u01/bravedog/bravedog0' name luckyrabbit0,
'/u01/bravedog/bravedog1' name luckyrabbit1,
'/u01/bravedog/bravedog2' name luckyrabbit2
attribute 'au_size'='16M';

# Одной командой удалить дисковую группу luckyrabbit и добавить новую дисковую группу oldpanda[4]"; размер AU - 4 МБ
mkdir /u01/oldpanda
mkfile -n 500M /u01/oldpanda/oldpanda0
mkfile -n 500M /u01/oldpanda/oldpanda1
mkfile -n 500M /u01/oldpanda/oldpanda2
mkfile -n 500M /u01/oldpanda/oldpanda3
drop diskgroup luckyrabbit;
create diskgroup oldpanda normal redundancy disk
'/u01/oldpanda/oldpanda0' name oldpanda0,
'/u01/oldpanda/oldpanda1' name oldpanda1,
'/u01/oldpanda/oldpanda2' name oldpanda2,
'/u01/oldpanda/oldpanda3' name oldpanda3
attribute 'au_size'='4M';

# Добавить новую дисковую группу sadrat[3]"; размер AU - 16 МБ
mkdir /u01/sadrat
mkfile -n 500M /u01/sadrat/sadrat0
mkfile -n 500M /u01/sadrat/sadrat1
mkfile -n 500M /u01/sadrat/sadrat2
create diskgroup sadrat normal redundancy disk
'/u01/sadrat/sadrat0' name sadrat0,
'/u01/sadrat/sadrat1' name sadrat1,
'/u01/sadrat/sadrat2' name sadrat2
attribute 'au_size'='16M';

# Удалить диск #0 из группы sadrat
alter diskgroup sadrat drop disk sadrat0;

# Удалить дисковую группу oldpanda
drop diskgroup oldpanda;

# Добавить новую дисковую группу richlion[4]"; размер AU - 16 МБ
mkdir /u01/richlion
mkfile -n 500M /u01/richlion/richlion0
mkfile -n 500M /u01/richlion/richlion1
mkfile -n 500M /u01/richlion/richlion2
mkfile -n 500M /u01/richlion/richlion3
create diskgroup richlion external redundancy disk
'/u01/richlion/richlion0' name richlion0,
'/u01/richlion/richlion1' name richlion1,
'/u01/richlion/richlion2' name richlion2,
'/u01/richlion/richlion3' name richlion3
attribute 'au_size'='16M';

# Пересоздать группу sadrat, сконфигурировав в ней избыточность следующим образом: Размер группы - 9 элементов; Тип избыточности - HIGH; количество failure-групп - 3; Равномерно распределить диски по failure-группам
mkdir /u01/sadrat
mkfile -n 500M /u01/sadrat/sadrat0
mkfile -n 500M /u01/sadrat/sadrat1
mkfile -n 500M /u01/sadrat/sadrat2
mkfile -n 500M /u01/sadrat/sadrat3
mkfile -n 500M /u01/sadrat/sadrat4
mkfile -n 500M /u01/sadrat/sadrat5
mkfile -n 500M /u01/sadrat/sadrat6
mkfile -n 500M /u01/sadrat/sadrat7
mkfile -n 500M /u01/sadrat/sadrat8
drop diskgroup sadrat;
create diskgroup sadrat high redundancy
failgroup group1 disk
'/u01/sadrat/sadrat0' name sadrat0,
'/u01/sadrat/sadrat1' name sadrat1,
'/u01/sadrat/sadrat2' name sadrat2
failgroup group2 disk
'/u01/sadrat/sadrat3' name sadrat3,
'/u01/sadrat/sadrat4' name sadrat4,
'/u01/sadrat/sadrat5' name sadrat5
failgroup group3 disk
'/u01/sadrat/sadrat6' name sadrat6,
'/u01/sadrat/sadrat7' name sadrat7,
'/u01/sadrat/sadrat8' name sadrat8;

# Добавить новую дисковую группу oldwolf[6]"; размер AU - 1 МБ
mkdir /u01/oldwolf
mkfile -n 500M /u01/oldwolf/oldwolf0
mkfile -n 500M /u01/oldwolf/oldwolf1
mkfile -n 500M /u01/oldwolf/oldwolf2
mkfile -n 500M /u01/oldwolf/oldwolf3
mkfile -n 500M /u01/oldwolf/oldwolf4
mkfile -n 500M /u01/oldwolf/oldwolf5
create diskgroup oldwolf normal redundancy disk
'/u01/oldwolf/oldwolf0' name oldwolf0,
'/u01/oldwolf/oldwolf1' name oldwolf1,
'/u01/oldwolf/oldwolf2' name oldwolf2,
'/u01/oldwolf/oldwolf3' name oldwolf3,
'/u01/oldwolf/oldwolf4' name oldwolf4,
'/u01/oldwolf/oldwolf5' name oldwolf5
attribute 'au_size'='1M';