#!/bin/bash
# =========================================
# Renew Trojan WS/GRPC
# =========================================
BLUE='\033[0;34m'; NC='\033[0m'; BBLUE='\E[44;1;39m'

CONFIG="/usr/local/etc/xray/config.json"

clear
clients=$(grep -cE "^[[:space:]]*#1 " "$CONFIG")
if [[ $clients == 0 ]]; then
  echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${BBLUE}        Renew Trojan Account       ${NC}"
  echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "\nNo existing client found.\n"
  echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
  read -n1 -s -r -p "Press any key to return..."
  m-trojan
  exit
fi

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BBLUE}        Renew Trojan Account       ${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
grep -E "^[[:space:]]*#1 " "$CONFIG" | nl -s ') '
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

read -rp "Input Username : " user
[[ -z $user ]] && echo "Cancelled." && m-trojan && exit

read -rp "Extend for (days): " days
[[ -z $days ]] && echo "Invalid input." && exit 1

exp=$(grep -wE "^#1[[:space:]]+$user" "$CONFIG" | awk '{print $3}' | head -n1)
[[ -z $exp ]] && echo "User '$user' not found!" && exit 1

now=$(date +%Y-%m-%d)
exp_new=$(date -d "$exp +$days days" +%Y-%m-%d)

sed -i "s|^#1 $user $exp|#1 $user $exp_new|" "$CONFIG"

systemctl daemon-reload
systemctl restart xray

clear
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BBLUE}     Trojan Account Renewed        ${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "   • Username : $user"
echo -e "   • Old Exp  : $exp"
echo -e "   • New Exp  : $exp_new"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
read -n1 -s -r -p "Press any key to return to menu..."
m-trojan
