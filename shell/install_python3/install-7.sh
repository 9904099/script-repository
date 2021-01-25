#!/bin/sh
yum -y install zlib-devel bzip2-devel openssl-devel ncurses-devel sqlite-devel readline-devel tk-devel gdbm-devel db4-devel libpcap-devel xz-devel libffi-devel
#wget https://www.python.org/ftp/python/3.7.0/Python-3.7.0.tgz
tar -zxvf Python-3.7.0.tgz
mkdir /usr/local/python3
cd Python-3.7.0
./configure --prefix=/usr/local/python3
make && make install
[ -f /usr/bin/python3 ] && mv /usr/bin/python3 /usr/bin/python3_old
[ -f /usr/bin/pip3 ] && mv /usr/bin/pip3  /usr/bin/pip3_old
ln -s /usr/local/python3/bin/python3.7 /usr/bin/python3
ln -s /usr/local/python3/bin/pip3.7 /usr/bin/pip3
