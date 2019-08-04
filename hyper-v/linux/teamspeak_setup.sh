#!/bin/bash 
# Teamspeak3 Automated Installation Script
# Author: Simon Lee
# Script Revision: 1.0
# Description: Automatically download Teamspeak 3

# Check Session Status
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
elif [[ $EUID -eq 0 ]]; then
   echo -e "Session Running as \e[36mROOT\e[0m"
fi

echo "#######################"
echo "# Hyper-V Lab Scripts #"
echo "#  Teamspeak 3 Setup  #"
echo "#######################"

echo Creating Local User: teamspeak 
adduser --disabled-login teamspeak

# Download Teamspeak 3 Server 
echo " Please go to: https://www.teamspeak.com/en/downloads/#server"
echo " and download latest teamspeak3 linux 64x .tar.bz2 file
read -p "Paste Here: " wget
wget $wget -O/home/teamspeak

# Create .ts3server_license_accepted File
touch /home/teamspeak/teamspeak3-server/.ts3server_license_accepted
 
# Change File Ownsership
chown -R teamspeak:teamspeak /home/teamspeak 

# Download Teamspeak3 Service File 
wget https://raw.githubusercontent.com/hypervlab/hypervlab-resources/master/hyper-v/linux/teamspeak.service -O /etc/systemd/system/teamspeak.service

# Configure Service 
systemctl daemon-reload
systemctl enable teamspeak 
systemctl start teamspeak 
