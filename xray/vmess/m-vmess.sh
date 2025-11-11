#!/bin/bash
# =========================================
# VMESS MENU
# =========================================
clear
echo -e "\e[33m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "\E[0;100;33m        VMESS MENU          \E[0m"
echo -e "\e[33m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e ""
echo -e " [\e[36m1\e[0m] Create Account Vmess "
echo -e " [\e[36m2\e[0m] Trial Account Vmess "
echo -e " [\e[36m3\e[0m] Extending Account Vmess "
echo -e " [\e[36m4\e[0m] Delete Account Vmess "
echo -e " [\e[36m5\e[0m] Check User Login Vmess "
echo -e " [\e[36m6\e[0m] User list created Account "
echo -e ""
echo -e " [\e[31m0\e[0m] \e[31mBack To Menu\033[0m"
echo -e ""
echo -e   "Press x or [ Ctrl+C ]  To-Exit"
echo ""
echo -e "\e[33m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e ""
read -p " Select menu :  "  opt
echo -e ""
case $opt in
1) clear ; add-vmess ;;
2) clear ; trial-vmess ;;
3) clear ; renew-vmess ;;
4) clear ; del-vmess ;;
5) clear ; cek-vmess ;;
6) clear ; cat /var/log/xray/vmess.log ; exit ;;
0) clear ; menu ;;
x) exit ;;
*) echo "You pressed it wrong " ; sleep 1 ; m-vmess ;;
esac
