#!/bin/bash
# log brute force 
clear
LOG="/var/log/auth.log"
[ -f "$LOG" ] || { echo "Log not found: $LOG"; exit 1; }

# warna
R=$(printf '\033[1;31m')
G=$(printf '\033[1;32m')
Y=$(printf '\033[1;33m')
B=$(printf '\033[1;34m')
C=$(printf '\033[1;36m')
N=$(printf '\033[0m')

echo -e "${C}=== auth-tail: monitoring /var/log/auth.log (Ctrl+C to exit) ===${N}"

stdbuf -oL tail -F "$LOG" | while IFS= read -r line; do
  # hanya baris penting
  if ! echo "$line" | grep -qE 'Failed password|authentication failure|Invalid user|Accepted|session opened|session closed|sudo:'; then
    continue
  fi

  ts=$(date +"%Y-%m-%d %H:%M:%S")
  msg="$line"

  # ambil host
  host=$(echo "$msg" | sed -n 's/.*rhost=\([^ ]*\).*/\1/p')
  if [ -z "$host" ]; then
    host=$(echo "$msg" | sed -n 's/.*from \([0-9]\{1,3\}\(\.[0-9]\{1,3\}\)\{3\}\).*/\1/p')
  fi
  [ -z "$host" ] && host="-"

  icon=" "
  color="$N"

  if echo "$msg" | grep -qE 'Failed password|authentication failure'; then
    icon="✖"; color="$R"
  elif echo "$msg" | grep -qE 'Invalid user'; then
    icon="⚠"; color="$Y"
  elif echo "$msg" | grep -qE 'Accepted'; then
    icon="✔"; color="$G"
  elif echo "$msg" | grep -qE 'session opened|session closed'; then
    icon="⊕"; color="$C"
  elif echo "$msg" | grep -qE 'sudo:'; then
    icon="⚑"; color="$B"
  fi

  printf "%s %-15s %-2s %b%s%b\n" "$ts" "$host" "$icon" "$color" "$msg" "$N"
done
m-system
