#!/bin/bash
# =========================================
# auto delete xray user expired
# =========================================
#----- Auto Remove Trojan
for u in $(grep '^[[:space:]]*#1 ' /usr/local/etc/xray/config.json | awk '{print $2,$3}'); do
  user=$(echo $u | awk '{print $1}')
  exp=$(echo $u | awk '{print $2}')
  if [[ $(date -d "$exp" +%s) -le $(date +%s) ]]; then
    sed -i "/^#1 $user $exp/,/^},{/d" /usr/local/etc/xray/config.json
    echo "Removed expired Trojan user: $user ($exp)"
  fi
done

#----- Auto Remove Vless
for u in $(grep '^[[:space:]]*#2 ' /usr/local/etc/xray/config.json | awk '{print $2,$3}'); do
  user=$(echo $u | awk '{print $1}')
  exp=$(echo $u | awk '{print $2}')
  if [[ $(date -d "$exp" +%s) -le $(date +%s) ]]; then
    sed -i "/^#1 $user $exp/,/^},{/d" /usr/local/etc/xray/config.json
    echo "Removed expired Trojan user: $user ($exp)"
  fi
done

##----- Auto Remove Vmess
for u in $(grep '^[[:space:]]*#3 ' /usr/local/etc/xray/config.json | awk '{print $2,$3}'); do
  user=$(echo $u | awk '{print $1}')
  exp=$(echo $u | awk '{print $2}')
  if [[ $(date -d "$exp" +%s) -le $(date +%s) ]]; then
    sed -i "/^#1 $user $exp/,/^},{/d" /usr/local/etc/xray/config.json
    echo "Removed expired Trojan user: $user ($exp)"
  fi
done
systemctl restart xray >/dev/null 2>&1
