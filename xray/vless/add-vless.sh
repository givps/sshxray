#!/bin/bash
# =========================================
# add vless ws grpc
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
tls="$(cat ~/log-install.txt | grep -w "Vless WS TLS" | cut -d: -f2|sed 's/ //g')"
ntls="$(cat ~/log-install.txt | grep -w "Vless WS none TLS" | cut -d: -f2|sed 's/ //g')"
until [[ $user =~ ^[a-zA-Z0-9_]+$ && ${CLIENT_EXISTS} == '0' ]]; do
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "\E[44;1;39m      add vless account      \E[0m"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
read -rp "User: " -e user
CLIENT_EXISTS=$(grep -w $user /usr/local/etc/xray/config.json | wc -l)
if [[ ${CLIENT_EXISTS} == '1' ]]; then
clear
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "\E[44;1;39m      add vless account      \E[0m"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo ""
echo "A client with the specified name was already created, please choose another name."
echo ""
read -n 1 -s -r -p "Press any key to back on menu"
m-vless
fi
done
uuid=$(cat /proc/sys/kernel/random/uuid)
read -p "Expired (days): " expired
exp=`date -d "$expired days" +"%Y-%m-%d"`
sed -i '/#vlessws$/a\  #2 '"$user $exp"'\n  ,{"id": "'"$uuid"'", "email": "'"$user ($exp)"'"}' "/usr/local/etc/xray/config.json"
sed -i '/#vlessgrpc$/a\  #2 '"$user $exp"'\n  ,{"id": "'"$uuid"'", "email": "'"$user ($exp)"'"}' "/usr/local/etc/xray/config.json"
vlesslink1="vless://${uuid}@${domain}:$tls?path=/vless-ws&security=tls&type=ws#${user}"
vlesslink2="vless://${uuid}@${domain}:$ntls?path=/vless-ws&security=none&type=ws#${user}"
vlesslink3="vless://${uuid}@${domain}:$tls?serviceName=vless-grpc&security=tls&type=grpc#${user}"
systemctl daemon-reload
systemctl restart xray
clear
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m" | tee -a /var/log/xray/vless.log
echo -e "\E[44;1;39m         vless account             \E[0m" | tee -a /var/log/xray/vless.log
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m" | tee -a /var/log/xray/vless.log
echo -e "Remarks        : ${user}" | tee -a /var/log/xray/vless.log
echo -e "Host           : ${domain}" | tee -a /var/log/xray/vless.log
echo -e "IP             : ${MYIP}" | tee -a /var/log/xray/vless.log
echo -e "Wildcard       : bug.com.${domain}" | tee -a /var/log/xray/vless.log
echo -e "Port TLS       : $tls" | tee -a /var/log/xray/vless.log
echo -e "Port none TLS  : $ntls" | tee -a /var/log/xray/vless.log
echo -e "Port gRPC      : $tls" | tee -a /var/log/xray/vless.log
echo -e "UUID           : ${uuid}" | tee -a /var/log/xray/vless.log
echo -e "Network        : ws" | tee -a /var/log/xray/vless.log
echo -e "Path           : /vless-ws" | tee -a /var/log/xray/vless.log
echo -e "ServiceName    : vless-grpc" | tee -a /var/log/xray/vless.log
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m" | tee -a /var/log/xray/vless.log
echo -e "Link TLS       : ${vlesslink1}" | tee -a /var/log/xray/vless.log
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m" | tee -a /var/log/xray/vless.log
echo -e "Link none TLS  : ${vlesslink2}" | tee -a /var/log/xray/vless.log
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m" | tee -a /var/log/xray/vless.log
echo -e "Link gRPC      : ${vlesslink3}" | tee -a /var/log/xray/vless.log
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m" | tee -a /var/log/xray/vless.log
echo -e "Expired On     : $exp" | tee -a /var/log/xray/vless.log
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m" | tee -a /var/log/xray/vless.log
echo "" | tee -a /var/log/xray/vless.log
read -n 1 -s -r -p "Press any key to back on menu"
m-vless
