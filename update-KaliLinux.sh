#!/usr/bin/env bash

figlet "AutoUpdateKali"

clear
echo "Description: This Bash script will update, upgrade current or prior Kali installations."
echo "" && sleep 3
echo "Updating sources.list..."  && sleep 4

cat <<EOF > /etc/apt/sources.list 
# Update /etc/apt/sources.list
deb http://http.kali.org/kali kali-rolling main contrib non-free
# For source package access, uncomment the following line
deb-src http://http.kali.org/kali kali-rolling main contrib non-free
# For legacy Sana repositories activate these
#deb http://http.kali.org/kali sana main non-free contrib
#deb http://security.kali.org/kali-security sana/updates main contrib non-free
# For source package access, uncomment the following line
#deb-src http://http.kali.org/kali sana main non-free contrib
#deb-src http://security.kali.org/kali-security sana/updates main contrib non-free
EOF

##;// Main
function Main {
    echo "Fixing prior install issues..."  && sleep 4 && \
    apt-get -f install -fy
    echo "Updating sources from repositories..."  && sleep 4 && \
    apt-get update
    echo "Upgrading installed sources..."  && sleep 4 && \
    apt-get upgrade -fy
    echo "Upgrading distribution from repositories..."  && sleep 4 && \
    apt-get dist-upgrade -y
    echo "Automatically removing unused sources..."  && sleep 4 && \
    apt-get autoremove -fy
    echo "Automatically cleaning up cached sources..."  && sleep 4 && \
    apt-get autoclean -y
    echo "Using dpkg to auto-configure packages..."  && sleep 4 && \
    dpkg --configure -a
}

Main 

echo -e "\e[1;36m[+] Kali is now less dirty... Follow me on Twitter @MohsenJamall"

exit 0

