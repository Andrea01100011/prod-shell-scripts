#!/bin/bash
# 监控系统负载、CPU、内存、硬盘、用户登录数，超出警戒值发邮件告警

# 获取服务器IP地址信息
IP=$(ifconfig eth0 | grep "inet" | awk 'NR==1{print $2}')
echo "当前服务器IP地址: $IP"

# 获取CPU核数
cpu_num=$(grep -c 'model name' /proc/cpuinfo)
echo "CPU核数: $cpu_num核"

# 获取当前系统15分钟的平均负载值
load_15=$(uptime | awk '{print $NF}')
echo "15分钟平均负载值: $load_15"

# 计算当前系统单个核心15分钟的平均负载值，结果小于1.0时前面个位数补0。
average_load=$(echo "scale=2; $load_15 / $cpu_num " | bc)
if [ 1 -gt $average_load ]; then average_load=$(printf "%.2f" $average_load); fi
echo "单核15分钟平均负载值: $average_load" 

# 取上面平均负载值的个位整数
average_int=$(echo $average_load | cut -d "." -f 1)

# 设置系统单个核心15分钟的平均负载的告警值为0.70(即使用超过70%的时候告警)。
load_warn=0.70

# 当单个核心15分钟的平均负载值大于等于1.0（即个位整数大于0） ，直接发邮件告警；如果小于1.0则进行二次比较
if [ $average_int -gt 0 ]; then
echo "$IP服务器15分钟的系统平均负载为$average_load，超过警戒值1.0，请立即处理！！！" | mail -s "$IP 服务器系统负载严重告警！！！" test@163.com
fi

# 当前系统15分钟平均负载值与告警值进行比较（当大于告警值0.70时会返回1，小于时会返回0 ）
load_now=$(expr $average_load \> $load_warn)

# 如果系统单个核心15分钟的平均负载值大于告警值0.70（返回值为1）, 则发邮件给管理员
if [ $load_now == 1 ]; then
echo "$IP服务器15分钟的系统平均负载达到$average_load，超过警戒值0.70，请及时处理。" | mail -s "$IP 服务器系统负载告警" test@163.com
fi

# 2、监控系统cpu的情况，当使用超过80%的时候发告警邮件：

# 取当前空闲cpu百份比值（只取整数部分）
cpu_idle=$(top -b -n 1 -i -c | grep Cpu | awk '{print $8}' | cut -d "." -f 1)
echo "当前空闲cpu: $cpu_idle%"

# 设置空闲cpu的告警值为20%，如果当前cpu使用超过80%（即剩余小于20%），立即发邮件告警
if [ $cpu_idle -lt 20 ]; then
echo "$IP服务器cpu剩余$cpu_idle%，使用率已经超过80%，请及时处理。" | mail -s "$IP 服务器CPU告警" test@163.com
fi

# 3、监控系统交换分区swap的情况，当使用超过80%的时候发告警邮件：

# 系统分配的交换分区总量
swap_total=$(free -m | grep Swap | awk '{print $2}')
echo "交换分区总量: ""$swap_total""MB"

# 当前剩余的交换分区free大小
swap_free=$(free -m | grep Swap | awk '{print $4}')
echo "剩余交换分区量: ""$swap_total""MB"

# 当前已使用的交换分区used大小
swap_used=$(free -m | grep Swap | awk '{print $3}')

# 如果交换分区已被使用，则计算当前剩余交换分区free所占总量的百分比，用小数来表示，要在小数点前面补一个整数位0
swap_per=$(echo "scale=2; $swap_free/$swap_total" | bc)
if [ $swap_used != 0 ]; then swap_per=$(printf "%.2f" $swap_used); fi
# 设置交换分区的告警值为20%(即使用超过80%的时候告警)。
swap_warn=0.20

# 当前剩余交换分区百分比与告警值进行比较（当大于告警值(即剩余20%以上)时会返回1，小于(即剩余不足20%)时会返回0 ）
swap_now=$(expr $swap_per \> $swap_warn)

# 如果当前交换分区使用超过80%（即剩余小于20%，上面的返回值等于0），立即发邮件告警
if [ $swap_now == 0 ]; then
echo "$IP服务器swap交换分区只剩下 ""$swap_free"" MB 未使用，剩余不足20%，使用率已经超过80%，请及时处理。" | mail -s "$IP 服务器内存告警" test@163.com
fi

# 4、监控系统硬盘根分区使用的情况，当使用超过80%的时候发告警邮件：

# 取当前根分区（/dev/sda3）已用的百份比值（只取整数部分）
disk_total=$(df -h | grep /dev/vda1 | awk '{print $5}' | cut -d "%" -f 1)

# 设置空闲硬盘容量的告警值为80%，如果当前硬盘使用超过80%，立即发邮件告警
if [ $disk_total -gt 80 ]; then
echo "$IP 服务器 /根分区 使用率已经超过80%，请及时处理。" | mail -s "$IP 服务器硬盘告警" test@163.com
fi

# 5、监控系统用户登录的情况，当用户数超过3个的时候发告警邮件：

# 取当前用户登录数（只取数值部分）
users=$(uptime | awk '{print $6}')
echo "当前用户: $users个"

# 设置登录用户数的告警值为3个，如果当前用户数超过3个，立即发邮件告警
if [ $users -ge 3 ]; then
echo "$IP 服务器用户数已经达到$users个，请及时处理。" | mail -s "$IP 服务器用户数告警" test@163.com
fi