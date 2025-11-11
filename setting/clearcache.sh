#!/bin/bash
# =========================================
# Clear RAM Cache
# =========================================
clear
echo ""
echo -e "[ \033[32mINFO\033[0m ] Clearing RAM cache..."
sync
echo 3 > /proc/sys/vm/drop_caches
sleep 1
echo -e "[ \033[32mOK\033[0m ] Cache cleared successfully!"
echo ""
echo "Returning to menu"
menu

