#!/bin/bash
#定义部署基本信息
source_dir="/home/mysql"
mysql_dir="/usr/local/mysql"
mysql_package="mysql-boost-5.7.30.tar.gz"
mysql_SRC_first=$(echo $mysql_package | sed 's/.tar.gz//g')
mysql_SRC=$(echo $mysql_SRC_first | sed 's/boost-//g')
function init()
{
# close selinux
sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
setenforce 0
# check yes/no x86_64
if [ `uname -m` != "x86_64" ];then
	echo "your system is 32bit ,not install libunwind lib!"
fi
# download depend on the packages 
LANG=C
yum -y install gperftools make cmake gcc gcc-c++ autoconf automake libjpeg libjpeg-devel libpng libpng-devel freetype freetype-devel libxml2 libxml2-devel zlib zlib-devel glibc glibc-devel glib2 glib2-devel bzip2 bzip2-devel ncurses ncurses-devel curl curl-devel e2fsprogs e2fsprogs-devel krb5 krb5-devel libidn libidn-devel openssl openssl-devel openldap openldap-devel nss_ldap openldap-clients openldap-servers pcre pcre-devel
mkdir $log_dir
groupadd mysql && useradd mysql -s /sbin/nologin -g mysql
echo "www and mysql user && group create!"
}
function mysql_install()
{
echo "######## start install mysql ########"
##test yes/no have mysqld/mariadb progress
ps -ef|grep -w mysqld|grep -v "grep" &> /dev/null
if [ $? -eq 0 ];then
	mysqlbasedir=$(ps -ef|grep -w "mysqld"|grep -v "grep"|awk '{print $9}'|tr -d '\-\-')
    mysqldatadir=$(ps -ef|grep -w "mysqld"|grep -v "grep"|awk '{print $10}'|tr -d '\-\-')
fi
rpm -qa | grep mariadb* &> /dev/null
if [ $? -eq 0 ];then
    yum remove mariadb* -y
fi
ls /etc/my.cnf &> /dev/null
if [ $? -eq 0 ];then
    mv /etc/my.cnf /etc/my.cnf.bak
fi
ls /etc/init.d/mysql &> /dev/null
tar zxvf $mysql_package
cd $mysql_SRC
echo "start cmake..."
cmake -DCMAKE_INSTALL_PREFIX=$mysql_dir -DMYSQL_UNIX_ADDR=$mysql_dir/mysql.sock -DSYSCONFDIR=$mysql_dir/etc -DSYSTEMD_PID_DIR=$mysql_dir -DDEFAULT_CHARSET=utf8 -DDEFAULT_COLLATION=utf8_general_ci -DMYSQL_TCP_PORT=3309 -DWITH_INNOBASE_STORAGE_ENGINE=1 -DWITH_ARCHIVE_STORAGE_ENGINE=1 -DWITH_BLACKHOLE_STORAGE_ENGINE=1 -DWITH_PERFSCHEMA_STORAGE_ENGINE=1 -DMYSQL_DATADIR=$mysql_dir/data -DWITH_BOOST=boost -DWITH_SYSTEMD=1 > $log_dir/configure_mysql.log
sleep 1
echo "start make && make install..."
make && make install  
sleep 2
chown -R mysql.mysql $mysql_dir/
cd $mysql_dir/
echo '######create my.cnf######'
if [ ! -s my.cnf ];then
cat >> my.cnf << EOF
[client]                                                #客户端设置
port=3309                                               #服务器监听端口，默认为3306
socket=/usr/local/mysql/tmp/mysql.sock                  #Unix套接字文件路径，默认/tmp/mysql.sock

[mysqld]                                                #服务端设置
## 一般配置选项
port=3309                                               #服务器监听端口，默认为3306
basedir=/usr/local/mysql                                #MySQL安装根目录
datadir=/usr/local/mysql/data                           #MySQL数据文件目录
socket=/usr/local/mysql/tmp/mysql.sock                  #Unix套接字文件路径，默认/tmp/mysql.sock
pid-file=/usr/local/mysql/tmp/mysql.pid                 #服务进程pid文件路径
character_set_server=utf8                               #默认字符集
default_storage_engine=InnoDB                           #默认InnoDB存储引擎
user=mysql

## 连接配置选项
max_connections=200                                     #最大并发连接数
table_open_cache=400                                    #表打开缓存大小，默认2000
open_files_limit=1000                                   #打开文件数限制，默认5000
max_connect_errors=200                                  #最大连接失败数，默认100
back_log=100                                            #请求连接队列数
connect_timeout=20                                      #连接超时时间，默认10秒
interactive_timeout=1200                                #交互式超时时间，默认28800秒
wait_timeout=600                                        #非交互超时时间，默认28800秒
net_read_timeout=30                                     #读取超时时间，默认30秒
net_write_timeout=60                                    #写入超时时间，默认60秒
max_allowed_packet=8M                                   #最大传输数据字节，默认4M
thread_cache_size=10                                    #线程缓冲区（池）大小
thread_stack=256K                                       #线程栈大小，32位平台196608、64位平台262144

## 临时内存配置选项
tmpdir=/tmp                                             #临时目录路径
tmp_table_size=64M                                      #临时表大小，默认16M
max_heap_table_size=64M                                 #最大内存表大小，默认16M
sort_buffer_size=1M                                     #排序缓冲区大小，默认256K
join_buffer_size=1M                                     #join缓冲区大小，默认256K

## Innodb配置选项
#innodb_thread_concurrency=0                                                    #InnoDB线程并发数
innodb_io_capacity=200                                  #IO容量，可用于InnoDB后台任务的每秒I/O操作数（IOPS），
innodb_io_capacity_max=400                              #IO最大容量，InnoDB在这种情况下由后台任务执行的最大IOPS数
innodb_lock_wait_timeout=50                             #InnoDB引擎锁等待超时时间，默认50（单位：秒）

innodb_buffer_pool_size=512M                                                    #InnoDB缓冲池大小，默认128M
innodb_buffer_pool_instances=4                          #InnoDB缓冲池划分区域数
innodb_max_dirty_pages_pct=75                                                   #缓冲池最大允许脏页比例，默认为75
innodb_flush_method=O_DIRECT                            #日志刷新方法，默认为fdatasync
innodb_flush_log_at_trx_commit=2                        #事务日志刷新方式，默认为0
transaction_isolation=REPEATABLE-READ                   #事务隔离级别，默认REPEATABLE-READ

innodb_data_home_dir=/usr/local/mysql/data              #表空间文件路径，默认保存在MySQL的datadir中
innodb_data_file_path=ibdata1:128M:autoextend           #表空间文件大小
innodb_file_per_table=ON                                #每表独立表空间

innodb_log_group_home_dir=/usr/local/mysql/data         #redoLog文件目录，默认保存在MySQL的datadir中
innodb_log_files_in_group=2                             #日志组中的日志文件数，默认为2
innodb_log_file_size=128M                               #日志文件大小，默认为48MB
innodb_log_buffer_size=32M                              #日志缓冲区大小，默认为16MB

## MyISAM配置选项
key_buffer_size=32M                                     #索引缓冲区大小，默认8M
read_buffer_size=4M                                                                        #顺序读缓区冲大小，默认128K
read_rnd_buffer_size=4M                                                                 #随机读缓冲区大小，默认256K
bulk_insert_buffer_size=8M                              #块插入缓冲区大小，默认8M
myisam_sort_buffer_size=8M                                                              #MyISAM排序缓冲大小，默认8M
#myisam_max_sort_file_size=1G                           #MyISAM排序最大临时大小
myisam_repair_threads=1                                 #MyISAM修复线程
skip-external-locking                                   #跳过外部锁定，启用文件锁会影响性能

## 日志配置选项
log_output=FILE                                         #日志输出目标，TABLE（输出到表）、FILE（输出到文件）、NONE（不输出），可选择一个或多个以逗>号分隔
log_error=/usr/local/mysql/logs/error.log               #错误日志存放路径
log_error_verbosity=1                                   #错误日志过滤，允许的值为1（仅错误），2（错误和警告），3（错误、警告和注释），默认值为3。
log_timestamps=SYSTEM                                   #错误日志消息格式，日志中显示时间戳的时区，UTC（默认值）和 SYSTEM（本地系统时区）
general_log=ON                                          #开启查询日志，一般选择不开启，因为查询日志记录很详细，会增大磁盘IO开销，影响性能
general_log_file=/usr/local/mysql/logs/general.log      #通用查询日志存放路径

## 慢查询日志配置选项
slow_query_log=ON                                       #开启慢查询日志
slow_query_log_file=/usr/local/mysql/logs/slowq.log             #慢查询日志存放路径
long_query_time=2                                       #慢查询时间，默认10（单位：秒）
min_examined_row_limit=100                              #最小检查行限制，检索的行数必须达到此值才可被记为慢查询
log_slow_admin_statements=ON                            #记录慢查询管理语句
log_queries_not_using_indexes=ON                        #记录查询未使用索引语句
log_throttle_queries_not_using_indexes=5                #记录未使用索引速率限制，默认为0不限制
log_slow_slave_statements=ON                            #记录从库复制的慢查询，作为从库时生效，从库复制中如果有慢查询也将被记录

## 复制配置选项
server-id=1                                             #MySQL服务唯一标识
log-bin=mysql-bin                                       #开启二进制日志，默认位置是datadir数据目录
log-bin-index=mysql-bin.index                           #binlog索引文件
binlog_format=MIXED                                     #binlog日志格式，分三种：STATEMENT、ROW或MIXED，MySQL 5.7.7之前默认为STATEMENT，之后默认为ROW
binlog_cache_size=1M                                    #binlog缓存大小，默认32KB
max_binlog_cache_size=1G                                #binlog最大缓存大小，推荐最大值为4GB
max_binlog_size=256M                                    #binlog最大文件大小，最小值为4096字节，最大值和默认值为1GB
expire_logs_days=7                                      #binlog过期天数，默认为0不自动删除
log_slave_updates=ON                                    #binlog级联复制
sync_binlog=1                                           #binlog同步频率，0为禁用同步（最佳性能，但可能丢失事务），为1开启同步（影响性能，但最安全不会丢失任何事务），为N操作N次事务后同步1次

relay_log=relay-bin                                     #relaylog文件路径，默认位置是datadir数据目录
relay_log_index=relay-log.index                         #relaylog索引文件
max_relay_log_size=256M                                 #relaylog最大文件大小
relay_log_purge=ON                                      #中继日志自动清除，默认值为1（ON）
relay_log_recovery=ON                                   #中继日志自动恢复

auto_increment_offset=1                                 #自增值偏移量
auto_increment_increment=1                              #自增值自增量
slave_net_timeout=60                                    #从机连接超时时间
replicate-wild-ignore-table=mysql.%                     #复制时忽略的数据库表，告诉从线程不要复制到与给定通配符模式匹配的表
skip-slave-start                                        #跳过Slave启动，Slave复制进程不随MySQL启动而启动

## 其他配置选项
#memlock=ON                                             #开启内存锁，此选项生效需系统支持mlockall()调用，将mysqld进程锁定在内存中，防止遇到操作系统导致mysqld交换到磁盘的问题

[mysqldump]                                             #mysqldump数据库备份工具
quick                                                   #强制mysqldump从服务器查询取得记录直接输出，而不是取得所有记录后将它们缓存到内存中
max_allowed_packet=16M                                  #最大传输数据字节，使用mysqldump工具备份数据库时，某表过大会导致备份失败，需要增大该值（大>于表大小即可）

[myisamchk]                                             #使用myisamchk实用程序可以用来获得有关你的数据库表的统计信息或检查、修复、优化他们
key_buffer_size=32M                                     #索引缓冲区大小
myisam_sort_buffer_size=8M                              #排序缓冲区大小
read_buffer_size=4M                                     #读取缓区冲大小
write_buffer_size=4M  
EOF
else
continue
fi
chown mysql.mysql my.cnf
cp $mysql_dir/support-files/mysql.server  /etc/init.d/mysqld
chmod +x  /etc/init.d/mysqld
echo 'PATH=/usr/local/mysql/bin:/usr/local/mysql/lib:$PATH' >> /etc/profile
echo 'export PATH' >> /etc/profile
source /etc/profile
rm -rf $mysql_dir/data/*
mysqld --initialize-insecure --user=mysql --basedir=/usr/local/mysql --datadir=/usr/local/mysql/data
cp usr/lib/systemd/system/mysqld.service /usr/lib/systemd/system/
systemctl daemon-reload
systemctl start mysqld
systemctl enable mysqld
ps -ef|grep mysql
systemctl status mysqld
echo '######mysql is install completed done.######'
}
init
sleep 1
mysql_install
