#!/bin/sh
:<<!
2020-12-14更新，使用方法：
./show-busy-java-threads.sh $JAVA_HOME $PID
!

JAVA_HOME=$1    #/storage/java/jdk1.8.0_241
#DUMP_PIDS=`ps  --no-heading -C java -f --width 1000 |awk '{print $2}'`
DUMP_PIDS=$2
if [ -z "${DUMP_PIDS}" ]; then
    echo "The server ${HOST_NAME} is not started!"
    exit 1;
fi
DUMP_ROOT=./dump
if [ ! -d "${DUMP_ROOT}" ]; then
    mkdir "${DUMP_ROOT}"
fi
DUMP_DATE=$(date +%Y%m%d%H%M%S)
DUMP_DIR="${DUMP_ROOT}/dump-${DUMP_DATE}"
if [ ! -d "${DUMP_DIR}" ]; then
    mkdir "${DUMP_DIR}"
fi
for PID in ${DUMP_PIDS} ; do
#Full thread dump 用来查线程占用，死锁等问题
    if "${JAVA_HOME}/bin/jstack ${PID}" > "${DUMP_DIR}/jstack-${PID}.dump" 2>&1; then
        echo "jstack done"
    fi
#打印出一个给定的Java进程、Java core文件或远程Debug服务器的Java配置信息，具体包括Java系统属性和JVM命令行参数。
    if "$JAVA_HOME/bin/jinfo $PID" > "$DUMP_DIR/jinfo-$PID.dump" 2>&1;then
        echo "jinfo done"
    fi
#jstat能够动态打印jvm(Java Virtual Machine Statistics Monitoring Tool)的相关统计信息。如young gc执行的次数、full gc执行的次数，各个内存分区的空间大小和可使用量等信息。    
    if "$JAVA_HOME/bin/jstat -gcutil $PID" > "$DUMP_DIR/jstat-gcutil-$PID.dump" 2>&1;then
        echo "gcutil done"
    fi
    if "$JAVA_HOME/bin/jstat -gccapacity $PID" > "$DUMP_DIR/jstat-gccapacity-$PID.dump" 2>&1; then
        echo "gccapacity done"
    fi
#未指定选项时，jmap打印共享对象的映射。对每个目标VM加载的共享对象，其起始地址、映射大小及共享对象文件的完整路径将被打印出来，    
    if "${JAVA_HOME}/bin/jmap ${PID}" > "$DUMP_DIR/jmap-$PID.dump" 2>&1; then
        echo "jmap done"
    fi
#-heap打印堆情况的概要信息，包括堆配置，各堆空间的容量、已使用和空闲情况    
    if "$JAVA_HOME/bin/jmap -heap ${PID}" > "$DUMP_DIR/jmap-heap-$PID.dump" 2>&1;then
        echo "jmap_heap done"
    fi
#-dump将jvm的堆中内存信息输出到一个文件中,然后可以通过eclipse memory analyzer进行分析
#注意：这个jmap使用的时候jvm是处在假死状态的，只能在服务瘫痪的时候为了解决问题来使用，否则会造成服务中断。 
#    $JAVA_HOME/bin/jmap -dump:format=b,file=$DUMP_DIR/jmap-dump-$PID.dump $PID 2>&1
    #echo "jmap_dump done"
#显示被进程打开的文件信息
    if [ -r /usr/sbin/lsof ]; then
        if /usr/sbin/lsof -p "${PID}" > "${DUMP_DIR}/lsof-$PID.dump"; then
            echo "lsof done"
        fi
    fi
done
#主要负责收集、汇报与存储系统运行信息的。
if [ -r /usr/bin/sar ]; then
    if /usr/bin/sar > "${DUMP_DIR}/sar.dump";then
        echo "sar done"
    fi
fi
#主要负责收集、汇报与存储系统运行信息的。
if [ -r /usr/bin/uptime ]; then
    if /usr/bin/uptime > "${DUMP_DIR}/uptime.dump";then
        echo "uptime done"
    fi
fi
#内存查看
if [ -r /usr/bin/free ]; then
    if /usr/bin/free -h > "${DUMP_DIR}/free.dump"; then
        echo "free done"
    fi
fi
#可以得到关于进程、内存、内存分页、堵塞IO、traps及CPU活动的信息。
if [ -r /usr/bin/vmstat ]; then
    if /usr/bin/vmstat > "${DUMP_DIR}/vmstat.dump"; then
        echo "vmstat done"
    fi
fi
#报告与CPU相关的一些统计信息
if [ -r /usr/bin/mpstat ]; then
    if /usr/bin/mpstat > "${DUMP_DIR}/mpstat.dump"; then
        echo "mpstat done"
    fi
fi
#报告与IO相关的一些统计信息
if [ -r /usr/bin/iostat ]; then
    if /usr/bin/iostat > "${DUMP_DIR}/iostat.dump"; then
        echo "iostat done"
    fi
fi
#报告与网络相关的一些统计信息
if [ -r /bin/netstat ]; then
    if /bin/netstat > "${DUMP_DIR}/netstat.dump" ; then
        echo "netstat done"
    fi
fi
echo "OK!"
