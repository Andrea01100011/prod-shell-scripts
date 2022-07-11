# prod-shell-scripts
Linux shell scripts in production environment
**简体中文** | [English](README_en.md)

---

# 介绍

分享一些在生产环境中能用得到的一些shell脚本。

# 脚本用途

1. 服务器监控：对服务器的系统负载、CPU、根分区硬盘、交换分区和同时登陆用户数量进行监控，并设置警戒值。当某一项超出警戒值，则向管理员发送邮件告警。

# 环境设置

1. 服务器监控：需要安装sendmail和mailx，并对`/etc/mail.rc`进行配置

# 同一用法

- 首先确保脚本授于执行权限（x权限）：`chmod +x 脚本.sh`
- 直接输入脚本绝对或相对路径以执行脚本：`./脚本.sh`

# 相关链接

- [服务器监控](https://www.ninjacat.cn/2022/07/10/%e7%94%9f%e4%ba%a7%e7%8e%af%e5%a2%83%e4%b8%8b%e5%ae%9e%e7%94%a8%e7%9a%84shell%e8%84%9a%e6%9c%ac%ef%bc%88%e4%b8%80%ef%bc%89/)
