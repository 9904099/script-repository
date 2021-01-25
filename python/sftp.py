# coding: utf-8
 
import paramiko
import re
import os
import sys
from time import sleep
 
class Linux(object):
    # 通过IP, 用户名，密码，超时时间初始化一个远程Linux主机
    def __init__(self, ip, username, password, timeout=3000):
        self.ip = ip
        self.username = username
        self.password = password
        self.timeout = timeout
        self.t = ''
        self.chan = ''
        # 链接失败的重试次数
        self.try_times = 3
 
    # 调用该方法连接远程主机
    def connect(self):
        while True:
            # 连接过程中可能会抛出异常，比如网络不通、链接超时
            try:
                self.t = paramiko.Transport(sock=(self.ip, 22))
                self.t.connect(username=self.username, password=self.password)
                self.chan = self.t.open_session()
                self.chan.settimeout(self.timeout)
                self.chan.get_pty()
                self.chan.invoke_shell()
                # 如果没有抛出异常说明连接成功，直接返回
                print (u'连接%s成功' % self.ip)
                # 接收到的网络数据解码为str
                print (self.chan.recv(65535).decode('utf-8'))
                return
            # 这里不对可能的异常如socket.error, socket.timeout细化，直接一网打尽
            except Exception as e1:
                if self.try_times != 0:
                    print(e1)
                    print (u'连接%s失败，进行重试' %(self.ip))
                    self.try_times -= 1
                else:
                    print (u'重试3次失败，结束程序')
                    exit(1)
 
    # 断开连接
    def close(self):
        self.chan.close()
        self.t.close()
 
    # 发送要执行的命令
    def send(self, cmd):
        cmd += '\r'
        # 通过命令执行提示符来判断命令是否执行完成
        p = re.compile(r'$')
        result = ''
        # 发送要执行的命令
        self.chan.send(cmd)
        # 回显很长的命令可能执行较久，通过循环分批次取回回显
        while True:
            sleep(0.5)
            ret = self.chan.recv(65535)
            ret = ret.decode('utf-8')
            result += ret
            if p.search(ret):
                print (result)
                return result

    # ------获取本地指定目录及其子目录下的所有文件------
    def __get_all_files_in_local_dir(self, local_dir):
        # 保存所有文件的列表
        all_files = list()
 
        # 获取当前指定目录下的所有目录及文件，包含属性值
        files = os.listdir(local_dir)
        for x in files:
            # local_dir目录中每一个文件或目录的完整路径
            filename = os.path.join(local_dir, x)
            # 如果是目录，则递归处理该目录
            if os.path.isdir(x):
                all_files.extend(self.__get_all_files_in_local_dir(filename))
            else:
                all_files.append(filename)
        return all_files
 
    def sftp_put_dir(self, local_dir, remote_dir):
        t = paramiko.Transport(sock=(self.ip, 22))
        t.connect(username=self.username, password=self.password)
        sftp = paramiko.SFTPClient.from_transport(t)
 
        # 去掉路径字符穿最后的字符'/'，如果有的话
        if remote_dir[-1] == '/':
            remote_dir = remote_dir[0:-1]
 
        # 获取本地指定目录及其子目录下的所有文件
        all_files = self.__get_all_files_in_local_dir(local_dir)
        # 依次put每一个文件
        for x in all_files:
            filename = os.path.split(x)[-1]
            remote_filename = remote_dir + '/' + filename
            print('\n')
            print ("From:%s" %(x))
            print ("TO:%s" %(remote_filename))
            print (u'Put文件%s传输到%s中...' % (filename,self.ip))
            sftp.put(x, remote_filename)
if __name__ == '__main__':
    # pwd=os.getcwd()
    # print("本地目录：%s" %(pwd+"/"+sys.argv[1]))
    # print("本地目录：%s" %(sys.argv[2]))
    # remote_path = '%s' %(sys.argv[2])
    # local_path = '%s' %(pwd+"/"+sys.argv[1])
    #传入值拆分，传参
    # host = Linux(sys.argv[3].split(",")[0],sys.argv[3].split(",")[1],sys.argv[3].split(",")[2])

    
    remote_path = r'/home/sup/matter/'
    local_path = r'C:\Users\chenguangzheng\Documents\supcon\svn\运维资料\jenkin_home\python3\aaa'
    host = Linux("10.10.90.195","sup","supcon")

    #host.send('mkdir -p %s' %(remote_path))
    host.sftp_put_dir(local_path, remote_path)
    host.connect()
    host.send('ls -l %s' %(remote_path))
    host.close()
    # # host.sftp_put_dir(local_path, remote_path)
    # hostArr=["%s" %(sys.argv[3])]
#    hostArray=[['185.230.208.244','supcon','Supcon_1304'],['172.16.10.51','root','x1f@2013']]
'''     hostArray=[['192.168.18.111','cloudsigma','Z1a1q1@2020']]
    for x in hostArray:
        host = Linux(x[0], x[1], x[2])
        host.sftp_put_dir(local_path, remote_path)
        host.connect()
        host.send('ls -l %s' %(remote_path))
        host.close() '''
#    host = Linux('192.168.18.111','cloudsigma','Z1a1q1@2020')
