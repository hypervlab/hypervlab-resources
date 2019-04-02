#!/bin/bash 
# Microsoft Hyper-V Intergration Services (Ubuntu/Debian Install Script)
# Author: Simon Lee
# Script Revision: 1.0
# Description: Install linux-virtual kernal for Ubuntu/Debian Server

# Clear Current Screen
clear

# Check Session Status
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
elif [[ $EUID -eq 0 ]]; then
   echo -e "Session Running as \e[36mROOT\e[0m"
fi

# Update Local System Packages 
apt update && apt -y upgrade

# Add hv_modules to /etc/initramfs-tools/modules
echo 'hv_vmbus' >> /etc/initramfs-tools/modules
echo 'hv_storvsc' >> /etc/initramfs-tools/modules
echo 'hv_blkvsc' >> /etc/initramfs-tools/modules
echo 'hv_netvsc' >> /etc/initramfs-tools/modules

# Replace Out of Box Kernal with linux-virtual
apt -y install linux-virtual linux-cloud-tools-virtual linux-tools-virtual

# Update Initramfs
update-initramfs -u

# Reboot Server
reboot
