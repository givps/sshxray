#!/bin/bash
# ==========================================
# install xray & ssl
# ==========================================
# Colors
red='\e[1;31m'
green='\e[0;32m'
yellow='\e[1;33m'
blue='\e[1;34m'
nc='\e[0m'

# Get domain
domain=$(cat /usr/local/etc/xray/domain 2>/dev/null || cat /root/domain 2>/dev/null)
mkdir -p /myinfo
country=$(curl -s https://api.country.is 2>/dev/null | jq -r '.country' 2>/dev/null)
if [[ -z "$country" || "$country" == "null" ]]; then
    country=$(curl -s https://ipinfo.io/json 2>/dev/null | jq -r '.country' 2>/dev/null)
fi
if [[ -z "$country" || "$country" == "null" ]]; then
    country="API limit..."
fi
mkdir -p /myinfo
echo "$country" | tee /myinfo/country > /dev/null

# Install all packages in one command (more efficient)
echo -e "[ ${green}INFO${nc} ] Installing dependencies..."
apt update -y >/dev/null 2>&1
apt install -y \
    iptables iptables-persistent \
    curl python3 socat xz-utils wget apt-transport-https \
    gnupg gnupg2 gnupg1 dnsutils lsb-release \
    cron bash-completion \
    zip pwgen openssl netcat

# Clean up packages
apt clean && apt autoremove -y > /dev/null

# Create directory if doesn't exist and set permissions
rm -f /usr/local/bin/xray
mkdir -p /usr/local/bin /usr/local/etc/xray /var/log/xray
touch /var/log/xray/{access,error}.log
id xray &>/dev/null || useradd -r -s /usr/sbin/nologin xray
# xray official
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install -u xray
# xray version
# Set ownership
chmod +x /usr/local/bin/xray
chown -R root:root /usr/local/bin/xray
chown -R xray:xray /usr/local/etc/xray
chown -R xray:xray /var/log/xray

# nginx stop
systemctl stop nginx

LOG_FILE="/var/log/acme-setup.log"
mkdir -p /var/log
rm -rf /root/.acme.sh
rm -f /usr/local/etc/xray/xray.crt
rm -f /usr/local/etc/xray/xray.key
# Rotate log if >1MB
[ -f "$LOG_FILE" ] && [ "$(stat -c%s "$LOG_FILE")" -gt 1048576 ] && {
  ts=$(date +%Y%m%d-%H%M%S)
  mv "$LOG_FILE" "$LOG_FILE.$ts.bak"
  ls -tp /var/log/acme-setup.log.*.bak 2>/dev/null | tail -n +4 | xargs -r rm --
}

exec > >(tee -a "$LOG_FILE") 2>&1

# ---------- Dependencies ----------
echo -e "[${blue}INFO${nc}] Installing dependencies..."
apt update -y >/dev/null 2>&1
apt install -y curl wget socat cron openssl bash >/dev/null 2>&1

# ---------- Domain ----------
domain=$(cat /usr/local/etc/xray/domain 2>/dev/null || cat /root/domain 2>/dev/null)
[[ -z "$domain" ]] && echo -e "${red}[ERROR] Domain file not found!${nc}" && exit 1

# ---------- Cloudflare Token ----------
DEFAULT_CF_TOKEN="XCu7wHsxlkbcU3GSPOEvl1BopubJxA9kDcr-Tkt8"
read -rp "Enter Cloudflare API Token (ENTER for default): " CF_Token
export CF_Token="${CF_Token:-$DEFAULT_CF_TOKEN}"

# ---------- Retry helper ----------
retry() { local n=1; until "$@"; do ((n++==5)) && exit 1; echo -e "${yellow}Retry $n...${nc}"; sleep 3; done; }

# ---------- Install acme.sh ----------
ACME_HOME="/root/.acme.sh"
if [ ! -f "$ACME_HOME/acme.sh" ]; then
  echo -e "[${green}INFO${nc}] Installing acme.sh official..."
  curl https://get.acme.sh | sh
fi

# Reload ACME_HOME
export ACME_HOME="/root/.acme.sh"

# ---------- Ensure Cloudflare DNS hook ----------
mkdir -p "$ACME_HOME/dnsapi"
[ ! -f "$ACME_HOME/dnsapi/dns_cf.sh" ] && wget -qO "$ACME_HOME/dnsapi/dns_cf.sh" https://raw.githubusercontent.com/acmesh-official/acme.sh/master/dnsapi/dns_cf.sh && chmod +x "$ACME_HOME/dnsapi/dns_cf.sh"

# ---------- Register ACME account ----------
echo -e "[${green}INFO${nc}] Registering ACME account..."
retry bash "$ACME_HOME/acme.sh" --register-account -m ssl@ipgivpn.my.id --server letsencrypt

# ---------- Issue wildcard certificate ----------
echo -e "[${blue}INFO${nc}] Issuing wildcard certificate for ${domain}..."
retry bash "$ACME_HOME/acme.sh" --issue --dns dns_cf -d "$domain" -d "*.$domain" --force --server letsencrypt

# ---------- Install certificate ----------
echo -e "[${blue}INFO${nc}] Installing certificate..."
mkdir -p /usr/local/etc/xray
retry bash "$ACME_HOME/acme.sh" --installcert -d "$domain" \
  --fullchainpath /usr/local/etc/xray/xray.crt \
  --keypath /usr/local/etc/xray/xray.key

# ---------- Auto-renew cron ----------
cat > /etc/cron.d/acme-renew <<EOF
0 3 1 */2 * root $ACME_HOME/acme.sh --cron --home $ACME_HOME > /var/log/acme-renew.log 2>&1
EOF
chmod 644 /etc/cron.d/acme-renew

# ---------- Done ----------
echo -e "[${green}SUCCESS${nc}] ACME.sh + Cloudflare setup completed!"
echo -e "CRT: /usr/local/etc/xray/xray.crt"
echo -e "KEY: /usr/local/etc/xray/xray.key"
chmod 600 /usr/local/etc/xray/xray.key
chown -R xray:xray /usr/local/etc/xray/xray.key

# Auto-detect Xray SSL and convert
XRAY_DIR="/usr/local/etc/xray"
# Cari file SSL Xray
CERT=$(find $XRAY_DIR -name "*.crt" -o -name "*.pem" -o -name "fullchain.cer" | head -1)
KEY=$(find $XRAY_DIR -name "*.key" -o -name "private.key" | head -1)

mkdir -p /etc/stunnel
# convert from xray
if [ -f "$CERT" ] && [ -f "$KEY" ]; then
cat "$CERT" "$KEY" > /etc/stunnel/stunnel.pem
chmod 600 /etc/stunnel/stunnel.pem
echo "✅ SSL converted from Xray"
else
# make a certificate
openssl genrsa -out key.pem 2048
openssl req -new -x509 -key key.pem -out cert.pem -days 3650 \
-subj "/C=ID/ST=Jakarta/L=Jakarta/O=givps/OU=IT/CN=localhost/emailAddress=admin@localhost"
cat key.pem cert.pem > /etc/stunnel/stunnel.pem
chmod 600 /etc/stunnel/stunnel.pem
echo "✅ Use Self-signed SSL"
fi

uuid=$(cat /proc/sys/kernel/random/uuid)
cat > /usr/local/etc/xray/config.json <<EOF
{
  "log": {
    "access": "/var/log/xray/access.log",
    "error": "/var/log/xray/error.log",
    "loglevel": "info"
  },
  "inbounds": [
    {
      "listen": "127.0.0.1",
      "port": 10050,
      "protocol": "dokodemo-door",
      "settings": {
        "address": "127.0.0.1"
      },
      "tag": "api"
    },
    {
      "tag": "vless-ws",
      "listen": "127.0.0.1",
      "port": 10001,
      "protocol": "vless",
      "settings": {
        "clients": [
          { "id": "$uuid" }
#vlessws
        ],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "ws",
        "wsSettings": { "path": "/vless-ws" }
      }
    },
    {
      "tag": "vmess-ws",
      "listen": "127.0.0.1",
      "port": 10002,
      "protocol": "vmess",
      "settings": {
        "clients": [
          { "id": "$uuid" }
#vmessws
        ]
      },
      "streamSettings": {
        "network": "ws",
        "wsSettings": { "path": "/vmess-ws" }
      }
    },
    {
      "tag": "trojan-ws",
      "listen": "127.0.0.1",
      "port": 10003,
      "protocol": "trojan",
      "settings": {
        "clients": [
          { "password": "$uuid" }
#trojanws
        ]
      },
      "streamSettings": {
        "network": "ws",
        "wsSettings": { "path": "/trojan-ws" }
      }
    },
    {
      "tag": "vless-grpc",
      "listen": "127.0.0.1",
      "port": 10011,
      "protocol": "vless",
      "settings": {
        "clients": [
          { "id": "$uuid" }
#vlessgrpc
        ],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "grpc",
        "grpcSettings": { "serviceName": "vless-grpc" }
      }
    },
    {
      "tag": "vmess-grpc",
      "listen": "127.0.0.1",
      "port": 10012,
      "protocol": "vmess",
      "settings": {
        "clients": [
          { "id": "$uuid" }
#vmessgrpc
        ]
      },
      "streamSettings": {
        "network": "grpc",
        "grpcSettings": { "serviceName": "vmess-grpc" }
      }
    },
    {
      "tag": "trojan-grpc",
      "listen": "127.0.0.1",
      "port": 10013,
      "protocol": "trojan",
      "settings": {
        "clients": [
          { "password": "$uuid" }
#trojangrpc
        ]
      },
      "streamSettings": {
        "network": "grpc",
        "grpcSettings": { "serviceName": "trojan-grpc" }
      }
    }
  ],
  "outbounds": [
    {
      "protocol": "freedom",
      "settings": {}
    },
    {
      "protocol": "freedom",
      "settings": {},
      "tag": "api"
    },
    {
      "protocol": "blackhole",
      "settings": {},
      "tag": "blocked"
    }
  ],
  "routing": {
    "rules": [
      {
        "type": "field",
        "ip": [
          "0.0.0.0/8",
          "10.0.0.0/8",
          "100.64.0.0/10",
          "169.254.0.0/16",
          "172.16.0.0/12",
          "192.0.0.0/24",
          "192.0.2.0/24",
          "192.168.0.0/16",
          "198.18.0.0/15",
          "198.51.100.0/24",
          "203.0.113.0/24",
          "::1/128",
          "fc00::/7",
          "fe80::/10"
        ],
        "outboundTag": "blocked"
      },
      {
        "type": "field",
        "inboundTag": ["api"],
        "outboundTag": "api"
      },
      {
        "type": "field",
        "protocol": ["bittorrent"],
        "outboundTag": "blocked"
      }
    ]
  },
  "stats": {},
  "api": {
    "services": [
      "StatsService"
    ],
    "tag": "api"
  },
  "policy": {
    "levels": {
      "0": {
        "statsUserDownlink": true,
        "statsUserUplink": true
      }
    },
    "system": {
      "statsInboundUplink": true,
      "statsInboundDownlink": true,
      "statsOutboundUplink": true,
      "statsOutboundDownlink": true
    }
  }
}
EOF

cat > /etc/systemd/system/xray.service <<EOF
[Unit]
Description=Xray Service
Documentation=https://github.com/xtls
After=network.target nss-lookup.target

[Service]
User=xray
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
NoNewPrivileges=true

ExecStart=/usr/local/bin/xray run -config /usr/local/etc/xray/config.json
Restart=on-failure
RestartPreventExitStatus=23
LimitNPROC=10000
LimitNOFILE=1000000

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable xray
systemctl start xray

# nginx
cat > /etc/nginx/conf.d/xray.conf <<'EOF'
server {
    listen 127.0.0.1:8080;
    server_name _;

    location /vless-ws {
        proxy_pass http://127.0.0.1:10001;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_buffering off;
        proxy_request_buffering off;
    }

    location /vmess-ws {
        proxy_pass http://127.0.0.1:10002;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_buffering off;
        proxy_request_buffering off;
    }

    location /trojan-ws {
        proxy_pass http://127.0.0.1:10003;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_buffering off;
        proxy_request_buffering off;
    }
}

server {
    listen 127.0.0.1:4433 ssl http2;
    server_name _;

    ssl_certificate /usr/local/etc/xray/xray.crt;
    ssl_certificate_key /usr/local/etc/xray/xray.key;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-CHACHA20-POLY1305:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384;
    ssl_prefer_server_ciphers on;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 1h;
    ssl_session_tickets off;
    resolver 1.1.1.1 8.8.8.8 valid=300s;
    resolver_timeout 5s;

    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "no-referrer-when-downgrade" always;

    location /vless-ws {
        proxy_pass http://127.0.0.1:10001;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_buffering off;
        proxy_request_buffering off;
    }

    location /vmess-ws {
        proxy_pass http://127.0.0.1:10002;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_buffering off;
        proxy_request_buffering off;
    }

    location /trojan-ws {
        proxy_pass http://127.0.0.1:10003;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_buffering off;
        proxy_request_buffering off;
    }

    location /vless-grpc {
        grpc_pass grpc://127.0.0.1:10011;
        client_max_body_size 0;
        grpc_set_header X-Real-IP $remote_addr;
        grpc_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        grpc_set_header Host $host;
        proxy_buffering off;
    }

    location /vmess-grpc {
        grpc_pass grpc://127.0.0.1:10012;
        client_max_body_size 0;
        grpc_set_header X-Real-IP $remote_addr;
        grpc_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        grpc_set_header Host $host;
        proxy_buffering off;
    }

    location /trojan-grpc {
        grpc_pass grpc://127.0.0.1:10013;
        client_max_body_size 0;
        grpc_set_header X-Real-IP $remote_addr;
        grpc_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        grpc_set_header Host $host;
        proxy_buffering off;
    }
}
EOF

# Reload systemd and start Xray
systemctl daemon-reload
systemctl enable nginx
systemctl start nginx

cd /usr/bin/
wget -q -O add-vmess "https://raw.githubusercontent.com/givps/sshxray/master/xray/vmess/add-vmess.sh" && chmod +x add-vmess
wget -q -O trial-vmess "https://raw.githubusercontent.com/givps/sshxray/master/xray/vmess/trial-vmess.sh" && chmod +x trial-vmess
wget -q -O renew-vmess "https://raw.githubusercontent.com/givps/sshxray/master/xray/vmess/renew-vmess.sh" && chmod +x renew-vmess
wget -q -O del-vmess "https://raw.githubusercontent.com/givps/sshxray/master/xray/vmess/del-vmess.sh" && chmod +x del-vmess
wget -q -O cek-vmess "https://raw.githubusercontent.com/givps/sshxray/master/xray/vmess/cek-vmess.sh" && chmod +x cek-vmess
wget -q -O m-vmess "https://raw.githubusercontent.com/givps/sshxray/master/xray/vmess/m-vmess.sh" && chmod +x m-vmess

wget -O add-vless "https://raw.githubusercontent.com/givps/sshxray/master/xray/vless/add-vless.sh" && chmod +x add-vless
wget -O trial-vless "https://raw.githubusercontent.com/givps/sshxray/master/xray/vless/trial-vless.sh" && chmod +x trial-vless
wget -O renew-vless "https://raw.githubusercontent.com/givps/sshxray/master/xray/vless/renew-vless.sh" && chmod +x renew-vless
wget -O del-vless "https://raw.githubusercontent.com/givps/sshxray/master/xray/vless/del-vless.sh" && chmod +x del-vless
wget -O cek-vless "https://raw.githubusercontent.com/givps/sshxray/master/xray/vless/cek-vless.sh" && chmod +x cek-vless
wget -O m-vless "https://raw.githubusercontent.com/givps/sshxray/master/xray/vless/m-vless.sh" && chmod +x m-vless

wget -O add-trojan "https://raw.githubusercontent.com/givps/sshxray/master/xray/trojan/add-trojan.sh" && chmod +x add-trojan
wget -O renew-trojan "https://raw.githubusercontent.com/givps/sshxray/master/xray/trojan/renew-trojan.sh" && chmod +x renew-trojan
wget -O trial-trojan "https://raw.githubusercontent.com/givps/sshxray/master/xray/trojan/trial-trojan.sh" && chmod +x trial-trojan
wget -O del-trojan "https://raw.githubusercontent.com/givps/sshxray/master/xray/trojan/del-trojan.sh" && chmod +x del-trojan
wget -O cek-trojan "https://raw.githubusercontent.com/givps/sshxray/master/xray/trojan/cek-trojan.sh" && chmod +x cek-trojan
wget -O m-trojan "https://raw.githubusercontent.com/givps/sshxray/master/xray/trojan/m-trojan.sh" && chmod +x m-trojan
wget -O xpxray "https://raw.githubusercontent.com/givps/sshxray/master/xray/trojan/xpxray.sh" && chmod +x xpxray
wget -O xray-log "https://raw.githubusercontent.com/givps/sshxray/master/xray/trojan/xray-log.sh" && chmod +x xray-log
cd

cat > /etc/cron.d/xpxray_otm <<EOF
SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
0 0 * * * root /usr/bin/xpxray
0 1 * * 0 /sbin/reboot
EOF
