#!/bin/bash

# تحديد الألوان
RED='\e[1;31m'
GREEN='\e[1;32m'
CYAN='\e[1;36m'
NC='\e[0m' # No Color

# تنظيف الشاشة وعرض العنوان
clear
figlet -f slant "Blak X"

echo -e "${CYAN}Full Linux Update Script - v2.0${NC}"
echo -e "Developed by: BlaxkRaven\n"

# فحص صلاحيات root
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}ERROR: Please run this script as root (use sudo).${NC}"
   exit 1
fi

# فحص الاتصال بالإنترنت
echo -e "${CYAN}[+] Checking internet connection...${NC}"
if ! ping -c 2 google.com > /dev/null 2>&1; then
    echo -e "${RED}ERROR: No internet connection detected. Please connect and try again.${NC}"
    exit 1
fi

# قائمة الخيارات
echo -e "${GREEN}Choose an option:${NC}"
echo "1. Update and Upgrade Kali"
echo "2. Clean Kali"
echo "3. Full Update (Kali Linux)"
echo "4. Full Update (Ubuntu)"
echo "5. Exit"
read -p "Enter your choice [1-5]: " choice

# ملف السجل
LOG_FILE="/var/log/auto_update_$(date +%F_%T).log"

# تنفيذ الخيارات
case $choice in
    1)
        echo -e "${CYAN}[+] Updating Kali, please wait...${NC}"
        apt-get update -y && apt-get upgrade -y 2>> "$LOG_FILE"
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}Kali updated successfully!${NC}"
        else
            echo -e "${RED}Update failed. Check $LOG_FILE for details.${NC}"
        fi
        ;;
    2)
        echo -e "${CYAN}[+] Cleaning Kali, please wait...${NC}"
        apt-get autoclean -y && apt-get clean -y 2>> "$LOG_FILE"
        echo -e "${GREEN}Kali cleaned successfully!${NC}"
        ;;
    3)
        echo -e "${CYAN}[+] Performing full update, please wait...${NC}"
        apt-get update -y && apt-get upgrade -y && apt-get dist-upgrade -y && apt-get autoclean -y && apt-get clean -y 2>> "$LOG_FILE"
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}Full update completed successfully!${NC}"
        else
            echo -e "${RED}Full update failed. Check $LOG_FILE for details.${NC}"
        fi
        ;;
    4)
        echo -e "${CYAN}[+] Performing full update with autoremove, please wait...${NC}"
        apt-get update -y && apt-get upgrade -y && apt-get dist-upgrade -y && apt-get autoclean -y && apt-get clean -y && apt-get autoremove -y 2>> "$LOG_FILE"
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}Full update with autoremove completed successfully!${NC}"
        else
            echo -e "${RED}Full update with autoremove failed. Check $LOG_FILE for details.${NC}"
        fi
        ;;
    5)
        echo -e "${CYAN}Exiting. Thanks for using the script!${NC}"
        exit 0
        ;;
    *)
        echo -e "${RED}Invalid choice. Please run again and select 1-5.${NC}"
        exit 1
        ;;
esac

echo -e "\n${CYAN}[+] Log saved to: $LOG_FILE${NC}"
echo -e "${GREEN}Done! Have a great day.${NC}"
