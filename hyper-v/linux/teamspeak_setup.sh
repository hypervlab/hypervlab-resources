#!/bin/bash
# Teamspeak3 Automated Installation Script
# Author: Simon Lee
# Script Revision: 1.0
# Description: Automatically download Teamspeak 3

# Clear Screen
Clear

# Check Session Status
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
elif [[ $EUID -eq 0 ]]; then
   echo -e "Session Running as \e[36mROOT\e[0m"
fi

