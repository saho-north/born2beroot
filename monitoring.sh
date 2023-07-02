#!/bin/bash
# Script to monitor the server

# Architecture
# System name, network node's hostname, kernel release information, kernel version, machine hardware name (processor architecture), and name of the OS
system_arch=$(uname -a)

# CPU physical
# Number of physical processors
physical_cpu_count=$(grep -c "physical id" /proc/cpuinfo)

# CPU virtual
# Number of virtual processors
virtual_cpu_count=$(grep -c "processor" /proc/cpuinfo)

# RAM
# Memory usage
memory_info=$(free --mega | awk 'NR==2{print $3, $2}')
ram_use=$(echo "$memory_info" | cut -d' ' -f1)
ram_total=$(echo "$memory_info" | cut -d' ' -f2)
ram_percent=$(echo "scale=2; $ram_use/$ram_total*100" | bc)

# DISK
# Disk usage
disk_info=$(df -m | grep "/dev/" | grep -v -e "/boot" -e "tmpfs")
disk_use=$(echo "$disk_info" | awk '{sum += $3} END {print sum}')
disk_total=$(echo "$disk_info" | awk '{sum += $2} END {print sum}')
disk_percent=$(echo "scale=2; $disk_use/$disk_total*100" | bc)
disk_total=$(echo "scale=0; $disk_total/1024" | bc)

# CPU load
cpu_load=$(top -bn1 | awk '/%Cpu/ {printf("%.1f%%"), $2 + $4}')

# Last boot
last_boot=$(who -b | awk '{print $3, $4}')

# LVM use
lvmu_use=$(if [ $(lsblk | grep -c "lvm") -gt 0 ]; then echo yes; else echo no; fi)

# TCP ESTABLISHED
tcp_count=$(ss -ta | grep -c "ESTAB")

# the number of users using the server
users_count=$(who | wc -l)

# Network
ip=$(hostname -I)
mac=$(ip -o link show | awk '/link\/ether/{print $17}')

# SUDO
cmnd=$(journalctl _COMM=sudo | grep -c COMMAND)

wall "	#Architecture: $system_arch
	#CPU physical: $physical_cpu_count
	#vCPU: $virtual_cpu_count
	#Memory Usage: $ram_use/${ram_total}MB ($ram_percent%)
	#Disk Usage: $disk_use/${disk_total}Gb ($disk_percent%)
	#CPU load: $cpu_load%
	#Last boot: $last_boot
	#LVM use: $lvmu_use
	#Connections TCP: $tcp_count ESTABLISHED
	#User log: $users_count
	#Network: IP $ip ($mac)
	#Sudo: $cmnd cmd"
