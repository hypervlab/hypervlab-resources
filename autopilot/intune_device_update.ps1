# MS Intune Multi Device Update Script
# Author  : Simon Lee
# Twitter : @smoon_lee
# Blog    : https://hypervlab.co.uk
# Created : 03.12.2020

# Import Intune Powershell SDK
Import-Module -Name 'Install-Module -Name Microsoft.Graph.Intune'

# Connec to MS Intune
# 1. Create the PSCredential object
$adminUPN = Read-Host -Prompt "Enter UPN"
$adminPwd = Read-Host -AsSecureString -Prompt "Enter password for $adminUPN"
$creds = New-Object System.Management.Automation.PSCredential ($adminUPN, $adminPwd)

# 2. Log in with these credentials
Connect-MSGraph -PSCredential $Creds

# Define Devices
$DeviceID = Get-IntuneManagedDevice | Select-Object deviceName, managedDeviceId

ForEach ($Device in $DeviceID) {
    Write-Output "Updating Deivce: $($Device.deviceName)"
    Update-IntuneManagedDevice -managedDeviceId $Device.managedDeviceId

}
