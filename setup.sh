#!/bin/bash
# =========================================
# setup
# =========================================

# color
red='\e[1;31m'
green='\e[0;32m'
yellow='\e[1;33m'
blue='\e[1;34m'
white='\e[1;37m'
nc='\e[0m'

cd
rm -f log-install.txt
rm -f cf.sh
rm -f tool.sh
rm -f ssh-vpn.sh
rm -f openvpn.sh
rm -f ins-xray.sh

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    print_error "Script need run AS root...!"
    exit 1
fi

# Detect OS
if [ -f /etc/debian_version ]; then
    OS="debian"
elif [ -f /etc/lsb-release ]; then
    OS="ubuntu"
else
    print_error "OS Not Support. Script for OS Debian/Ubuntu."
    exit 1
fi

echo "Setting timezone to Asia/Jakarta..."
timedatectl set-timezone Asia/Jakarta
echo "Timezone set:"
timedatectl | grep "Time zone"

echo "Enabling NTP..."
timedatectl set-ntp true

timedatectl status | grep -E "NTP enabled|NTP synchronized"

mkdir -p /usr/local/etc/xray
mkdir -p /etc/log

MYIP=$(wget -qO- ipv4.icanhazip.com || curl -s ifconfig.me)
clear
echo -e "${red}=========================================${nc}"
echo -e "${green}     CUSTOM SETUP DOMAIN VPS     ${nc}"
echo -e "${red}=========================================${nc}"
echo -e "${white}1${nc} Use Domain From Script"
echo -e "${white}2${nc} Use Own Your Domain"
echo -e "${red}=========================================${nc}"
read -rp "Choose Your Domain Installation 1/2 : " dom 

if [[ $dom -eq 1 ]]; then
    clear
    rm -f /root/cf.sh
    wget -q -O /root/cf.sh "https://raw.githubusercontent.com/givps/sshxray/master/setting/cf.sh"
    chmod +x /root/cf.sh && bash /root/cf.sh

elif [[ $dom -eq 2 ]]; then
    read -rp "Enter Your Domain : " domen
    rm -f /usr/local/etc/xray/domain /root/domain
    echo "$domen" | tee /usr/local/etc/xray/domain /root/domain >/dev/null

    echo -e "\n${yellow}Checking DNS record for ${domen}...${nc}"
    DNS_IP=$(dig +short A "$domen" @1.1.1.1 | head -n1)

    if [[ -z "$DNS_IP" ]]; then
        echo -e "${red}No DNS record found for ${domen}.${nc}"
    elif [[ "$DNS_IP" != "$MYIP" ]]; then
        echo -e "${yellow}⚠ Domain does not point to this VPS.${nc}"
        echo -e "Your VPS IP: ${green}$MYIP${nc}"
        echo -e "Current DNS IP: ${red}$DNS_IP${nc}"
    else
        echo -e "${green}✅ Domain already points to this VPS.${nc}"
    fi

    # If not pointing, offer Cloudflare API creation
    if [[ "$DNS_IP" != "$MYIP" ]]; then
        echo -e "\n${yellow}Would you like to create an A record on Cloudflare using API Token?${nc}"
        read -rp "Create record automatically? (y/n): " ans
        if [[ "$ans" == "y" || "$ans" == "Y" ]]; then
            read -rp "Enter your Cloudflare API Token: " CF_API
            read -rp "Enter your Cloudflare Zone Name / Primary Domain Name (e.g. example.com): " CF_ZONE
            ZONE_ID=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones?name=${CF_ZONE}" \
                -H "Authorization: Bearer ${CF_API}" \
                -H "Content-Type: application/json" | jq -r '.result[0].id')

            if [[ -z "$ZONE_ID" || "$ZONE_ID" == "null" ]]; then
                echo -e "${red}Failed to get Zone ID. Please check your token and zone name.${nc}"
            else
                echo -e "${green}Zone ID found: ${ZONE_ID}${nc}"
                # Create or update DNS record
                RECORD_ID=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/${ZONE_ID}/dns_records?name=${domen}" \
                    -H "Authorization: Bearer ${CF_API}" \
                    -H "Content-Type: application/json" | jq -r '.result[0].id')

                if [[ "$RECORD_ID" == "null" || -z "$RECORD_ID" ]]; then
                    echo -e "${yellow}Creating new A record for ${domen}...${nc}"
                    curl -s -X POST "https://api.cloudflare.com/client/v4/zones/${ZONE_ID}/dns_records" \
                        -H "Authorization: Bearer ${CF_API}" \
                        -H "Content-Type: application/json" \
                        --data "{\"type\":\"A\",\"name\":\"${domen}\",\"content\":\"${MYIP}\",\"ttl\":120,\"proxied\":false}" >/dev/null
                else
                    echo -e "${yellow}Updating existing A record for ${domen}...${nc}"
                    curl -s -X PUT "https://api.cloudflare.com/client/v4/zones/${ZONE_ID}/dns_records/${RECORD_ID}" \
                        -H "Authorization: Bearer ${CF_API}" \
                        -H "Content-Type: application/json" \
                        --data "{\"type\":\"A\",\"name\":\"${domen}\",\"content\":\"${MYIP}\",\"ttl\":120,\"proxied\":false}" >/dev/null
                fi
                echo -e "${green}✅ DNS record set to ${MYIP}${nc}"
            fi
        fi
    fi
else 
    echo -e "${red}Wrong Argument${nc}"
    exit 1
fi
echo -e "${green}Done${nc}"

echo -e "${red}=========================================${nc}"
echo -e "${blue}             Install TOOL           ${nc}"
echo -e "${red}=========================================${nc}"
#install tool
wget https://raw.githubusercontent.com/givps/sshxray/master/setting/tool.sh && chmod +x tool.sh && ./tool.sh

echo -e "${red}=========================================${nc}"
echo -e "${blue}             Install SSH           ${nc}"
echo -e "${red}=========================================${nc}"
#install ssh
wget https://raw.githubusercontent.com/givps/sshxray/master/ssh/ssh-vpn.sh && chmod +x ssh-vpn.sh && ./ssh-vpn.sh

echo -e "${red}=========================================${nc}"
echo -e "${blue}             Install XRAY              ${nc}"
echo -e "${red}=========================================${nc}"
#Instal Xray
wget https://raw.githubusercontent.com/givps/sshxray/master/xray/ins-xray.sh && chmod +x ins-xray.sh && ./ins-xray.sh

echo -e "${red}=========================================${nc}"
echo -e "${blue}             Install OpenVPN           ${nc}"
echo -e "${red}=========================================${nc}"
#install openvpn
wget https://raw.githubusercontent.com/givps/sshxray/master/openvpn/openvpn.sh && chmod +x openvpn.sh && ./openvpn.sh

apt install -y netfilter-persistent iptables-persistent
systemctl enable netfilter-persistent
systemctl start netfilter-persistent
# Allow loopback
iptables -C INPUT -i lo -j ACCEPT 2>/dev/null || \
iptables -I INPUT -i lo -j ACCEPT
# Allow established connections
iptables -C INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT 2>/dev/null || \
iptables -I INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
# Allow SSH
iptables -C INPUT -p tcp --dport 22 -j ACCEPT 2>/dev/null || \
iptables -I INPUT -p tcp --dport 22 -j ACCEPT
iptables -C INPUT -p tcp --dport 2222 -j ACCEPT 2>/dev/null || \
iptables -I INPUT -p tcp --dport 2222 -j ACCEPT
iptables -C INPUT -p tcp --dport 222 -j ACCEPT 2>/dev/null || \
iptables -I INPUT -p tcp --dport 222 -j ACCEPT
# Allow HTTP/HTTPS
iptables -C INPUT -p tcp --dport 80 -j ACCEPT 2>/dev/null || \
iptables -I INPUT -p tcp --dport 80 -j ACCEPT
iptables -C INPUT -p tcp --dport 443 -j ACCEPT 2>/dev/null || \
iptables -I INPUT -p tcp --dport 443 -j ACCEPT
iptables -C INPUT -p tcp --dport 8443 -j ACCEPT 2>/dev/null || \
iptables -I INPUT -p tcp --dport 8443 -j ACCEPT
# Allow nginx
iptables -C INPUT -p tcp -s 127.0.0.1 --dport 4433 -j ACCEPT 2>/dev/null || \
iptables -I INPUT -p tcp -s 127.0.0.1 --dport 4433 -j ACCEPT
iptables -C INPUT -p tcp --dport 4433 -j DROP 2>/dev/null || \
iptables -A INPUT -p tcp --dport 4433 -j DROP
iptables -C INPUT -p tcp -s 127.0.0.1 --dport 8080 -j ACCEPT 2>/dev/null || \
iptables -I INPUT -p tcp -s 127.0.0.1 --dport 8080 -j ACCEPT
iptables -C INPUT -p tcp --dport 8080 -j DROP 2>/dev/null || \
iptables -A INPUT -p tcp --dport 8080 -j DROP

netfilter-persistent save
# chattr +i /etc/iptables/rules.v4
netfilter-persistent reload

echo ""
echo -e "========================================="  | tee -a ~/log-install.txt
echo -e "          Service Information            "  | tee -a ~/log-install.txt
echo -e "========================================="  | tee -a ~/log-install.txt
echo ""
echo "   - OpenSSH                  : 22, 2222"  | tee -a ~/log-install.txt
echo "   - Stunnel4                 : 222" | tee -a ~/log-install.txt
echo "   - OpenVPN                  : 443, 1195, 51825" | tee -a ~/log-install.txt
echo "   - Nginx                    : 80, 443" | tee -a ~/log-install.txt
echo "   - Vmess WS TLS             : 443" | tee -a ~/log-install.txt
echo "   - Vless WS TLS             : 443" | tee -a ~/log-install.txt
echo "   - Trojan WS TLS            : 443" | tee -a ~/log-install.txt
echo "   - Vmess WS none TLS        : 80" | tee -a ~/log-install.txt
echo "   - Vless WS none TLS        : 80" | tee -a ~/log-install.txt
echo "   - Trojan WS none TLS       : 80" | tee -a ~/log-install.txt
echo "   - Vmess gRPC               : 443" | tee -a ~/log-install.txt
echo "   - Vless gRPC               : 443" | tee -a ~/log-install.txt
echo "   - Trojan gRPC              : 443" | tee -a ~/log-install.txt
echo ""
echo -e "=========================================" | tee -a ~/log-install.txt
echo -e "               t.me/givps_com            "  | tee -a ~/log-install.txt
echo -e "=========================================" | tee -a ~/log-install.txt
echo ""
echo -e "Auto reboot in 10 seconds..."
sleep 10
clear
reboot
