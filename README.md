本项目是一个允许多用户 RDP 登录的 linux 图形界面，用作局域网的图形终端（省去创建多个 Windows 主机）。
本项目基于 github [danielguerra/ubuntu-xrdp](https://github.com/danielguerra69/ubuntu-xrdp) 项目。
该项目已经内置了一些维护常用的工具，用户可以根据实际需求自行增加。

## 启动镜像

```bash
# 指定数据目录
DATADIR=/data/ops-desktop

# 创建数据目录
mkdir -p ${DATADIR}/{home,bin}

# 创建初始化用户（echo 内容参考下文说明）
echo 'xxx' >> ${DATADIR}/users.list

# 启动容器
# --shm-size 1g --cap-add=SYS_ADMIN，Chrome 需要用到
# /usr/local/bin 给用户自己挂载额外的命令
# /etc/ssh 保存 ssh 信息
docker run -d --name xrdp --hostname ops-desktop --restart=always --shm-size 1g --cap-add=SYS_ADMIN -p 3389:3389 -p 2222:22 -v ${DATADIR}/home:/home -v ${DATADIR}/users.list:/etc/users.list -v ${DATADIR}/bin:/usr/local/bin -v ${DATADIR}/ssh:/etc/ssh alvinleee/xrdp-desktop:v1
```

## 用户初始化文件

```
# users.list 文件示例
id username password-hash list-of-supplemental-groups
999 ubuntu $6$9DorSQJl$7/vYvQlX6qfyLEbehwX9NNmEsL0MsQCCY3ZGueQE5juFP.Jqp1XtBx3fR5pp5ZXVwOIoRQR7a9VSMOlHVd4sB0 sudo

# 用户密码生成示例
openssl passwd -1 'newpassword'
```

## 其他工具

如：docker、helm、kubectl 等命令的二进制文件直接放到 ${DATADIR}/bin 目录下使用。

## kill_inactive_users.py

用于杀死断开 RDP 连接且 30 分钟内未重新连接的用户的所有进程，避免用户很多时占用资源。