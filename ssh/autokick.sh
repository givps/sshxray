#!/bin/bash
# =========================================
# AUTO KICK SSH USER (Only SSHD)
# =========================================

# Colors
red='\e[1;31m'
green='\e[0;32m'
yellow='\e[1;33m'
blue='\e[1;34m'
white='\e[1;37m'
nc='\e[0m'

clear
echo -e "${red}=========================================${nc}"
echo -e "${blue}           AUTO KICK SSH USER            ${nc}"
echo -e "${red}=========================================${nc}"

# Config
MAX=${1:-2}  # Default max connection
LOG=""
[[ -f /var/log/auth.log ]] && LOG="/var/log/auth.log"
[[ -f /var/log/secure ]] && LOG="/var/log/secure"

if [[ -z "$LOG" ]]; then
    echo -e "${red}Error:${nc} No auth log file found!"
    exit 1
fi

echo -e "Max Connections : ${yellow}$MAX${nc}"
echo -e "Log File        : ${yellow}$LOG${nc}"
echo -e "${red}-----------------------------------------${nc}"

# Get user list with home dir
mapfile -t users < <(awk -F: '$3>=1000 && $1!="nobody"{print $1}' /etc/passwd)

declare -A conn_count
declare -A pid_list

# Scan SSH sessions
mapfile -t ssh_pids < <(ps aux | grep 'sshd.*@' | grep -v grep | awk '{print $2}')

echo -e "${blue}Checking active SSH sessions...${nc}"

for pid in "${ssh_pids[@]}"; do
    if grep -q "\[$pid\]" "$LOG" 2>/dev/null; then
        line=$(grep "\[$pid\]" "$LOG" | grep "Accepted password for" | tail -1)
        if [[ -n "$line" ]]; then
            user=$(echo "$line" | awk '{print $9}')
            ip=$(echo "$line" | awk '{print $11}')
            if [[ " ${users[@]} " =~ " ${user} " ]]; then
                ((conn_count["$user"]++))
                pid_list["$user"]+="$pid "
                echo -e "  ${white}$user${nc} from ${yellow}$ip${nc} (PID: $pid)"
            fi
        fi
    fi
done

echo -e "${red}-----------------------------------------${nc}"
echo -e "${blue}Checking for users exceeding limit...${nc}"

kicked=0
for user in "${users[@]}"; do
    conns=${conn_count["$user"]}
    [[ -z "$conns" ]] && continue
    if (( conns > MAX )); then
        echo -e "${red}✗ $user has $conns connections (max $MAX)${nc}"
        echo "$(date '+%F %T') - $user - $conns connections" >> /root/log-limit.txt
        for pid in ${pid_list["$user"]}; do
            if ps -p "$pid" &>/dev/null; then
                kill "$pid"
                echo -e "  Killed PID: $pid"
            fi
        done
        ((kicked++))
    else
        echo -e "${green}✓ $user: $conns connections${nc}"
    fi
done

echo -e "${red}-----------------------------------------${nc}"
if (( kicked > 0 )); then
    echo -e "${yellow}Kicked $kicked user(s) for exceeding limit${nc}"
else
    echo -e "${green}No users exceeded connection limit${nc}"
fi

echo -e "${red}=========================================${nc}"
