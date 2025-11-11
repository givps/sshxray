# debian/ubuntu

# install

- 1
```
apt update && apt upgrade -y && apt autoremove -y && reboot
```
- 2
```
apt update && apt install -y bzip2 gzip coreutils screen curl unzip && wget https://raw.githubusercontent.com/givps/sshxray/master/setup.sh && chmod +x setup.sh && sed -i -e 's/\r$//' setup.sh && screen -S setup ./setup.sh
```

# Port :
<br>
- OpenSSH                  : 22, 2222<br>
- Stunnel4                 : 222<br>
- OpenVPN                  : 443, 1195, 51825<br>
- Nginx                    : 80, 443<br>
- Vmess WS TLS             : 443<br>
- Vless WS TLS             : 443<br>
- Trojan WS TLS            : 443<br>
- Vmess WS none TLS        : 80<br>
- Vless WS none TLS        : 80<br>
- Trojan WS none TLS       : 80<br>
- Vmess gRPC               : 443<br>
- Vless gRPC               : 443<br>
- Trojan gRPC              : 443<br>
<br>
