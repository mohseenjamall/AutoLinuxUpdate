#!/usr/bin/env bash

clear
figlet "Blak X"

echo -e "Kali Linux Upadte Script"

echo "press Enter to continue, CTRL+C to exit."

read input

echo -e "\e[1;36m[+] Updating Kali, Please wait.\e[0m"

apt-get update -y > /dev/null && apt-get upgrade -y > /dev/null && apt-get dist-upgrade -y > >
echo -e "Kali is now up to date. \n"

echo -e  "\e[1;36m[+] Updating Kali, Please wait.\e[0m"

apt-get autoclean -y > /dev/null && apt-get clean -y > /dev/null
echo -e "\e[1;36m[+] Kali is now less dirty.."
echo -e "\n \e[1;36m[+] Thanks to use Script .."
