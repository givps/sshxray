#!/bin/bash
# =========================================
# vmess Active Users
# =========================================

CONFIG="/usr/local/etc/xray/config.json"
LOG="/var/log/xray/access.log"
BLUE='\033[0;34m'
GREEN='\033[0;32m'
NC='\033[0m'

clear
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}        Vmess Active Users        ${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

mapfile -t USERS < <(grep -E "^[[:space:]]*#3 " "$CONFIG" | awk '{print $2}' | sort -u)

declare -A LAST_IP

while read -r line; do
    for user in "${USERS[@]}"; do
        if [[ "$line" =~ email:\ $user ]]; then
            ip=$(echo "$line" | awk '{for(i=1;i<=NF;i++){if($i=="from"){print $(i+1)}}}')
            ip=${ip//tcp:/}
            ip=${ip//udp:/}
            ip=${ip/:0/}
            LAST_IP[$user]=$ip
        fi
    done
done < "$LOG"

for user in "${USERS[@]}"; do
    if [[ -n "${LAST_IP[$user]}" ]]; then
        echo -e "${GREEN}User:${NC} $user\tIP: ${LAST_IP[$user]}"
    fi
done

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
read -n 1 -s -r -p "Press any key to back on menu"
m-vmess
