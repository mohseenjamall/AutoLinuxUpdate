#!/bin/bash


RED='\e[1;31m'
GREEN='\e[1;32m'
CYAN='\e[1;36m'
NC='\e[0m' # No Color


clear
figlet -f slant "Blak X"

echo -e "${CYAN}Kali Linux Update Script - v2.0${NC}"
echo -e "Developed by: BlaxkRaven\n"


if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}ERROR: Please run this script as root (use sudo).${NC}"
   exit 1
fi


echo -e "${CYAN}[+] Checking internet connection...${NC}"
if ! ping -c 2 google.com > /dev/null 2>&1; then
    echo -e "${RED}ERROR: No internet connection detected. Please connect and try again.${NC}"
    exit 1
fi


echo -e "${GREEN}Choose an option:${NC}"
echo "1. Update and Upgrade Kali"
echo "2. Clean Kali"
echo "3. Full Update (Update + Upgrade + Clean)"
echo "4. Exit"
read -p "Enter your choice [1-4]: " choice


LOG_FILE="/var/log/kali_update_$(date +%F_%T).log"


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
        echo -e "${CYAN}Exiting. Thanks for using the script!${NC}"
        exit 0
        ;;
    *)
        echo -e "${RED}Invalid choice. Please run again and select 1-4.${NC}"
        exit 1
        ;;
esac

echo -e "\n${CYAN}[+] Log saved to: $LOG_FILE${NC}"
echo -e "${GREEN}Done! Have a great day.${NC}"
