#!/bin/bash
# Simple, portable realtime pretty-tail for /var/log/auth.log
LOG="/var/log/auth.log"
[ -f "$LOG" ] || { echo "Log not found: $LOG"; exit 1; }

# color codes
R=$(printf '\033[1;31m')   # red
G=$(printf '\033[1;32m')   # green
Y=$(printf '\033[1;33m')   # yellow
B=$(printf '\033[1;34m')   # blue
C=$(printf '\033[1;36m')   # cyan
N=$(printf '\033[0m')      # reset

# follow log and pretty print
stdbuf -oL tail -F "$LOG" | while IFS= read -r line; do
  # human timestamp (use current time because some log lines already have timestamp)
  ts=$(date +"%Y-%m-%d %H:%M:%S")

  msg="$line"

  # extract host/IP: prefer rhost= value, fallback to "from <IP>"
  host="-"
  host=$(echo "$msg" | sed -n 's/.*rhost=\([^ ]*\).*/\1/p')
  if [ -z "$host" ]; then
    host=$(echo "$msg" | sed -n 's/.*from \([0-9]\{1,3\}\(\.[0-9]\{1,3\}\)\{3\}\).*/\1/p')
  fi
  [ -z "$host" ] && host="-"

  icon=" "
  color="$N"

  if echo "$msg" | grep -qE 'Failed password|authentication failure|Maximum authentication attempts|authentication error'; then
    icon="✖"; color="$R"
  elif echo "$msg" | grep -qE 'Invalid user'; then
    icon="⚠"; color="$Y"
  elif echo "$msg" | grep -qE 'Accepted publickey|Accepted password'; then
    icon="✔"; color="$G"
  elif echo "$msg" | grep -qE 'session opened|session closed'; then
    icon="⊕"; color="$C"
  elif echo "$msg" | grep -qE 'sudo:'; then
    icon="⚑"; color="$B"
  fi

echo -e "${G} CTRL +C To EXIT ${N}"
  # print: timestamp, host, icon, colored message
  printf "%s %-15s %-2s %b%s%b\n" "$ts" "$host" "$icon" "$color" "$msg" "$N"
done
m-sshovpn
