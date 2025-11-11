#!/bin/bash
# =========================================
# CHECK MULTI SSH USER
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
echo -e "${blue}           CHECK MULTI SSH USER          ${nc}"
echo -e "${red}=========================================${nc}"
echo

# Function to display violation logs
display_violations() {
    if [ -f "/root/log-limit.txt" ]; then
        echo -e "${white}Users Who Violated the Connection Limit${nc}"
        echo -e "${white}Time - Username - Number of Connections${nc}"
        echo -e "${red}=========================================${nc}"
        cat /root/log-limit.txt
    else
        echo -e "${yellow}No users have violated the connection limit.${nc}"
        echo -e "${yellow}Or the user-limit script hasn't been executed yet.${nc}"
    fi
}

# Display current violations
display_violations

echo
echo -e "${red}=========================================${nc}"
echo -e "${blue}               MENU OPTIONS              ${nc}"
echo -e "${red}=========================================${nc}"
echo -e "${white}1${nc}. Refresh Check"
echo -e "${white}2${nc}. Clear Log History"
echo -e "${white}3${nc}. Back to SSH Menu"
echo -e "${white}4${nc}. Exit"
echo -e "${red}=========================================${nc}"
echo

read -rp "Select option [1-4]: " option

case $option in
    1)
        echo -e "${green}Refreshing...${nc}"
        sleep 1
        exec "$0"
        ;;
    2)
        if [ -f "/root/log-limit.txt" ]; then
            rm -f /root/log-limit.txt
            echo -e "${green}Log history cleared successfully!${nc}"
        else
            echo -e "${yellow}No log file to clear.${nc}"
        fi
        sleep 2
        exec "$0"
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
        echo -e "${red}Invalid option! Returning to SSH Menu...${nc}"
        sleep 2
        m-sshovpn
        ;;
esac
