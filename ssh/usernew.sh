#!/bin/bash
# =========================================
# CREATE SSH & openvpn USER
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

echo -e "${red}=========================================${nc}"
echo -e "${blue}            SSH Account            ${nc}"
echo -e "${red}=========================================${nc}"
[ "$(id -u)" -ne 0 ] && echo "Run as root" >&2 && exit 1
read -p "Username: " Login
read -s -p "Password (Press Enter to auto-generate): " Pass; echo
read -p "Expire in (days): " d
[ -z "$Pass" ] && Pass=$(openssl rand -base64 24 | tr '+/' '-_' | tr -d '=')
exp=$(date -d "+${d} days" +%Y-%m-%d)
id "$Login" &>/dev/null && { echo "User already exists" >&2; exit 1; }
useradd -e "$exp" -s /bin/false -M "$Login"
echo "$Login:$Pass" | chpasswd
printf "\nUser: %s\nPass: %s\nExpires: %s\n" "$Login" "$Pass" "$exp"
clear
if [[ ! -z "${PID}" ]]; then
echo -e "${red}=========================================${nc}" | tee -a /var/log/create-ssh.log
echo -e "${blue}            SSH Account            ${nc}" | tee -a /var/log/create-ssh.log
echo -e "${red}=========================================${nc}" | tee -a /var/log/create-ssh.log
echo -e "Username    : $Login" | tee -a /var/log/create-ssh.log
echo -e "Password    : $Pass" | tee -a /var/log/create-ssh.log
echo -e "Expired On  : $exp" | tee -a /var/log/create-ssh.log
echo -e "${red}=========================================${nc}" | tee -a /var/log/create-ssh.log
echo -e "IP          : $MYIP" | tee -a /var/log/create-ssh.log
echo -e "Host        : $domain" | tee -a /var/log/create-ssh.log
echo -e "SSH         : $ssh" | tee -a /var/log/create-ssh.log
echo -e "SSH/SSL     : $ssl" | tee -a /var/log/create-ssh.log
echo -e "${red}=========================================${nc}" | tee -a /var/log/create-ssh.log
echo -e "${blue}            OpenVPN Account            ${nc}" | tee -a /var/log/create-ssh.log
echo -e "${red}=========================================${nc}" | tee -a /var/log/create-ssh.log
echo -e "Username    : $Login" | tee -a /var/log/create-ssh.log
echo -e "Password    : $Pass" | tee -a /var/log/create-ssh.log
echo -e "Expired On  : $exp" | tee -a /var/log/create-ssh.log
echo -e "${red}=========================================${nc}" | tee -a /var/log/create-ssh.log
echo -e "openvpn tcp : https://$domain/openvpn/tcp.ovpn" | tee -a /var/log/create-ssh.log
echo -e "openvpn udp : https://$domain/openvpn/udp.ovpn" | tee -a /var/log/create-ssh.log
echo -e "openvpn ssl : https://$domain/openvpn/ssl.ovpn" | tee -a /var/log/create-ssh.log
echo -e "openvpn zip : https://$domain/openvpn/ovpn.zip" | tee -a /var/log/create-ssh.log
echo -e "${red}=========================================${nc}" | tee -a /var/log/create-ssh.log
else

echo -e "${red}=========================================${nc}" | tee -a /var/log/create-ssh.log
echo -e "${blue}            SSH Account            ${nc}" | tee -a /var/log/create-ssh.log
echo -e "${red}=========================================${nc}" | tee -a /var/log/create-ssh.log
echo -e "Username    : $Login" | tee -a /var/log/create-ssh.log
echo -e "Password    : $Pass" | tee -a /var/log/create-ssh.log
echo -e "Expired On  : $exp" | tee -a /var/log/create-ssh.log
echo -e "${red}=========================================${nc}" | tee -a /var/log/create-ssh.log
echo -e "IP          : $MYIP" | tee -a /var/log/create-ssh.log
echo -e "Host        : $domain" | tee -a /var/log/create-ssh.log
echo -e "SSH         : $ssh" | tee -a /var/log/create-ssh.log
echo -e "SSH/SSL     : $ssl" | tee -a /var/log/create-ssh.log
echo -e "${red}=========================================${nc}" | tee -a /var/log/create-ssh.log
echo -e "${blue}            OpenVPN Account            ${nc}" | tee -a /var/log/create-ssh.log
echo -e "${red}=========================================${nc}" | tee -a /var/log/create-ssh.log
echo -e "Username    : $Login" | tee -a /var/log/create-ssh.log
echo -e "Password    : $Pass" | tee -a /var/log/create-ssh.log
echo -e "Expired On  : $exp" | tee -a /var/log/create-ssh.log
echo -e "${red}=========================================${nc}" | tee -a /var/log/create-ssh.log
echo -e "openvpn tcp : https://$domain/openvpn/tcp.ovpn" | tee -a /var/log/create-ssh.log
echo -e "openvpn udp : https://$domain/openvpn/udp.ovpn" | tee -a /var/log/create-ssh.log
echo -e "openvpn ssl : https://$domain/openvpn/ssl.ovpn" | tee -a /var/log/create-ssh.log
echo -e "openvpn zip : https://$domain/openvpn/ovpn.zip" | tee -a /var/log/create-ssh.log
echo -e "${red}=========================================${nc}" | tee -a /var/log/create-ssh.log
fi
echo "" | tee -a /var/log/create-ssh.log
read -n 1 -s -r -p "Press any key to back on menu"
m-sshovpn
