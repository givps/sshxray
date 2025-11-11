#!/bin/bash
# =========================================
# DNS CHANGER
# =========================================

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m'

clear
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "           DNS CHANGER"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

dnsfile="/root/dns"
if [ -f "$dnsfile" ]; then
    active_dns=$(cat "$dnsfile")
    echo -e "Active DNS : ${GREEN}$active_dns${NC}"
fi

echo ""
echo -e "[1] Set Custom DNS (e.g., 1.1.1.1)"
echo -e "[2] Reset DNS to Google (8.8.8.8)"
echo -e "[3] Reboot VPS"
echo -e "[0] Back to Menu"
echo ""

read -p "Select option [0-3]: " choice
echo ""

case $choice in
1)
    read -p "Enter new DNS: " new_dns
    if [ -z "$new_dns" ]; then
        echo -e "${RED}No DNS entered!${NC}"
        sleep 1
        $0
        exit
    fi
    echo "$new_dns" > /root/dns
    echo -e "nameserver $new_dns" > /etc/resolv.conf
    echo -e "nameserver $new_dns" > /etc/resolvconf/resolv.conf.d/head
    systemctl restart resolvconf.service
    echo -e "${GREEN}DNS $new_dns successfully set.${NC}"
    sleep 1
    $0
    ;;
2)
    rm -f /root/dns
    echo -e "nameserver 8.8.8.8" > /etc/resolv.conf
    echo -e "nameserver 8.8.8.8" > /etc/resolvconf/resolv.conf.d/head
    systemctl restart resolvconf.service
    echo -e "${GREEN}DNS reset to Google 8.8.8.8.${NC}"
    sleep 1
    $0
    ;;
3)
    reboot
    ;;
0)
    m-system
    ;;
*)
    echo -e "${RED}Invalid option!${NC}"
    sleep 1
    $0
    ;;
esac
