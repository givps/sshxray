#!/bin/bash
# =========================================
# MENU
# =========================================

# -------------------------------
# Fetch Public IP
# -------------------------------
MYIP=$(wget -qO- ipv4.icanhazip.com || curl -s ifconfig.me)

# -------------------------------
# Color Definitions
# -------------------------------
RED='\e[31m'; GREEN='\e[32m'; YELL='\e[33m'; BLUE='\e[34m'; PURPLE='\e[35m'
CYAN='\e[36m'; NC='\e[0m'; BGreen='\e[1;32m'; BYellow='\e[1;33m'; BBlue='\e[1;34m'

# -------------------------------
# VPS Info
# -------------------------------
domain=$(cat /usr/local/etc/xray/domain 2>/dev/null || cat /root/domain 2>/dev/null)
uptime="$(uptime -p | cut -d " " -f2-10)"
DATE2=$(date -R | cut -d " " -f -5)
country=$(cat /myinfo/country 2>/dev/null || echo "API limit...")

# TLS Certificate Status
cert_path="$HOME/.acme.sh/${domain}_ecc/${domain}.key"
if [ -f "$cert_path" ]; then
    mod_time=$(stat "$cert_path" | sed -n '7,6p' | awk '{print $2" "$3" "$4" "$5}')
    mod_sec=$(date +%s -d "$mod_time")
    cur_sec=$(date +%s)
    days=$(( (cur_sec - mod_sec)/86400 ))
    tlsStatus=$((90 - days))
    [ "$tlsStatus" -le 0 ] && tlsStatus="expired"
else
    tlsStatus="No certificate found"
fi

# RAM & CPU Info
tram=$(free -m | awk 'NR==2 {print $2}')
uram=$(free -m | awk 'NR==2 {print $3}')
fram=$(free -m | awk 'NR==2 {print $4}')
cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8"%"}')

# Network (vnstat)
get_vnstat() { vnstat -i eth0 | grep "$1" | awk '{print $2" "substr($3,1,1)}'; }
dtoday=$(get_vnstat "today"); utoday=$(vnstat -i eth0 | grep "today" | awk '{print $5" "substr($6,1,1)}')
dmon=$(vnstat -i eth0 -m | grep "`date +"%b '%y"`" | awk '{print $3" "substr($4,1,1)}')

# User Info
Name="VIP-MEMBERS"; Exp2="Lifetime"

# -------------------------------
# Display Dashboard
# -------------------------------
clear
echo -e "${BYellow}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BBlue}                VPS INFO             ${NC}"
echo -e "${BYellow}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BGreen} OS          ${NC}: $(hostnamectl | grep 'Operating System' | cut -d ' ' -f5-)"
echo -e "${BGreen} Uptime      ${NC}: $uptime"
echo -e "${BGreen} Public IP   ${NC}: $MYIP"
echo -e "${BGreen} Country     ${NC}: $country"
echo -e "${BGreen} DOMAIN      ${NC}: $domain"
echo -e "${BGreen} DATE & TIME ${NC}: $DATE2"
echo -e "${BYellow}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BBlue}                RAM INFO             ${NC}"
echo -e "${BYellow}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BGreen} RAM USED    ${NC}: $uram MB"
echo -e "${BGreen} RAM TOTAL   ${NC}: $tram MB"
echo -e "${BGreen} CPU Usage   ${NC}: $cpu_usage"
echo -e "${BYellow}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BBlue}                  MENU               ${NC}"
echo -e "${BYellow}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN} 1 ${NC}: Menu SSH"
echo -e "${CYAN} 2 ${NC}: Menu Vmess"
echo -e "${CYAN} 3 ${NC}: Menu Vless"
echo -e "${CYAN} 4 ${NC}: Menu Trojan"
echo -e "${CYAN} 5 ${nc}: Xray Log"
echo -e "${CYAN} 6 ${NC}: Menu Setting"
echo -e "${CYAN} 7 ${NC}: Reboot VPS"
echo -e "${CYAN} x ${NC}: Exit Script"
echo -e "${BYellow}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BGreen} Client Name ${NC}: $Name"
echo -e "${BGreen} Expired     ${NC}: $Exp2"
echo -e "${BYellow}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN} --------------------t.me/givpn_grup-------------------${NC}"
echo ""

# -------------------------------
# Menu Selection
# -------------------------------
read -p " Select menu :  " opt
echo ""
case $opt in
    1) clear ; m-sshovpn ;;
    2) clear ; m-vmess ;;
    3) clear ; m-vless ;;
    4) clear ; m-trojan ;;
    5) clear ; xray-log ;;
    6) clear ; m-system ;;
    7) clear ; /sbin/reboot ;;
    x) exit ;;
    *) echo "You pressed it wrong" ; sleep 1 ; menu ;;
esac
