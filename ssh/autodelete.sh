#!/bin/bash
# =========================================
# AUTO DELETE EXPIRED SSH USERS
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
echo -e "${blue}           AUTO DELETE SSH USERS         ${nc}"
echo -e "${red}=========================================${nc}"

# Function: Delete expired users
delete_expired_users() {
    today=$(date +%s)
    total=0
    deleted=0
    active=0
    thisday=$(date +%d-%m-%Y)

    echo -e "${yellow}Checking user expirations...${nc}"
    echo -e "${red}-----------------------------------------${nc}"
    while IFS=: read -r user _ uid _ _ _ _ expire; do
        if [[ $uid -ge 1000 && -n $expire ]]; then
            exp_date=$(( expire * 86400 ))
            if [[ $exp_date -lt $today ]]; then
                # Expired
                ((deleted++))
                expstr=$(date -d @$exp_date +"%d %b %Y")
                printf "${red}✗ %-15s expired: %s${nc}\n" "$user" "$expstr"
                userdel -f "$user" 2>/dev/null
                echo "Expired: $user expired $expstr - deleted $thisday" >> /usr/local/bin/deleteduser
            else
                # Active
                ((active++))
                expstr=$(date -d @$exp_date +"%d %b %Y")
                printf "${green}✓ %-15s active  : %s${nc}\n" "$user" "$expstr"
            fi
            ((total++))
        fi
    done < /etc/shadow
    echo -e "${red}-----------------------------------------${nc}"
    echo -e "${white}Total checked : ${total}${nc}"
    echo -e "${green}Active users  : ${active}${nc}"
    echo -e "${red}Deleted users : ${deleted}${nc}"
    echo -e "${red}-----------------------------------------${nc}"
}

# Function: Show deletion log
show_log() {
    echo -e "${yellow}LAST DELETION HISTORY:${nc}"
    echo -e "${blue}-----------------------------------------${nc}"
    if [[ -f /usr/local/bin/deleteduser ]]; then
        tail -10 /usr/local/bin/deleteduser
    else
        echo -e "${white}No deletion log found.${nc}"
    fi
    echo -e "${blue}-----------------------------------------${nc}"
}

# Main
delete_expired_users
echo ""
show_log
echo ""
echo -e "${red}=========================================${nc}"
echo -e "${green}              MENU OPTIONS              ${nc}"
echo -e "${red}=========================================${nc}"
echo -e "${white}1${nc}. Run Auto Delete Again"
echo -e "${white}2${nc}. View Full Deletion Log"
echo -e "${white}3${nc}. Clear Deletion History"
echo -e "${white}0${nc}. Back to SSH Menu"
echo -e "${white}x${nc}. Exit"
echo -e "${red}=========================================${nc}"
echo ""

read -p "Select option [1-5]: " opt
case $opt in
1)
    exec "$0"
    ;;
2)
    clear
    echo -e "${red}=========================================${nc}"
    echo -e "${blue}          FULL DELETION LOG           ${nc}"
    echo -e "${red}=========================================${nc}"
    [[ -f /usr/local/bin/deleteduser ]] && cat /usr/local/bin/deleteduser || echo "No log found."
    echo -e "${red}=========================================${nc}"
    read -n1 -s -r -p "Press any key to return..."
    exec "$0"
    ;;
3)
    rm -f /usr/local/bin/deleteduser
    echo -e "${green}History cleared.${nc}"
    sleep 1
    exec "$0"
    ;;
0)
    echo -e "${green}Returning to SSH menu...${nc}"
    sleep 1
    m-sshovpn
    ;;
x)
    clear; exit 0
    ;;
*)
    echo -e "${red}Invalid choice!${nc}"
    sleep 1
    exec "$0"
    ;;
esac
