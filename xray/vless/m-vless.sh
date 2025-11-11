#!/bin/bash
# =========================================
# VLESS MENU
# =========================================
clear
echo -e "\e[33m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "\E[0;100;33m        VLESS MENU          \E[0m"
echo -e "\e[33m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e ""
echo -e " [\e[36m1\e[0m] Create Account Vless "
echo -e " [\e[36m2\e[0m] Trial Account Vless "
echo -e " [\e[36m3\e[0m] Extending Account Vless "
echo -e " [\e[36m4\e[0m] Delete Account Vless "
echo -e " [\e[36m5\e[0m] Check User Login Vless "
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
1) clear ; add-vless ;;
2) clear ; trial-vless ;;
3) clear ; renew-vless ;;
4) clear ; del-vless ;;
5) clear ; cek-vless ;;
6) clear ; cat /var/log/xray/vless.log ; exit ;;
0) clear ; menu ;;
x) exit ;;
*) echo "You pressed it wrong " ; sleep 1 ; m-vless ;;
esac
