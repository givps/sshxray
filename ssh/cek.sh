#!/bin/bash
# =========================================
# SSH USER LOGIN MONITOR
# =========================================

# Colors
red='\e[1;31m'
green='\e[0;32m'
yellow='\e[1;33m'
blue='\e[1;34m'
white='\e[1;37m'
nc='\e[0m'

TMP_LOG="/tmp/ssh-login.txt"

# Detect auth log
if [ -f /var/log/auth.log ]; then
    LOG="/var/log/auth.log"
elif [ -f /var/log/secure ]; then
    LOG="/var/log/secure"
else
    echo -e "${red}No authentication log found!${nc}"
    exit 1
fi

show_login_info() {
    clear
    echo -e "${red}=========================================${nc}"
    echo -e "${blue}          OpenSSH Active Users           ${nc}"
    echo -e "${red}=========================================${nc}"
    echo -e "${white}PID   |  Username  |  IP Address${nc}"
    echo -e "${red}=========================================${nc}"

    grep -i "sshd.*Accepted password for" "$LOG" > "$TMP_LOG"
    ssh_count=0

    ps aux | grep "sshd.*@" | grep -v grep | awk '{print $2}' | while read pid; do
        ppid=$(ps -o ppid= -p "$pid" 2>/dev/null | tr -d ' ')
        line=$(grep "sshd\[$ppid\]" "$TMP_LOG")
        if [ -n "$line" ]; then
            user=$(awk '{print $9}' <<<"$line")
            ip=$(awk '{print $11}' <<<"$line")
            if [[ -n "$user" && -n "$ip" ]]; then
                printf "${white}%-5s - %-10s - %-15s${nc}\n" "$pid" "$user" "$ip"
                ((ssh_count++))
            fi
        fi
    done

    if [ "$ssh_count" -eq 0 ]; then
        echo -e "${yellow}No active SSH connections${nc}"
    fi

    echo -e "${red}=========================================${nc}"
}

# --- MAIN MENU ---
show_menu() {
    echo ""
    echo -e "${red}=========================================${nc}"
    echo -e "${blue}              MENU OPTIONS               ${nc}"
    echo -e "${red}=========================================${nc}"
    echo -e "${white}1${nc}. Refresh Login Information"
    echo -e "${white}2${nc}. Kill User Session"
    echo -e "${white}3${nc}. Back to SSH Menu"
    echo -e "${white}4${nc}. Exit"
    echo -e "${red}=========================================${nc}"
    echo ""
    read -p "Select option [1-4]: " option

    case $option in
        1)
            show_login_info
            show_menu
            ;;
        2)
            read -p "Enter PID to kill: " kill_pid
            if [[ "$kill_pid" =~ ^[0-9]+$ ]] && kill -0 "$kill_pid" 2>/dev/null; then
                kill "$kill_pid"
                echo -e "${green}Session $kill_pid terminated${nc}"
            else
                echo -e "${red}Invalid PID or not found${nc}"
            fi
            sleep 2
            show_login_info
            show_menu
            ;;
        3)
            echo -e "${green}Returning to SSH Menu...${nc}"
            sleep 1
            m-sshovpn
            ;;
        4)
            echo -e "${green}Exiting...${nc}"
            sleep 1
            clear
            exit 0
            ;;
        *)
            echo -e "${red}Invalid option!${nc}"
            sleep 2
            show_login_info
            show_menu
            ;;
    esac
}

show_login_info
show_menu
