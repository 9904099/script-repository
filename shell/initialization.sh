#!/bin/bash

#disable ipv6
cat << EOF
+--------------------------------------------------------------+
| === Disable IPV6 === |
+--------------------------------------------------------------+
EOF
echo "alias net-pf-10 off" >> /etc/modprobe.conf
echo "alias ipv6 off" >> /etc/modprobe.conf
/sbin/chkconfig --level 35 ip6tables off
echo "ipv6 is disabled!"

#disable selinux
sed -i '/SELINUX/s/enforcing/disabled/' /etc/selinux/config
echo "selinux is disabled,you must reboot!"

#vim
sed -i "8 s/^/alias vi='vim'/" /root/.bashrc
echo 'syntax on' > /root/.vimrc

#zh_cn
sed -i -e 's/^LANG=.*/LANG="zh_CN.UTF-8"/' /etc/sysconfig/i18n
# configure file max to 52100
echo "* soft nofile 52100
* hard nofile 52100" >> /etc/security/limits.conf

#tunoff services
#--------------------------------------------------------------------------------
cat << EOF
+--------------------------------------------------------------+
| === Tunoff services === |
+--------------------------------------------------------------+
EOF
#---------------------------------------------------------------------------------
for i in `ls /etc/rc3.d/S*`
do
CURSRV=`echo $i|cut -c 15-`

echo $CURSRV
case $CURSRV in
crond | network | sendmail | sshd | syslog )
#这个启动的系统服务根据具体的应用情况设置，其中network、sshd、syslog是三项必须要启动的系统服务！
echo "Base services, Skip!"

*)
echo "change $CURSRV to off"
chkconfig --level 235 $CURSRV off
service $CURSRV stop

esac
done

mv /etc/sysctl.conf /etc/sysctl.conf.bak
echo "net.ipv4.ip_forward = 0
net.ipv4.conf.default.rp_filter = 1
net.ipv4.conf.default.accept_source_route = 0
kernel.sysrq = 0
kernel.core_uses_pid = 1
net.ipv4.tcp_syncookies = 1
kernel.msgmnb = 65536
kernel.msgmax = 65536
kernel.shmmax = 68719476736
kernel.shmall = 134217728
net.ipv4.ip_local_port_range = 1024 65536
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.ipv4.tcp_rmem = 4096 87380 16777216
net.ipv4.tcp_wmem = 4096 65536 16777216
net.ipv4.tcp_fin_timeout = 3
net.ipv4.tcp_tw_recycle = 1
net.core.netdev_max_backlog = 30000
net.ipv4.tcp_no_metrics_save = 1
net.core.somaxconn = 262144
net.ipv4.tcp_syncookies = 0
net.ipv4.tcp_max_orphans = 262144
net.ipv4.tcp_max_syn_backlog = 262144
net.ipv4.tcp_synack_retries = 2
net.ipv4.tcp_syn_retries = 2
vm.swappiness = 6" >> /etc/sysctl.conf
echo "optimizited kernel configure was done!"