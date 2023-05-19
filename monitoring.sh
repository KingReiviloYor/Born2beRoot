#!/bin/bash
#
# OS Architecture + Kernel version. -a (--all) prints all info in the following order:
# kernel-name, nodename, kernel-release, kernel-version, machine, operating-system
architecture=$(uname -a)
#
# Display number of cpu sockets
cpu=$(lscpu | grep '^Socket' | awk '{print $2}')
#
# Display number of logical cores
vcpu=$(lscpu | grep '^CPU(s)' | awk '{print $2}')
#
# Memory Usage (RAM). The free command displays the amount of free and used memory in the system.
# -m refers to mebibyte (1024 KiB), which is in the binary system. --mega equals 1000 KB.
mem_used=$(free -m | awk 'NR==2 {print $3}')
mem_total=$(free -m | awk 'NR==2 {print $2"MB"}')
mem_percent=$(free -m | awk 'NR==2 {printf("%.2f%%", $3/$2*100)}')
#
# Disk Space Available. -h means human-readable and displays sizes in power of 1024,
# in contrast to -H which displays them in powers of 1000.
disk_used=$(df -h --total | awk 'END {print $3}')
disk_total=$(df -h --total | awk 'END {print $2}')
disk_percent=$(df -h --total | awk 'END {print $5}')
#
# CPU Load. Basically works using the user processes ($2), the system processes ($4) and the idle time ($5).
# This command represents the overall usage on all cores since bootup. The top command is more accurate
# to get the current cpu.
load=$(grep '^cpu' /proc/stat | awk 'END {printf("%.1f%%", ($2+$4)*100/($2+$4+$5))}')
#
# Date and time of last boot. The who command displays who is currently logged in.
last_boot=$(who -b | awk '{print $3, $4}')
#
# LVM Status. If there's at least one lvm, output 1. Another way to do it is with the lsblk command.
lvm=$(if [[ $(cat /etc/fstab | grep '^/dev/mapper/') ]]; then echo yes; else echo no; fi)
#
# Number of TCP connections established
tcp=$(ss -s | grep '^TCP' | head -1 | awk '{print $4}')
#
# Number of users on server. The wc command (word count) is quite useful here.
user_log=$(who | wc -l)
#
# IPv4 address + MAC Address. The xargs command is meant to remove useless white spaces.
ip_addr=$(hostname -I | xargs)
mac_addr=$(ip addr | grep 'link/ether' | awk '{print $2}')
#
# Number of times the sudo command was used.
# The -c flag makes the grep command output a count instead of printing all the lines.
sudo_count=$(cat /var/log/sudo/sudo.log | grep -c 'COMMAND')
#
#
## -- Echo - Start -- ##

echo "#Architecture: ${architecture}"
echo "#CPU physical: ${cpu}"
echo "#vCPU: ${vcpu}"
echo "#Memory Usage: ${mem_used}/${mem_total} (${mem_percent})"
echo "#Disk Usage: ${disk_used}/${disk_total} (${disk_percent})"
echo "#CPU load: ${load}"
echo "#Last boot: ${last_boot}"
echo "#LVM use: ${lvm}"
echo "#Connexions TCP: ${tcp::-1} ESTABLISHED"
echo "#User log: ${user_log}"
echo "#Network: IP ${ip_addr} (${mac_addr})"
echo "#Sudo: ${sudo_count} cmd"

## -- Echo - End -- ##
