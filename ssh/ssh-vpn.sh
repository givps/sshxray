#!/bin/bash
# =========================================
# install ssh
# =========================================

# PAM configuration
wget -q -O /etc/pam.d/common-password "https://raw.githubusercontent.com/givps/sshxray/master/ssh/password"
chmod +x /etc/pam.d/common-password

# setup sshd
cat > /etc/ssh/sshd_config <<EOF
Port 22
Port 2222
PermitRootLogin yes
PasswordAuthentication yes
PermitEmptyPasswords no
PubkeyAuthentication yes
AllowTcpForwarding yes
PermitTTY yes
X11Forwarding no
TCPKeepAlive yes
ClientAliveInterval 300
ClientAliveCountMax 2
MaxAuthTries 3
MaxSessions 10
MaxStartups 10:30:100
UsePAM yes
ChallengeResponseAuthentication no
UseDNS no
Compression delayed
GSSAPIAuthentication no
SyslogFacility AUTH
LogLevel INFO
EOF

# Download banner
BANNER_URL="https://raw.githubusercontent.com/givps/sshxray/master/ssh/banner.conf"
BANNER_FILE="/etc/issue.net"
wget -q -O "$BANNER_FILE" "$BANNER_URL"
if ! grep -q "^Banner $BANNER_FILE" /etc/ssh/sshd_config; then
    echo "Banner $BANNER_FILE" >> /etc/ssh/sshd_config
fi

grep -qxF "/bin/false" /etc/shells || echo "/bin/false" >> /etc/shells
grep -qxF "/usr/sbin/nologin" /etc/shells || echo "/usr/sbin/nologin" >> /etc/shells

systemctl restart sshd
systemctl enable sshd

# ==============================================
# SSLH Multi-port Installer
# ==============================================
# Update system & install dependencies
apt update -y
apt install -y sslh wget build-essential libconfig-dev iproute2
# Buat systemd service type = simple/forking
cat > /etc/systemd/system/sslh.service <<'EOF'
[Unit]
Description=SSL/SSH/OpenVPN/XMPP/tinc port multiplexer
After=network.target

[Service]
Type=simple
ExecStartPre=/bin/mkdir -p /run/sslh
ExecStartPre=/bin/chown root:root /run/sslh
ExecStart=/usr/sbin/sslh \
  --listen 0.0.0.0:443 \
  --listen 0.0.0.0:80 \
  --ssh 127.0.0.1:2222 \
  --openvpn 127.0.0.1:1196 \
  --tls 127.0.0.1:4433 \
  --http 127.0.0.1:8080 \
  --on-timeout tls \
  --timeout 2 \
  --pidfile /run/sslh/sslh.pid \
  --foreground
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd dan start service
systemctl daemon-reload
systemctl enable sslh
systemctl start sslh

# install stunnel
apt install -y stunnel4

cat > /etc/stunnel/stunnel.conf <<EOF
pid = /var/run/stunnel.pid
cert = /etc/stunnel/stunnel.pem
client = no
socket = a:SO_REUSEADDR=1
socket = l:TCP_NODELAY=1
socket = r:TCP_NODELAY=1

[ssh-tls]
accept = 222
connect = 127.0.0.1:2222

[openvpn-tls]
accept = 8443
connect = 127.0.0.1:1196
EOF

# make a certificate
openssl genrsa -out key.pem 2048
openssl req -new -x509 -key key.pem -out cert.pem -days 3650 \
-subj "/C=ID/ST=Jakarta/L=Jakarta/O=givps/OU=IT/CN=localhost/emailAddress=admin@localhost"
cat key.pem cert.pem > /etc/stunnel/stunnel.pem
chmod 600 /etc/stunnel/stunnel.pem

cat > /etc/default/stunnel4 <<EOF
ENABLED=1
FILES="/etc/stunnel/*.conf"
OPTIONS=""
PPP_RESTART=0
EOF

systemctl daemon-reload
systemctl enable stunnel4
systemctl start stunnel4

cd /usr/bin
# ssh menu
wget -O m-sshovpn "https://raw.githubusercontent.com/givps/sshxray/master/ssh/m-sshovpn.sh"
wget -O usernew "https://raw.githubusercontent.com/givps/sshxray/master/ssh/usernew.sh"
wget -O trial "https://raw.githubusercontent.com/givps/sshxray/master/ssh/trial.sh"
wget -O renew "https://raw.githubusercontent.com/givps/sshxray/master/ssh/renew.sh"
wget -O delete "https://raw.githubusercontent.com/givps/sshxray/master/ssh/delete.sh"
wget -O cek "https://raw.githubusercontent.com/givps/sshxray/master/ssh/cek.sh"
wget -O member "https://raw.githubusercontent.com/givps/sshxray/master/ssh/member.sh"
wget -O autodelete "https://raw.githubusercontent.com/givps/sshxray/master/ssh/autodelete.sh"
wget -O autokill "https://raw.githubusercontent.com/givps/sshxray/master/ssh/autokill.sh"
wget -O autokick "https://raw.githubusercontent.com/givps/sshxray/master/ssh/autokick.sh"
wget -O ceklim "https://raw.githubusercontent.com/givps/sshxray/master/ssh/ceklim.sh"
wget -O lock-unlock "https://raw.githubusercontent.com/givps/sshxray/master/ssh/lock-unlock.sh"
wget -O xp "https://raw.githubusercontent.com/givps/sshxray/master/ssh/xp.sh"
wget -O cek-openvpn "https://raw.githubusercontent.com/givps/sshxray/master/openvpn/cek-openvpn.sh"

chmod +x m-sshovpn
chmod +x usernew
chmod +x trial
chmod +x renew
chmod +x delete
chmod +x cek
chmod +x member
chmod +x autodelete
chmod +x autokill
chmod +x autokick
chmod +x ceklim
chmod +x lock-unlock
chmod +x xp
chmod +x cek-openvpn

cat > /etc/cron.d/xp_otm <<EOF
SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
0 0 * * * root /usr/bin/xp
EOF
