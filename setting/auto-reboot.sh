#!/bin/bash
# =========================================
# auto reboot
# =========================================
#!/bin/bash
BRed='\e[1;31m'
BGreen='\e[1;32m'
BYellow='\e[1;33m'
BBlue='\e[1;34m'
BPurple='\e[1;35m'
NC='\e[0m'

if [ ! -f /usr/local/bin/auto_reboot ]; then
cat > /usr/local/bin/auto_reboot <<'EOF'
#!/bin/bash
date=$(date +"%m-%d-%Y")
time=$(date +"%T")
echo "Server successfully rebooted on $date at $time." >> /root/log-reboot.txt
/sbin/shutdown -r now
EOF
chmod +x /usr/local/bin/auto_reboot
fi

clear
echo -e "\e[1;33m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\e[0m"
echo -e "\e[1;34m         AUTO-REBOOT MENU           \e[0m"
echo -e "\e[1;33m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\e[0m"
echo ""
echo -e "\e[1;35m 1 \e[0m Set Auto-Reboot Every 1 Day"
echo -e "\e[1;35m 2 \e[0m Set Auto-Reboot Every 1 Week"
echo -e "\e[1;35m 3 \e[0m Set Auto-Reboot Every 1 Month"
echo -e "\e[1;35m 4 \e[0m Turn off Auto-Reboot"
echo -e "\e[1;35m 5 \e[0m View Reboot Log"
echo -e "\e[1;35m 6 \e[0m Remove Reboot Log"
echo -e "\e[1;35m 0 \e[0m Back To Menu"
echo ""
read -p " Select menu : " x

case $x in
1)
  echo "10 0 * * * root /usr/local/bin/auto_reboot" > /etc/cron.d/auto_reboot
  echo "Auto-Reboot has been set every day."
  ;;
2)
  echo "10 0 */7 * * root /usr/local/bin/auto_reboot" > /etc/cron.d/auto_reboot
  echo "Auto-Reboot has been set every week."
  ;;
3)
  echo "10 0 1 * * root /usr/local/bin/auto_reboot" > /etc/cron.d/auto_reboot
  echo "Auto-Reboot has been set every month."
  ;;
4)
  rm -f /etc/cron.d/auto_reboot
  echo "Auto-Reboot successfully turned off."
  ;;
5)
  if [ -f /root/log-reboot.txt ]; then
    cat /root/log-reboot.txt
  else
    echo "No reboot activity found."
  fi
  ;;
6)
  > /root/log-reboot.txt
  echo "Auto-Reboot log successfully deleted."
  ;;
0)
  clear
  m-system
  ;;
*)
  echo "Option not found!"
  ;;
esac

echo ""
read -n 1 -s -r -p "Press any key to back on menu"
auto-reboot
