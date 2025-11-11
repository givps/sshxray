#!/bin/bash
# =========================================
# SSH MEMBER LIST
# =========================================

# Colors
red='\e[1;31m'; green='\e[0;32m'; yellow='\e[1;33m'
blue='\e[1;34m'; cyan='\e[1;36m'; white='\e[1;37m'; nc='\e[0m'

clear
echo -e "${red}=========================================${nc}"
echo -e "${blue}             SSH USER LIST               ${nc}"
echo -e "${red}=========================================${nc}"
echo -e "USERNAME          EXP DATE          STATUS"
echo -e "${red}=========================================${nc}"

today=$(date +%s)
total=0; active=0; locked=0; expired=0

awk -F: '$3>=1000 && $1!="nobody"{print $1}' /etc/passwd | while read user; do
    ((total++))
    status=$(passwd -S "$user" 2>/dev/null | awk '{print $2}')
    expraw=$(chage -l "$user" 2>/dev/null | awk -F": " '/Account expires/{print $2}')
    
    if [[ "$expraw" == "never" || -z "$expraw" ]]; then
        exp_disp="never          "; expired_flag=0
    else
        exp_epoch=$(date -d "$expraw" +%s 2>/dev/null)
        exp_disp=$(date -d "$expraw" "+%d %b %Y" 2>/dev/null)
        [[ $exp_epoch -lt $today ]] && expired_flag=1 || expired_flag=0
    fi
    
    if [[ "$status" == "L" ]]; then
        color=$red; text="LOCKED"; ((locked++))
    elif ((expired_flag)); then
        color=$yellow; text="EXPIRED"; ((expired++))
    else
        color=$green; text="ACTIVE"; ((active++))
    fi
    
    printf "%-17s %-17s ${color}%s${nc}\n" "$user" "$exp_disp" "$text"
done

echo -e "${red}=========================================${nc}"
echo -e "Total Users    : ${cyan}$total${nc}"
echo -e "Active Users   : ${green}$active${nc}"
echo -e "Locked Users   : ${red}$locked${nc}"
echo -e "Expired Users  : ${yellow}$expired${nc}"
echo -e "${red}=========================================${nc}"

read -n 1 -s -r -p "Press any key to return..."
m-sshovpn
