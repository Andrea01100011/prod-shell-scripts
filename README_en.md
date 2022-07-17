# prod-shell-scripts
生产环境常用shell脚本/Linux shell scripts in production environment
**English** | [简体中文](README.md)

---

# Introduction

Share some shell scripts in production environment.

# Useage

1. server_monitoring: Monitor the system load, CPU, memory, disk space, and number of user logged in, and send alert emails when the numbers exceed the threshold.
2. adduser：add a new user to the system, including building their home directory, copying in default config data, etc.

# Settings

1. server_monitoring: sendmail and mailx need to be installed; and configure file`/etc/mail.rc`

# Usage

- First you need to make sure that your script has the execute permission: `chmod +x script_name.sh`
- Once your script is executable, all you need to do is to type the file name along with its absolute or relative path. Most often you are in the same directory so you just use it like this:`./script_name.sh`

# Links

- [server_monitoring](https://www.ninjacat.cn/2022/07/10/%e7%94%9f%e4%ba%a7%e7%8e%af%e5%a2%83%e4%b8%8b%e5%ae%9e%e7%94%a8%e7%9a%84shell%e8%84%9a%e6%9c%ac%ef%bc%88%e4%b8%80%ef%bc%89/)
