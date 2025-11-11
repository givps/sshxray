#!/bin/bash
# =========================================
# USER LOCK & UNLOCK TOOL
# =========================================

# Colors
red='\e[1;31m'; green='\e[0;32m'; yellow='\e[1;33m'; blue='\e[1;34m'
cyan='\e[1;36m'; white='\e[1;37m'; nc='\e[0m'

LOG_FILE="/var/log/user-management.log"

# Ensure root privileges
[[ $EUID -ne 0 ]] && echo -e "${red}Run as root!${nc}" && exit 1

# Validate username format
validate_username() {
    [[ -z "$1" ]] && echo -e "${red}Username required!${nc}" && return 1
    [[ ! "$1" =~ ^[a-z_][a-z0-9_-]*$ ]] && echo -e "${red}Invalid username!${nc}" && return 1
}

# Check user status (locked/unlocked)
get_user_status() {
    passwd -S "$1" 2>/dev/null | grep -q "LK" && echo "locked" || echo "unlocked"
}

# Log actions
log_activity() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1: user '$2' $3 by $(whoami)" >> "$LOG_FILE"
}

# Display recent users
display_users() {
    echo -e "\n${yellow}Recently active:${nc}"
    last -10 | awk '{print $1}' | sort -u | grep -Ev "reboot|wtmp|^$" | sed "s/^/  ${cyan}/;s/$/${nc}/"
    echo -e "\n${yellow}System users:${nc}"
    getent passwd | awk -F: '$3>=1000{print "  '${cyan}'"$1"'${nc}'"}'
    echo
}

# Lock / Unlock function
user_action() {
    local user="$1" action="$2"
    echo -e "\n${yellow}${action^}ing user: ${blue}$user${nc}"
    if passwd "-${action:0:1}" "$user" &>/dev/null; then
        local s=$(get_user_status "$user")
        clear
        echo -e "${blue}=========================================${nc}"
        echo -e "${green}User ${action^^}ED SUCCESSFULLY${nc}"
        echo -e "${blue}=========================================${nc}"
        echo -e "Username : ${cyan}$user${nc}"
        echo -e "Status   : ${yellow}$s${nc}"
        echo -e "Date     : ${white}$(date)${nc}"
        log_activity "${action^^}" "$user" "$s"
    else
        echo -e "${red}Failed to ${action} user '$user'${nc}"
        log_activity "${action^^}" "$user" "FAILED"
    fi
}

# Menu
clear
echo -e "${yellow}=========================================${nc}"
echo -e "${yellow}       USER LOCK & UNLOCK TOOL          ${nc}"
echo -e "${yellow}=========================================${nc}"
echo
echo -e "  ${white}1${nc}. Lock user"
echo -e "  ${white}2${nc}. Unlock user"
echo -e "  ${white}3${nc}. Check user status"
echo -e "  ${white}4${nc}. Back to SSH Menu"
echo -e "  ${white}0${nc}. Exit"
echo
read -rp "Select option [1-5]: " opt

case $opt in
  1) mode="lock" ;;
  2) mode="unlock" ;;
  3) mode="status" ;;
  4) m-sshovpn; exit 0 ;;
  0) clear; exit 0 ;;
  *) echo -e "${red}Invalid option!${nc}"; exit 1 ;;
esac

clear
echo -e "${blue}=========================================${nc}"
echo -e "${blue}           USER ${mode^^} MODE           ${nc}"
echo -e "${blue}=========================================${nc}"
display_users

read -rp "Enter username to $mode: " user
validate_username "$user" || exit 1
id "$user" &>/dev/null || { echo -e "${red}User not found!${nc}"; exit 1; }

status=$(get_user_status "$user")
echo -e "\n${blue}User info:${nc}"
echo -e "  Username : ${cyan}$user${nc}"
echo -e "  Status   : ${yellow}$status${nc}\n"

case $mode in
  lock|unlock)
    read -rp "Confirm to $mode '$user'? (y/N): " c
    [[ "$c" =~ ^[Yy]$ ]] && user_action "$user" "$mode"
    ;;
  status)
    echo -e "${yellow}=========================================${nc}"
    echo -e "Username  : ${cyan}$user${nc}"
    echo -e "Home Dir  : ${white}$(eval echo ~$user)${nc}"
    echo -e "Shell     : ${white}$(getent passwd "$user" | cut -d: -f7)${nc}"
    echo -e "Status    : ${yellow}$status${nc}"
    echo -e "Last Login: ${white}$(last -n 1 "$user" | head -1 || echo 'Never')${nc}"
    echo -e "${yellow}=========================================${nc}"
    log_activity "STATUS_CHECK" "$user" "$status"
    ;;
esac

echo
read -n 1 -s -r -p "Press any key to return..."
m-sshovpn
