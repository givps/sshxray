#!/bin/bash
# =========================================
# CREATE TRIAL SSH USER
# =========================================

# Colors
red='\e[1;31m'
green='\e[0;32m'
yellow='\e[1;33m'
blue='\e[1;34m'
cyan='\e[1;36m'
white='\e[1;37m'
nc='\e[0m'
clear
MYIP=$(wget -qO- ipv4.icanhazip.com || curl -s ifconfig.me)
domain=$(cat /usr/local/etc/xray/domain 2>/dev/null || cat /root/domain 2>/dev/null)

ssh=`cat /root/log-install.txt | grep -w "OpenSSH" | cut -f2 -d: | awk '{print $1,$2}'`
ssl=`cat /root/log-install.txt | grep -w "Stunnel4" | cut -f2 -d: | awk '{print $1,$2,$3,$4}'`

Login="trial$(tr -dc A-Za-z0-9 </dev/urandom | head -c5)"
Pass=$(openssl rand -base64 24 | tr '+/' '-_' | tr -d '=')
exp=$(date -d "+1 day" +%Y-%m-%d)
useradd -e "$exp" -s /bin/false -M "$Login"
echo "$Login:$Pass" | chpasswd
printf "User: %s\nPass: %s\nExp : %s\n" "$Login" "$Pass" "$exp"
clear
if [[ ! -z "${PID}" ]]; then
echo -e "${red}=========================================${nc}"
echo -e "${blue}            TRIAL SSH              ${nc}"
echo -e "${red}=========================================${nc}"
echo -e "Username    : $Login"
echo -e "Password    : $Pass"
echo -e "Expired On  : $exp"
echo -e "${red}=========================================${nc}"
echo -e "IP          : $MYIP"
echo -e "Host        : $domain"
echo -e "SSH         : $ssh"
echo -e "SSH/SSL     : $ssl"
echo -e "${red}=========================================${nc}"
echo -e "${blue}        TRIAL OpenVPN Account           ${nc}"
echo -e "${red}=========================================${nc}"
echo -e "Username    : $Login"
echo -e "Password    : $Pass"
echo -e "Expired On  : $exp"
echo -e "${red}=========================================${nc}"
echo -e "openvpn tcp : https://$domain/openvpn/tcp.ovpn"
echo -e "openvpn udp : https://$domain/openvpn/udp.ovpn"
echo -e "openvpn ssl : https://$domain/openvpn/ssl.ovpn"
echo -e "openvpn zip : https://$domain/openvpn/ovpn.zip"
echo -e "${red}=========================================${nc}"

else

echo -e "${red}=========================================${nc}"
echo -e "${blue}            TRIAL SSH              ${nc}"
echo -e "${red}=========================================${nc}"
echo -e "Username    : $Login"
echo -e "Password    : $Pass"
echo -e "Expired On  : $exp"
echo -e "${red}=========================================${nc}"
echo -e "IP          : $MYIP"
echo -e "Host        : $domain"
echo -e "SSH         : $ssh"
echo -e "SSH/SSL     : $ssl"
echo -e "${red}=========================================${nc}"
echo -e "${blue}        TRIAL OpenVPN Account           ${nc}"
echo -e "${red}=========================================${nc}"
echo -e "Username    : $Login"
echo -e "Password    : $Pass"
echo -e "Expired On  : $exp"
echo -e "${red}=========================================${nc}"
echo -e "openvpn tcp : https://$domain/openvpn/tcp.ovpn"
echo -e "openvpn udp : https://$domain/openvpn/udp.ovpn"
echo -e "openvpn ssl : https://$domain/openvpn/ssl.ovpn"
echo -e "openvpn zip : https://$domain/openvpn/ovpn.zip"
echo -e "${red}=========================================${nc}"
fi
echo ""
read -n 1 -s -r -p "Press any key to back on menu"
m-sshovpn
