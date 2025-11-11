#!/bin/bash
# Auto Remove Expired SSH Users
# --------------------------------
LOGFILE="/var/log/expired_ssh_user.log"
mkdir -p "$(dirname "$LOGFILE")"

today=$(date +%s)

awk -v now="$today" -v logfile="$LOGFILE" -F: '
($8 != "" && $8 != 0) {
    user = $1
    expire_date = $8 * 86400
    if (expire_date < now) {
        cmd = "userdel --force " user
        print strftime("[%Y-%m-%d %H:%M:%S]"), "Deleting expired SSH user:", user >> logfile
        system(cmd)
    }
}' /etc/shadow
