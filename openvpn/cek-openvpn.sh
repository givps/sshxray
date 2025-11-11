#!/bin/bash
# =========================================
# CHECK OPENVPN LOGGED-IN USERS
# =========================================

# Colors
red='\e[1;31m'; green='\e[0;32m'; yellow='\e[1;33m'; nc='\e[0m'

# Paths to your OpenVPN status logs
STATUS_TCP="/var/log/openvpn/server-tcp.log"
STATUS_UDP="/var/log/openvpn/server-udp.log"
STATUS_SSL="/var/log/openvpn/server-ssl.log"

clear
echo -e "${red}=========================================${nc}"
echo -e "${yellow}      OPENVPN LOGGED-IN USER CHECK      ${nc}"
echo -e "${red}=========================================${nc}"
echo

# Function to calculate connection duration
calc_duration() {
    local since="$1"
    if [[ -z "$since" ]]; then
        echo "Unknown"
        return
    fi
    local since_epoch
    since_epoch=$(date -d "$since" +%s 2>/dev/null)
    local now_epoch
    now_epoch=$(date +%s)
    local diff=$(( now_epoch - since_epoch ))
    local hours=$(( diff / 3600 ))
    local mins=$(( (diff % 3600) / 60 ))
    local secs=$(( diff % 60 ))
    printf "%02dh %02dm %02ds" "$hours" "$mins" "$secs"
}

show_online_users() {
    local FILE=$1
    local PROTO=$2

    if [[ -f "$FILE" ]]; then
        local COUNT
        COUNT=$(grep -cE '^CLIENT_LIST' "$FILE")
        if [[ $COUNT -gt 0 ]]; then
            echo -e "${green}Protocol: $PROTO (${COUNT} user(s) online)${nc}"
            echo -e "-----------------------------------------------------------------------------------"
            echo -e "USER              IP/PORT               CONNECTED SINCE        DURATION     RX        TX"
            echo -e "-----------------------------------------------------------------------------------"

            grep -E '^CLIENT_LIST' "$FILE" | while IFS=',' read -r tag user ip _ _ rx tx _ since _; do
                duration=$(calc_duration "$since")
                printf "%-17s %-21s %-19s %-10s %-9s %-9s\n" "$user" "$ip" "$since" "$duration" "$rx" "$tx"
            done
            echo
        else
            echo -e "${yellow}No active users found for $PROTO.${nc}"
            echo
        fi
    else
        echo -e "${yellow}Status file not found for $PROTO ($FILE)${nc}"
        echo
    fi
}

# Display users per protocol
show_online_users "$STATUS_TCP" "TCP"
show_online_users "$STATUS_UDP" "UDP"
show_online_users "$STATUS_SSL" "SSL"

echo -e "${red}=========================================${nc}"
read -n 1 -s -r -p "Press any key to return to menu..."
m-sshovpn
