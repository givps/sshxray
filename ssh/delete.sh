#!/bin/bash
# =========================================
# DELETE SSH USER
# =========================================

# Colors
red='\e[1;31m'; green='\e[0;32m'; yellow='\e[1;33m'
blue='\e[1;34m'; white='\e[1;37m'; nc='\e[0m'

LOGFILE="/var/log/user-deletion.log"

# Ensure log directory exists
mkdir -p "$(dirname "$LOGFILE")"

delete_user() {
    clear
    echo -e "${red}=========================================${nc}"
    echo -e "${blue}             DELETE USER                 ${nc}"
    echo -e "${red}=========================================${nc}\n"

    echo -e "${yellow}Current SSH Users:${nc}"
    echo -e "${blue}=========================================${nc}"
    getent passwd | awk -F: '$7=="/bin/bash"{print "• "$1}' | sort
    echo -e "${blue}=========================================${nc}\n"

    read -p "Username to delete: " user
    [[ -z "$user" ]] && { echo -e "${red}Error: Username cannot be empty!${nc}"; return 1; }

    if ! id "$user" &>/dev/null; then
        echo -e "${red}✗ Error: User '$user' does not exist.${nc}"
        return 1
    fi

    echo -e "\n${yellow}Are you sure you want to delete user '$user'?${nc}"
    read -p "Confirm deletion? [y/N]: " confirm
    [[ ! $confirm =~ ^[Yy]$ ]] && { echo -e "${yellow}Deletion cancelled.${nc}"; return 0; }

    # Kill user sessions
    pkill -u "$user" 2>/dev/null

    # Delete user safely
    userdel -r "$user" &>/dev/null || userdel "$user" &>/dev/null

    # Remove user references in Xray configs (if exist)
    sed -i "/### $user ###/d" /etc/xray/config.json 2>/dev/null
    sed -i "/^$user:/d" /etc/xray/ssh.txt 2>/dev/null

    # Log the deletion
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Deleted user: $user" >> "$LOGFILE"
    echo -e "${green}✓ Success: User '$user' was removed.${nc}"
}

show_deletion_log() {
    [[ ! -f "$LOGFILE" ]] && return
    echo -e "\n${yellow}Recent Deletion History:${nc}"
    echo -e "${blue}=========================================${nc}"
    tail -5 "$LOGFILE"
    echo -e "${blue}=========================================${nc}"
}

main_menu() {
    clear
    delete_user
    show_deletion_log

    echo -e "\n${red}=========================================${nc}"
    echo -e "${blue}              MENU OPTIONS              ${nc}"
    echo -e "${red}=========================================${nc}"
    echo -e "${white}1${nc}. Delete Another User"
    echo -e "${white}2${nc}. View Full Deletion Log"
    echo -e "${white}3${nc}. Clear Deletion Log"
    echo -e "${white}4${nc}. Back to SSH Menu"
    echo -e "${white}5${nc}. Exit"
    echo -e "${red}=========================================${nc}\n"

    read -p "Select option [1-5]: " opt
    case "$opt" in
        1) exec "$0" ;;
        2)
            clear
            echo -e "${red}=========================================${nc}"
            echo -e "${blue}          FULL DELETION LOG             ${nc}"
            echo -e "${red}=========================================${nc}"
            [[ -f "$LOGFILE" ]] && cat "$LOGFILE" || echo -e "${yellow}No deletion history found.${nc}"
            echo -e "${red}=========================================${nc}"
            read -n 1 -s -r -p "Press any key to continue..."; exec "$0"
            ;;
        3)
            rm -f "$LOGFILE" && echo -e "${green}Deletion log cleared!${nc}" || echo -e "${yellow}No log to clear.${nc}"
            sleep 2; exec "$0"
            ;;
        4) echo -e "${green}Returning to SSH Menu...${nc}"; sleep 1; m-sshovpn ;;
        5) echo -e "${green}Exiting...${nc}"; sleep 1; clear; exit 0 ;;
        *) echo -e "${red}Invalid option! Returning...${nc}"; sleep 2; m-sshovpn ;;
    esac
}

main_menu
