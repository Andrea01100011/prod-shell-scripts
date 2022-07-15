#!/bin/bash
# adduser--Adds a new user to the system, including building their
# home directory, copying in default config data, etc.
# For a standard Unix/Linux system.
pass_file="/etc/passwd" 
shadow_file="/etc/shadow"
group_file="/etc/group"
homedir="/home"

if [ "$(id -un)" != "root" ] ; then
 echo "Error: You must be root to run this command." >&2
 exit 1
fi

echo "Add new user account to $(hostname)"
echo -n "login: " ; read login
# The next line sets the highest possible user ID value at 5000,
# but you should adjust this number to match the top end 
# of your user ID range.
uid="$(awk -F: '{ if (big < $3 && $3 < 5000) big=$3 } END { print big + 1 }' $pass_file)"
homedir=$homedir/$login

# give each user their own group.
gid=$uid
echo -n "full name: " ; read fullname
echo -n "shell: " ; read shell
echo "Setting up account $login for $fullname..."
echo ${login}:x:${uid}:${gid}:${fullname}:${homedir}:$shell >> $pass_file
echo ${login}:*:11647:0:99999:7::: >> $shadow_file
echo "${login}:x:${gid}:$login" >> $group_file
mkdir $homedir
cp -R /etc/skel/.[a-zA-Z]* $homedir
chmod 755 $homedir
chown -R ${login}:${login} $homedir
# Setting an initial password
exec passwd $login