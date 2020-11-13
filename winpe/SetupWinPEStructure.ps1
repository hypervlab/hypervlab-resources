<#
.NAME
    WinPE Media Builder Setup Script

.DESCRIPTION

.AUTHOR
    Simon Lee
    #HypervLAB
    @smoon_lee

.CHANGELOG
    13.11.2020 - Inital Script Created

#>

# Define Setup Directory
$SetupDir = Read-Host -Prompt 'Please Enter Setup Directory Drive Letter (Example: C:\)'
$Folder = 'WinPERoot'
New-Item -ItemType 'Directory' -Path "$SetupDir" + "$Folder"

# Folder Structure
New-Item -ItemType 'Directory' -Path "$SetupDir" + "$Folder" + \ + "Notes"
New-Item -ItemType 'Directory' -Path "$SetupDir" + "$Folder" + \ + "WinPE_Applications"
New-Item -ItemType 'Directory' -Path "$SetupDir" + "$Folder" + \ + "WinPE_Backgrounds"
New-Item -ItemType 'Directory' -Path "$SetupDir" + "$Folder" + \ + "WinPE_Drivers"
New-Item -ItemType 'Directory' -Path "$SetupDir" + "$Folder" + \ + "WinPE_Patches"
New-Item -ItemType 'Directory' -Path "$SetupDir" + "$Folder" + \ + "WinPE_ISO"
New-Item -ItemType 'Directory' -Path "$SetupDir" + "$Folder" + \ + "WinPE_Unattend"

# Download Configure-WinPEImage Script
Invoke-WebRequest -Uri -OutFile $SetupDir" + "$Folder" 

