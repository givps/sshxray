#!/bin/bash
# =========================================
# RENEW SSH USER
# =========================================

# Colors
red='\e[1;31m'; green='\e[0;32m'; yellow='\e[1;33m'
blue='\e[1;34m'; nc='\e[0m'

clear
echo -e "${red}=========================================${nc}"
echo -e "${blue}           RENEW SSH USER              ${nc}"
echo -e "${red}=========================================${nc}"
echo

# --- Show existing SSH users and their expiry dates ---
echo -e "${yellow}List of SSH users and their expiry dates:${nc}"
while IFS=: read -r user _ uid _; do
    if (( uid >= 1000 )) && [[ "$user" != "nobody" ]]; then
        exp=$(chage -l "$user" | awk -F': ' '/Account expires/{print $2}')
        echo " - $user   (Expires: $exp)"
    fi
done < /etc/passwd
echo

read -p "Enter username : " User
if ! id "$User" &>/dev/null; then
    echo -e "\n${red}User does not exist!${nc}\n"
    read -n 1 -s -r -p "Press any key to return..."
    m-sshovpn; exit 1
fi

read -p "Extend for how many days: " day
[[ ! "$day" =~ ^[0-9]+$ || "$day" -le 0 ]] && { echo -e "${red}Invalid number!${nc}"; m-sshovpn; exit 1; }

# Get current expiry
current_exp=$(chage -l "$User" | awk -F': ' '/Account expires/{print $2}')

# Determine new expiry (extend from current if still valid)
if [[ "$current_exp" != "never" && "$current_exp" != "password must be changed" ]]; then
    current_ts=$(date -d "$current_exp" +%s 2>/dev/null || echo 0)
    now_ts=$(date +%s)
    if (( current_ts > now_ts )); then
        new_exp=$(date -d "@$((current_ts + day*86400))" +%Y-%m-%d)
    else
        new_exp=$(date -d "+$day days" +%Y-%m-%d)
    fi
else
    new_exp=$(date -d "+$day days" +%Y-%m-%d)
fi

usermod -e "$new_exp" "$User"
passwd -u "$User" &>/dev/null

clear
echo -e "${red}=========================================${nc}"
echo -e "${blue}         SSH USER RENEWED              ${nc}"
echo -e "${red}=========================================${nc}"
echo -e " Username        : $User"
echo -e " Days Extended   : $day"
echo -e " New Expiry      : $new_exp"
echo -e " Previous Expiry : ${current_exp:-None}"
echo -e "${red}=========================================${nc}"
read -n 1 -s -r -p "Press any key to return..."
m-sshovpn
