#!/bin/bash
# =========================================
# SSH AUTOKILL MENU
# =========================================

# Colors
red='\e[1;31m'
green='\e[0;32m'
yellow='\e[1;33m'
blue='\e[1;34m'
white='\e[1;37m'
nc='\e[0m'

# Configuration
AUTOKILL_SCRIPT="/usr/bin/autokick"

clear
echo -e "${red}=========================================${nc}"
echo -e "${blue}           SSH AUTOKILL MANAGER          ${nc}"
echo -e "${red}=========================================${nc}"

# Status check
if [ -f "/etc/cron.d/autokick" ] && grep -q -E "^# Autokill" "/etc/cron.d/autokick" 2>/dev/null; then
    echo -e "Status Autokill   : ${green}[ACTIVE]${nc}"
    cron_line=$(grep -E "^\*/[0-9]+" /etc/cron.d/autokick | head -1)
    if [[ $cron_line =~ \*/([0-9]+)\ \*\ \*\ \*\ \*\ root\ $AUTOKILL_SCRIPT\ ([0-9]+) ]]; then
        interval=${BASH_REMATCH[1]}
        max_conn=${BASH_REMATCH[2]}
        echo -e "Check Interval    : ${yellow}Every $interval minutes${nc}"
        echo -e "Max Connections   : ${yellow}$max_conn${nc}"
    fi
else
    echo -e "Status Autokill   : ${red}[INACTIVE]${nc}"
fi

echo -e "${red}-----------------------------------------${nc}"
echo -e "${white}1${nc}. AutoKill Every 5 Minutes"
echo -e "${white}2${nc}. AutoKill Every 10 Minutes"
echo -e "${white}3${nc}. AutoKill Every 15 Minutes"
echo -e "${white}4${nc}. AutoKill Every 30 Minutes"
echo -e "${white}5${nc}. Custom Interval"
echo -e "${white}6${nc}. Turn Off AutoKill"
echo -e "${white}0${nc}. Back to SSH Menu"
echo -e "${white}x${nc}. Exit"
echo -e "${red}-----------------------------------------${nc}"

read -p "Select option [0-6 or x]: " AutoKill
echo ""

# Check existence
if [[ "$AutoKill" =~ ^[1-5]$ ]] && [ ! -f "$AUTOKILL_SCRIPT" ]; then
    echo -e "${red}Error:${nc} Autokill script not found at ${yellow}$AUTOKILL_SCRIPT${nc}"
    echo -e "Please install or check the path."
    read -n1 -s -r -p "Press any key to continue..."
    exec "$0"
fi

# Menu handler
case $AutoKill in
1|2|3)
    case $AutoKill in
        1) interval=5 ;;
        2) interval=10 ;;
        3) interval=15 ;;
    esac
    ;;
4)
    interval=30
    ;;
5)
    while true; do
        read -p "Custom check interval [1-60 minutes]: " interval
        [[ "$interval" =~ ^[1-9]$|^[1-5][0-9]$|^60$ ]] && break
        echo -e "${red}Invalid input!${nc}"
    done
    ;;
6)
    if [ -f "/etc/cron.d/autokick" ]; then
        rm -f /etc/cron.d/autokick
        echo -e "${yellow}✓ AutoKill disabled.${nc}"
    else
        echo -e "${yellow}Already inactive.${nc}"
    fi
    sleep 1
    exec "$0"
    ;;
0)
    echo -e "${green}Returning to SSH Menu...${nc}"
    sleep 1
    m-sshovpn
    exit 0
    ;;
x)
    clear; exit 0 ;;
*)
    echo -e "${red}Invalid option!${nc}"
    sleep 1
    exec "$0"
    ;;
esac

# Ask max connections if not option 6
while true; do
    read -p "Max connections allowed [1-10]: " max
    [[ "$max" =~ ^[1-9]$|^10$ ]] && break
    echo -e "${red}Please enter a number between 1-10.${nc}"
done

# Write new cron
cat > /etc/cron.d/autokick << EOF
# Autokill - Do not edit manually
# Check every $interval minutes, max $max connections
*/$interval * * * * root $AUTOKILL_SCRIPT $max
EOF

# Reload cron
if command -v systemctl >/dev/null 2>&1; then
    systemctl reload cron >/dev/null 2>&1 || systemctl reload crond >/dev/null 2>&1
else
    service cron reload >/dev/null 2>&1 || service crond reload >/dev/null 2>&1
fi

echo ""
echo -e "${green}✓ AutoKill activated${nc}"
echo -e "  Interval : Every ${yellow}$interval${nc} minutes"
echo -e "  Max conn : ${yellow}$max${nc}"
echo ""
read -n1 -s -r -p "Press any key to return..."
exec "$0"
