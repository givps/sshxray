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
clear
tls="$(cat ~/log-install.txt | grep -w "Trojan WS TLS" | cut -d: -f2|sed 's/ //g')"
ntls="$(cat ~/log-install.txt | grep -w "Trojan WS none TLS" | cut -d: -f2|sed 's/ //g')"
user=trial`</dev/urandom tr -dc a-z0-9 | head -c5`
uuid=$(cat /proc/sys/kernel/random/uuid)
expired=1
exp=`date -d "$expired days" +"%Y-%m-%d"`
sed -i '/#trojanws$/a\  #1 '"$user $exp"'\n  ,{"password": "'"$uuid"'", "email": "'"$user ($exp)"'"}' "/usr/local/etc/xray/config.json"
sed -i '/#trojangrpc$/a\  #1 '"$user $exp"'\n  ,{"password": "'"$uuid"'", "email": "'"$user ($exp)"'"}' "/usr/local/etc/xray/config.json"
trojanlink="trojan://${uuid}@${domain}:${tls}?path=trojan-ws&security=tls&type=ws&#${user}"
trojanlink1="trojan://${uuid}@${domain}:${ntls}?path=trojan-ws&security=none&type=ws#${user}"
trojanlink2="trojan://${uuid}@${domain}:${tls}?serviceName=trojan-grpc&security=tls&type=grpc#${user}"
systemctl daemon-reload
systemctl restart xray
clear
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "\E[0;41;36m           TRIAL TROJAN           \E[0m"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "Remarks        : ${user}"
echo -e "Host           : ${domain}"
echo -e "IP             : ${MYIP}"
echo -e "Wildcard       : bug.com.${domain}"
echo -e "Port TLS       : ${tls}"
echo -e "Port none TLS  : ${ntls}"
echo -e "Port gRPC      : ${tls}"
echo -e "Key            : ${uuid}"
echo -e "Path           : /trojan-ws"
echo -e "ServiceName    : trojan-grpc"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "Link TLS       : ${trojanlink}"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "Link none TLS  : ${trojanlink1}"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "Link gRPC      : ${trojanlink2}"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "Expired On     : $exp"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo ""
read -n 1 -s -r -p "Press any key to back on menu"
m-trojan
