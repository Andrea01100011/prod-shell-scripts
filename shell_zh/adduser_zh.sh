#!/bin/bash
# 添加用户，定义其家目录，拷贝默认配置文件，设置密码等
# 适用于linux/Unix系统
pass_file="/etc/passwd" 
shadow_file="/etc/shadow"
group_file="/etc/group"
homedir="/home"

if [ "$(id -un)" != "root" ] ; then
 echo "警告: 需要管理员权限！" >&2
 exit 1
fi

echo "正在向 $(hostname) 添加新用户"
echo -n "login: " ; read login
# 定义uid值不超过5000, 并且按照现有用户中最大的uid的开始递增创建用户的uid
uid="$(awk -F: '{ if (big < $3 && $3 < 5000) big=$3 } END { print big + 1 }' $pass_file)"
homedir=$homedir/$login

# 增加家目录
gid=$uid
echo -n "fullname: " ; read fullname
echo -n "shell: " ; read shell
echo "Setting up account $login for $fullname..."
echo ${login}:x:${uid}:${gid}:${fullname}:${homedir}:$shell >> $pass_file
echo ${login}:*:11647:0:99999:7::: >> $shadow_file
echo "${login}:x:${gid}:$login" >> $group_file
mkdir $homedir
cp -R /etc/skel/.[a-zA-Z]* $homedir
chmod 755 $homedir
chown -R ${login}:${login} $homedir
# 定义初始密码
exec passwd $login