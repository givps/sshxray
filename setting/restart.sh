#!/bin/bash
# =========================================
# Restart MENU & Services Status
# =========================================
clear
echo -e "\e[33m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "\E[0;100;33m          SERVICES STATUS           \E[0m"
echo -e "\e[33m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo ""

check_status() {
    systemctl is-active --quiet $1
    if [ $? -eq 0 ]; then
        echo -e " [$1] \e[32mRUNNING\e[0m"
    else
        echo -e " [$1] \e[31mSTOPPED\e[0m"
    fi
}

services=("nginx" "xray" "sshd" "openvpn" "fail2ban" "stunnel4" "sslh")

for service in "${services[@]}"; do
    check_status $service
done

echo ""
echo -e "\e[33m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "\E[0;100;33m          RESTART MENU           \E[0m"
echo -e "\e[33m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e ""
echo -e " [\e[36m1\e[0m] Restart All Services"
echo -e " [\e[36m2\e[0m] Restart nginx"
echo -e " [\e[36m3\e[0m] Restart xray"
echo -e " [\e[36m4\e[0m] Restart ssh"
echo -e " [\e[36m5\e[0m] Restart openvpn"
echo -e " [\e[36m6\e[0m] Restart fail2ban"
echo -e " [\e[36m7\e[0m] Restart stunnel4"
echo -e " [\e[36m8\e[0m] Restart sslh"
echo -e ""
echo -e " [\e[31m0\e[0m] \e[31mBack To Menu\033[0m"
echo -e ""
echo -e "Press x or [ Ctrl+C ]  To-Exit"
echo -e ""
echo -e "\e[33m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e ""

read -p " Select menu : " Restart
echo ""

case $Restart in
1)
    echo -e "\e[32mRestarting nginx...\e[0m"
    systemctl daemon-reload
    systemctl restart nginx
    echo -e "\e[32mRestarting xray...\e[0m"
    systemctl restart xray
    echo -e "\e[32mRestarting ssh...\e[0m"
    systemctl restart sshd
    echo -e "\e[32mRestarting openvpn...\e[0m"
    systemctl restart openvpn-server@server-tcp
    systemctl restart openvpn-server@server-udp
    systemctl restart openvpn-server@server-ssl
    systemctl restart openvpn
    echo -e "\e[32mRestarting fail2ban...\e[0m"
    systemctl restart fail2ban
    echo -e "\e[32mRestarting stunnel4...\e[0m"
    systemctl restart stunnel4
    echo -e "\e[32mRestarting sslh...\e[0m"
    systemctl restart sslh
    echo -e "\e[32mAll services restarted successfully!\e[0m"
    sleep 1
    $0
    ;;
2)
    echo -e "\e[32mRestarting nginx...\e[0m"
    systemctl restart nginx
    echo -e "\e[32mnginx restarted successfully!\e[0m"
    sleep 1
    $0
    ;;
3)
    echo -e "\e[32mRestarting xray...\e[0m"
    systemctl restart xray
    echo -e "\e[32mxray restarted successfully!\e[0m"
    sleep 1
    $0
    ;;
4)
    echo -e "\e[32mRestarting ssh...\e[0m"
    systemctl restart sshd
    echo -e "\e[32mssh restarted successfully!\e[0m"
    sleep 1
    $0
    ;;
5)
    echo -e "\e[32mRestarting openvpn...\e[0m"
    systemctl restart openvpn-server@server-tcp
    systemctl restart openvpn-server@server-udp
    systemctl restart openvpn-server@server-ssl
    systemctl restart openvpn
    echo -e "\e[32mopenvpn restarted successfully!\e[0m"
    sleep 1
    $0
    ;;
6)
    echo -e "\e[32mRestarting fail2ban...\e[0m"
    systemctl restart fail2ban
    echo -e "\e[32mfail2ban restarted successfully!\e[0m"
    sleep 1
    $0
    ;;
7)
    echo -e "\e[32mRestarting stunnel4...\e[0m"
    systemctl restart stunnel4
    echo -e "\e[32mstunnel4 restarted successfully!\e[0m"
    sleep 1
    $0
    ;;
8)
    echo -e "\e[32mRestarting sslh...\e[0m"
    systemctl restart sslh
    echo -e "\e[32msslh restarted successfully!\e[0m"
    sleep 1
    $0
    ;;
0)
    clear
    m-system
    ;;
x|X)
    exit
    ;;
*)
    echo -e "\e[31mInvalid option! Please select again.\e[0m"
    sleep 1
    $0
    ;;
esac
