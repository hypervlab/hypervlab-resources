<#
.NAME
    WinPE Media Builder Setup Script

.DESCRIPTION
    WinPE Default Root Setup Script 

.AUTHOR
    Simon Lee
    #HypervLAB - https://hypervlab.co.uk
    @smoon_lee

.CHANGELOG
    13.11.2020 - Inital Script Created

#>

# Define Setup Directory
$SetupDir = Read-Host -Prompt 'Please Enter Setup Directory Drive Letter (Example: C:\)'
$Folder = 'WinPEBuilder'
New-Item -ItemType 'Directory' -Path $("$SetupDir\$Folder")

# Folder Structure
New-Item -ItemType 'Directory' -Path $("$SetupDir\$Folder\Notes")
New-Item -ItemType 'Directory' -Path $("$SetupDir\$Folder\WinPE_Applications")
New-Item -ItemType 'Directory' -Path $("$SetupDir\$Folder\WinPE_Backgrounds")
New-Item -ItemType 'Directory' -Path $("$SetupDir\$Folder\WinPE_Drivers")
New-Item -ItemType 'Directory' -Path $("$SetupDir\$Folder\WinPE_ISO")
New-Item -ItemType 'Directory' -Path $("$SetupDir\$Folder\WinPE_Patches")
New-Item -ItemType 'Directory' -Path $("$SetupDir\$Folder\WinPE_Unattend")


# Download Configure-WinPEImage Script
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/hypervlab/hypervlab-resources/master/winpe/Configure-WinPEImage.ps1" -OutFile $("$SetupDir\$Folder\Configure-WinPEImage.ps1")