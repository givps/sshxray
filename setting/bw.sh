#!/bin/bash
# =========================================
# BANDWIDTH MONITOR
# =========================================

show_header() {
    clear
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo -e "\e[1;34m           BANDWIDTH MONITOR          \e[0m"
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo ""
}

pause() {
    echo -e ""
    read -n 1 -s -r -p "Press any key to return to menu..."
}

check_vnstat() {
    if ! command -v vnstat &> /dev/null; then
        echo -e "\n${RED}vnstat is not installed! Please install it first.${NC}"
        pause
        return 1
    fi
}

while true; do
    show_header
    echo -e "\e[1;35m 1 \e[0m View Total Remaining Bandwidth"
    echo -e "\e[1;35m 2 \e[0m Usage Table Every 5 Minutes"
    echo -e "\e[1;35m 3 \e[0m Hourly Usage Table"
    echo -e "\e[1;35m 4 \e[0m Daily Usage Table"
    echo -e "\e[1;35m 5 \e[0m Monthly Usage Table"
    echo -e "\e[1;35m 6 \e[0m Annual Usage Table"
    echo -e "\e[1;35m 7 \e[0m Highest Usage Table"
    echo -e "\e[1;35m 8 \e[0m Hourly Usage Statistics"
    echo -e "\e[1;35m 9 \e[0m Current Active Usage"
    echo -e "\e[1;35m 10 \e[0m Live Traffic [5s]"
    echo -e ""
    echo -e "\e[1;34m 0 Back To Menu \e[0m"
    echo -e "\e[1;34m x Exit \e[0m"
    echo -e ""
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo -e ""

    read -p "Select menu: " opt
    opt=$(echo "$opt" | xargs) # trim spaces

    case $opt in
        1) check_vnstat && vnstat ;;
        2) check_vnstat && vnstat -5 ;;
        3) check_vnstat && vnstat -h ;;
        4) check_vnstat && vnstat -d ;;
        5) check_vnstat && vnstat -m ;;
        6) check_vnstat && vnstat -y ;;
        7) check_vnstat && vnstat -t ;;
        8) check_vnstat && vnstat -hg ;;
        9) check_vnstat && vnstat -l ;;
        10) check_vnstat && vnstat -tr ;;
        0) sleep 1 ; m-system ; exit ;;
        x) exit ;;
        *) echo -e "\nYou pressed wrong, try again!" ; sleep 1 ;;
    esac

    pause
done
