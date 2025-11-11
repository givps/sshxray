#!/bin/bash
# =========================================
# add trojan ws grpc
# =========================================
RED='\033[0;31m'
NC='\033[0m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
LIGHT='\033[0;37m'
# ==========================================
domain=$(cat /usr/local/etc/xray/domain 2>/dev/null || cat /root/domain 2>/dev/null)
MYIP=$(wget -qO- ipv4.icanhazip.com || curl -s ifconfig.me)
tls="$(cat ~/log-install.txt | grep -w "Trojan WS TLS" | cut -d: -f2|sed 's/ //g')"
ntls="$(cat ~/log-install.txt | grep -w "Trojan WS none TLS" | cut -d: -f2|sed 's/ //g')"
until [[ $user =~ ^[a-zA-Z0-9_]+$ && ${user_EXISTS} == '0' ]]; do
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "\E[0;41;36m       add trojan account          \E[0m"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
read -rp "User: " -e user
user_EXISTS=$(grep -w $user /usr/local/etc/xray/config.json | wc -l)
if [[ ${user_EXISTS} == '1' ]]; then
clear
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "\E[0;41;36m       add trojan account          \E[0m"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo ""
echo "A client with the specified name was already created, please choose another name."
echo ""
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
read -n 1 -s -r -p "Press any key to back on menu"
m-trojan
fi
done
uuid=$(cat /proc/sys/kernel/random/uuid)
read -p "Expired (days): " expired
exp=`date -d "$expired days" +"%Y-%m-%d"`
sed -i '/#trojanws$/a\  #1 '"$user $exp"'\n  ,{"password": "'"$uuid"'", "email": "'"$user ($exp)"'"}' "/usr/local/etc/xray/config.json"
sed -i '/#trojangrpc$/a\  #1 '"$user $exp"'\n  ,{"password": "'"$uuid"'", "email": "'"$user ($exp)"'"}' "/usr/local/etc/xray/config.json"
trojanlink="trojan://${uuid}@${domain}:${tls}?path=trojan-ws&security=tls&type=ws&#${user}"
trojanlink1="trojan://${uuid}@${domain}:${ntls}?path=trojan-ws&security=none&type=ws#${user}"
trojanlink2="trojan://${uuid}@${domain}:${tls}?serviceName=trojan-grpc&security=tls&type=grpc#${user}"
systemctl daemon-reload
systemctl restart xray
clear
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m" | tee -a /var/log/xray/trojan.log
echo -e "\E[0;41;36m           trojan account           \E[0m" | tee -a /var/log/xray/trojan.log
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m" | tee -a /var/log/xray/trojan.log
echo -e "Remarks        : ${user}" | tee -a /var/log/xray/trojan.log
echo -e "Host           : ${domain}" | tee -a /var/log/xray/trojan.log
echo -e "IP             : ${MYIP}" | tee -a /var/log/xray/trojan.log
echo -e "Wildcard       : bug.com.${domain}" | tee -a /var/log/xray/trojan.log
echo -e "Port TLS       : ${tls}" | tee -a /var/log/xray/trojan.log
echo -e "Port none TLS  : ${ntls}" | tee -a /var/log/xray/trojan.log
echo -e "Port gRPC      : ${tls}" | tee -a /var/log/xray/trojan.log
echo -e "UUID           : ${uuid}" | tee -a /var/log/xray/trojan.log
echo -e "Network        : ws" | tee -a /var/log/xray/trojan.log
echo -e "Path           : /trojan-ws" | tee -a /var/log/xray/trojan.log
echo -e "ServiceName    : trojan-grpc" | tee -a /var/log/xray/trojan.log
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m" | tee -a /var/log/xray/trojan.log
echo -e "Link TLS       : ${trojanlink}" | tee -a /var/log/xray/trojan.log
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m" | tee -a /var/log/xray/trojan.log
echo -e "Link none TLS  : ${trojanlink1}" | tee -a /var/log/xray/trojan.log
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m" | tee -a /var/log/xray/trojan.log
echo -e "Link gRPC      : ${trojanlink2}" | tee -a /var/log/xray/trojan.log
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m" | tee -a /var/log/xray/trojan.log
echo -e "Expired On     : $exp" | tee -a /var/log/xray/trojan.log
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m" | tee -a /var/log/xray/trojan.log
echo "" | tee -a /var/log/xray/trojan.log
read -n 1 -s -r -p "Press any key to back on menu"
m-trojan
