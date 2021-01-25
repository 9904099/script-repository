import pexpect
from time import sleep
import sys
import time
import logging
from functools import wraps
import traceback
import os

PROMPT = ['# ', '>>> ', '> ', r'\$ ', '~# ','~$']

def send_command(child, cmd):
    child.sendline(cmd)
    child.expect(PROMPT)
    print (child.before, child.after)


def connect(connStr, password):
    ssh_newkey = 'Are you sure you want to continue connecting (yes/no)?'
    connStr = connStr
    child = pexpect.spawn(connStr)
    ret = child.expect(['password:', ssh_newkey])
    if ret == 1:
        child.sendline('yes')
        ret = child.expect('password:')
    if ret != 0:
        print ('[-] Error Connecting')
        return  # THIS WILL RETURN A NONE SO YOU SHOULD CHECK FOR IT.  SHOULD EXPLICITLY DO A return None TO MAKE IT CLEARER
    child.sendline(password)
    child.expect(PROMPT)
    return child

def progress_bar(num):
    for i in range(0, num + 1):
#        j += "#"; k += "="; #s = ("=" * i) + (" " * (num - i))
        
        #print(int(i/num*100), end='%\r')
        #print('%.2f' % (i/num*100), end='%\r')
        #print('%.2f' % (i*100/num), end='%\r')
        print('complete percent:', time.strftime("%Y-%m-%d %H:%M:%S", time.localtime()), int((i/num)*100), end='%\r')
        #print(str(int(i/num*100)) + '% ' + j + '->', end='\r')
        #print(k + ">" + str(int(i/num*100)), end='%\r')
        #print("[%s]" % t[i%4], end='\r')
        #print("[%s][%s][%.2f" % (t[i%4], k, (i/num*100)), "%]", end='\r')
        #print("[%s][%s][%.2f" % (t[i%4], s, (i/num*100)), "%]", end='\r')

        time.sleep(1)

    print()

def main():
    # host = '10.10.90.195'
    # user = 'sup'
    password = 'Supcon_1304'
    connStr='ssh -g -L 41234:185.230.208.244:22 supcon@192.168.18.2'
    #child = connect(user, host, password)
    child = connect(connStr,password)
    if child is not None:
        progress_bar(1800)
        #send_command(child, 'ifocnfig')
    else:
        print ("Problem connecting!")

if __name__ == '__main__':
    main()



ELK Stack:Elasticsearch、Logstash 和 Kibana | Elastic