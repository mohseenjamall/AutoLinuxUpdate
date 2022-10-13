#!/usr/bin/env bash

figlet "AutoUpdateKali"

echo -e "Bl@xkR@ven\n"
echo "$(tput bold)Press ENTER to continue, CTRL+C to abort."
read input

echo -e "\e[1;36m[+] Updating Kali. Please wait.\e[0m"
apt-get update -y > /dev/null && apt-get upgrade -y > /dev/null && apt-get >
echo -e "Kali is now up to date.\n"

echo -e "\e[1;36m[+] Cleaning Kali. Please wait.\e[0m"


apt-get autoclean -y > /dev/null && apt-get clean -y > /dev/null
<adeleon415"

