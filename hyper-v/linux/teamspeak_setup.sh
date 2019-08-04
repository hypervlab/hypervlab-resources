#!/bin/bash
# Teamspeak3 Automated Installation Script
# Author: Simon Lee
# Script Revision: 1.0
# Description: Automatically download Teamspeak 3

# Clear Screen
clear

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

echo ""
echo "Creating Local Teamspeak User Account"
adduser --disabled-login --gecos "Teamspeak Service Account" teamspeak

# Download Teakspeak Service
echo ""
echo "Download Teamspeak Server"
echo "Please go to: https://www.teamspeak.com/en/downloads/#server "
echo "and download the latest server"
echo ""

read -p "Paste Here: " wget
cd /home/teamspeak
wget $wget -P /home/teamspeak/
tar xvf /home/teamspeak/teamspeak3-server_linux*
mv /home/teamspeak/teamspeak3-server_linux_amd64 /home/teamspeak/teamspeak3-server
rm -rf /home/teamspeak/teamspeak3-server_linux*

# Create EULA Acceptance File
touch /home/teamspeak/teamspeak3-server/.ts3server_license_accepted

# Change File Onwership to: teamspeak
chown -R teamspeak:teamspeak /home/teamspeak

# Downkload Teamspeak 3 Service
echo ""
echo "#####################################"
echo " Downloading Teamspeak3 Service File "
echo "##################################### "
wget https://raw.githubusercontent.com/hypervlab/hypervlab-resources/master/hyper-v/linux/teamspeak.service -O /etc/systemd/system/teamspeak.service

# Configure Teamspeak Service
echo ""
echo "###############################"
echo " Configuring Teamspeak Service "
echo "###############################"
echo ""

sudo systemctl daemon-reload
echo "System Daemon Reloaded..."
sudo systemctl enable teamspeak
echo "Teamspeak Service Enabled"
sudo systemctl start teamspeak
echo "Teamspeak Service Started"
echo ""
echo "Waiting for Server to Start..."
sleep 15

systemctl status teamspeak

# Self Cleanup
rm -r /tmp/teamspeak_setup.sh 
