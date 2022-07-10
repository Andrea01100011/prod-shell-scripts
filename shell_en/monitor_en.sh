#!/bin/bash
# Monitor the system load, CPU, memory, hard disk, and number of user logins, and send alert emails when the numbers exceed the alarm threshold

# IP address
IP=$(ifconfig eth0 | grep "inet" | awk 'NR==1{print $2}')
echo "IP Add is: $IP"

# number of CPU cores
cpu_num=$(grep -c 'model name' /proc/cpuinfo)
echo "NUM of CPU core(s): $cpu_num"

# the average of system load in 15min
load_15=$(uptime | awk '{print $NF}')
echo "AVG load in 15min: $load_15"

# the average of system load in 15min for each CPU core
average_load=$(echo "scale=2; $load_15 / $cpu_num " | bc)
if [ 1 -gt $average_load ]; then average_load=$(printf "%.2f" $average_load); fi
echo "AVG load in 15min/each core: $average_load" 

# integer number
average_int=$(echo $average_load | cut -d "." -f 1)

# implement trigger when AVG load in 15min exceeds 70%
load_warn=0.70
if [ $average_int -gt 0 ]; then
echo "the AVG load in 15min on server $IP is $average_load, exceeds WARNING VALUE 1.0!!!" | mail -s "$IP system load WARNING!!!" test@163.com
fi

load_now=$(expr $average_load \> $load_warn)
if [ $load_now == 1 ]; then
echo "the AVG load in 15min on server $IP is $average_load, exceeds 70%, CAUTION!" | mail -s "$IP system load WARNING" test@163.com
fi

# 2. CPU monitoring, implement trigger when CPU utilization rate exceeds 80%

# idle cpu in %
cpu_idle=$(top -b -n 1 -i -c | grep Cpu | awk '{print $8}' | cut -d "." -f 1)
echo "current idle cpu: $cpu_idle%"

# sent alert email 
if [ $cpu_idle -lt 20 ]; then
echo "$IP idle cpu is $cpu_idle%, CPU utilization rate exceeds 80%, WARNING!!!" | mail -s "$IP CPU WARNING" test@163.com
fi

# 3. swap monitoring, implement trigger when swap utilization rate exceeds 80%

# swap space basic
swap_total=$(free -m | grep Swap | awk '{print $2}')
echo "total swap space: ""$swap_total""MB"

swap_free=$(free -m | grep Swap | awk '{print $4}')
echo "free swap space: ""$swap_total""MB"

swap_used=$(free -m | grep Swap | awk '{print $3}')
echo "used swap space: ""$swap_used""MB"

swap_per=$(echo "scale=2; $swap_free/$swap_total" | bc)
if [ $swap_used != 0 ]; then swap_per=$(printf "%.2f" $swap_used); fi

# sent alert email
swap_warn=0.20

swap_now=$(expr $swap_per \> $swap_warn)

if [ $swap_now == 0 ]; then
echo "$IP free swap space ""$swap_free"" MB, swap utilization rate exceeds 80%, WARNING!!!" | mail -s "$IP SWAP WARNING" test@163.com
fi

# 4. disk space monitoring on the root partition, implement trigger when disk space utilization rate exceeds 80%

# total root partition(dev/vda1) in %
disk_total=$(df -h | grep /dev/vda1 | awk '{print $5}' | cut -d "%" -f 1)

# sent alert email
if [ $disk_total -gt 80 ]; then
echo "$IP disk space utilization rate exceeds 80%, WARNING!!!" | mail -s "$IP disk space WARNING" test@163.com
fi

# 5. monitoring users, implement trigger when the number of current logged in users exceeds 3

# current use(s)
users=$(uptime | awk '{print $6}')
echo "current user(s): $users"

# sent alert email
if [ $users -ge 3 ]; then
echo "$IP the number of logged in users are $users, WARNING!!!" | mail -s "$IP users WARNING" test@163.com
fi