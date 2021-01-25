#/bin/bash

yum -y install gcc make readline zlib readline-devel zlib-devel
tar -jxvf postgresql-12.0.tar.bz2
cd postgresql-12.0
groupadd postgres
useradd -g postgres postgres
echo "supcon_1304" | passwd --stdin postgres
./configure --prefix=/opt/pg120
gmake world
gmake install-world
chown -R postgres:postgres /opt/pg120/
echo "export PG_HOME=/opt/pg120">> /home/postgres/.bash_profile
echo "export PG_DATA=/opt/pg120/data">> /home/postgres/.bash_profile
echo "export LD_LIBRARY_PATH=$PG_HOME/lib:$LD_LIBRARY_PATH">> /home/postgres/.bash_profile
echo "export PATH=PG_HOME/bin:$PATH">> /home/postgres/.bash_profile
/opt/pg120/bin/initdb -D /opt/pg120/data/ --locale=C --encoding=UTF8
/opt/pg120/bin/pg_ctl -D /opt/pg120/data/ -l /opt/pg120/logfile start
#--创建数据库/用户：
postgres=# create user root superuser;
CREATE ROLE
postgres=# create database root;
CREATE DATABASE
