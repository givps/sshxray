#!/bin/bash
# =========================================
# add vmess ws grpc
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
tls="$(cat ~/log-install.txt | grep -w "Vmess WS TLS" | cut -d: -f2|sed 's/ //g')"
none="$(cat ~/log-install.txt | grep -w "Vmess WS none TLS" | cut -d: -f2|sed 's/ //g')"
until [[ $user =~ ^[a-zA-Z0-9_]+$ && ${CLIENT_EXISTS} == '0' ]]; do
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "\\E[0;41;36m      add vmess account      \E[0m"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
read -rp "User: " -e user
CLIENT_EXISTS=$(grep -w $user /usr/local/etc/xray/config.json | wc -l)
if [[ ${CLIENT_EXISTS} == '1' ]]; then
clear
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "\\E[0;41;36m      add vmess account      \E[0m"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo ""
echo "A client with the specified name was already created, please choose another name."
echo ""
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
read -n 1 -s -r -p "Press any key to back on menu"
m-vmess
fi
done
uuid=$(cat /proc/sys/kernel/random/uuid)
read -p "Expired (days): " expired
exp=`date -d "$expired days" +"%Y-%m-%d"`
sed -i '/#vmessws$/a\  #3 '"$user $exp"'\n  ,{"id": "'"$uuid"'", "email": "'"$user ($exp)"'"}' "/usr/local/etc/xray/config.json"
sed -i '/#vmessgrpc$/a\  #3 '"$user $exp"'\n  ,{"id": "'"$uuid"'", "email": "'"$user ($exp)"'"}' "/usr/local/etc/xray/config.json"
wstls=`cat<<EOF
      {
      "v": "2",
      "ps": "${user}",
      "add": "${domain}",
      "port": "443",
      "id": "${uuid}",
      "aid": "0",
      "net": "ws",
      "path": "/vmess-ws",
      "type": "none",
      "host": "",
      "tls": "tls"
}
EOF`
wsnontls=`cat<<EOF
      {
      "v": "2",
      "ps": "${user}",
      "add": "${domain}",
      "port": "80",
      "id": "${uuid}",
      "aid": "0",
      "net": "ws",
      "path": "/vmess-ws",
      "type": "none",
      "host": "",
      "tls": "none"
}
EOF`
grpc=`cat<<EOF
      {
      "v": "2",
      "ps": "${user}",
      "add": "${domain}",
      "port": "443",
      "id": "${uuid}",
      "aid": "0",
      "net": "grpc",
      "path": "vmess-grpc",
      "type": "none",
      "host": "",
      "tls": "tls"
}
EOF`
vmess_base641=$( base64 -w 0 <<< $vmess_json1)
vmess_base642=$( base64 -w 0 <<< $vmess_json2)
vmess_base643=$( base64 -w 0 <<< $vmess_json3)
vmesslink1="vmess://$(echo $wstls | base64 -w 0)"
vmesslink2="vmess://$(echo $wsnontls | base64 -w 0)"
vmesslink3="vmess://$(echo $grpc | base64 -w 0)"
systemctl daemon-reload
systemctl restart xray
service cron restart > /dev/null 2>&1
clear
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m" | tee -a /var/log/xray/vmess.log
echo -e "\\E[0;41;36m        vmess account        \E[0m" | tee -a /var/log/xray/vmess.log
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m" | tee -a /var/log/xray/vmess.log
echo -e "Remarks        : ${user}" | tee -a /var/log/xray/vmess.log
echo -e "Host           : ${domain}" | tee -a /var/log/xray/vmess.log
echo -e "IP             : ${MYIP}" | tee -a /var/log/xray/vmess.log
echo -e "Wildcard       : bug.com.${domain}" | tee -a /var/log/xray/vmess.log
echo -e "Port TLS       : ${tls}" | tee -a /var/log/xray/vmess.log
echo -e "Port none TLS  : ${none}" | tee -a /var/log/xray/vmess.log
echo -e "Port gRPC      : ${tls}" | tee -a /var/log/xray/vmess.log
echo -e "UUID           : ${uuid}" | tee -a /var/log/xray/vmess.log
echo -e "alterId        : 0" | tee -a /var/log/xray/vmess.log
echo -e "Security       : auto" | tee -a /var/log/xray/vmess.log
echo -e "Network        : ws" | tee -a /var/log/xray/vmess.log
echo -e "Path           : /vmess-ws" | tee -a /var/log/xray/vmess.log
echo -e "ServiceName    : vmess-grpc" | tee -a /var/log/xray/vmess.log
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m" | tee -a /var/log/xray/vmess.log
echo -e "Link TLS       : ${vmesslink1}" | tee -a /var/log/xray/vmess.log
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m" | tee -a /var/log/xray/vmess.log
echo -e "Link none TLS  : ${vmesslink2}" | tee -a /var/log/xray/vmess.log
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m" | tee -a /var/log/xray/vmess.log
echo -e "Link gRPC      : ${vmesslink3}" | tee -a /var/log/xray/vmess.log
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m" | tee -a /var/log/xray/vmess.log
echo -e "Expired On     : $exp" | tee -a /var/log/xray/vmess.log
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m" | tee -a /var/log/xray/vmess.log
echo "" | tee -a /var/log/xray/vmess.log
read -n 1 -s -r -p "Press any key to back on menu"
m-vmess
