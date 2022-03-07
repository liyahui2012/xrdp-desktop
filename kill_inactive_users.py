#!/usr/bin/env python3

import subprocess,threading
import time,re

def command(cmd):
    cmd = cmd.strip().split() if isinstance(cmd, str) else cmd
    return subprocess.Popen(cmd,stdout=subprocess.PIPE,stderr=subprocess.PIPE,encoding='utf-8',text=True)

def get_active_users():
    users = set(x.split()[0] for x in command('ps aux').stdout.read().strip().split('\n')[1:])
    users.remove('root')
    return users

def get_active_sockets():
    xsockets = command('ss -H sport :3389').stdout.readlines()
    ips = [x.strip().split()[-1] for x in xsockets]
    ips = [x.replace('[','').replace(']','') for x in ips]
    return ips

def get_xrdp_events():
    xlog = command('tail -F /var/log/xrdp-sesman.log')
    pattern = re.compile(r'.*\+\+ (?P<action>\w+).*username (?P<username>\w+).*ip (?P<ip>[\.:\w\d]*) .*')
    while True:
        line = xlog.stdout.readline()
        event = re.search(pattern, line)
        if event is not None:
            action, username, ip = event.groups()
            if action in ['created', 'reconnected']:
                active_users.update({username: ip})
            elif action == 'terminated':
                command('pkill -u {}'.format(username))
                if active_users.get(username): active_users.pop(username)
            else:
                pass

def kill_offline_user():
    while True:
        active_sockets = get_active_sockets()
        for username, flag in active_users.copy().items(): # flag 为 ip 或整数，copy 字典防止循环的时候更新字典
            if isinstance(flag, str):
                ip = flag
                if ip not in active_sockets:
                    active_users[username] = 0
                else:
                    pass
            elif isinstance(flag, int):
                count = flag
                if count != 30:         # 超过 30m 杀死当前用户进程
                    active_users[username] += 1
                else:
                    command('pkill -u {}'.format(username))
                    if active_users.get(username): active_users.pop(username)
            else:
                active_users[username] = 0
        time.sleep(60)

def main():
    global active_users
    active_users = {}

    threads = []
    threads.append(threading.Thread(target=get_xrdp_events))
    threads.append(threading.Thread(target=kill_offline_user))

    for t in threads: t.start()
    for t in threads: t.join()

main()
