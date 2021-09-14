
<#
.NAME
    Automated Oh-My-Posh Deployment

.AUTHOR
  user   :  Simon Lee
  twitter:  @smoon_lee
    
.CHANGELOG
  13.08.2021 - Script Release Version 1.0
  14.09.2021 - Script Debugged for Profile Selection - Version 1.1
  14.09.2021 - Fixed PackageProvider Silent Prompt - Version 1.1.1
#>

# Script Version
$Version = '1.1.1'

# Script Title
$host.ui.RawUI.WindowTitle = "Oh-My-Posh Setup v:$Version "

# Check PowerShell Repository 
If ((Get-PSRepository -Name PSGallery).InstallationPolicy -ne 'Trusted') {
    Write-Warning -Message 'PSGallery Policy: Untrusted'
    Write-Output 'Configuring to Trusted Policy'
    Write-Output 'Installing Latest NuGet Package Provider'
    Install-PackageProvider -Name PowershellGet -Force | Out-Null
    Install-PackageProvider -Name 'NuGet' -Force | Out-Null
    Set-PSRepository -Name 'PSGallery' -InstallationPolicy 'Trusted' 
    Write-Warning -Message 'PSGallery Policy: Trusted'
}

# Install Oh-My-Posh Module
Write-Output 'Checking Oh-My-Posh Module'
If (!(Get-Module -ListAvailable -Name 'Oh-My-Posh' -ErrorAction SilentlyContinue)) {
    Write-Warning -Message 'No Oh-My-Posh Module Detected!'
    Write-Output "Installing Lastest Oh-My-Posh Module - v$((Find-Module -Name 'Oh-My-Posh').Version) "
    Install-Module -Name 'Oh-My-Posh' ; Import-Module -Name 'Oh-My-Posh' 

}
ElseIf ((Get-Module -ListAvailable -Name 'Oh-My-Posh').Version -ne (Find-Module -Name 'Oh-My-Posh').Version) {
    Write-Warning -Message "Oh-My-Posh Module Update available! - Installed:$((Get-Module -ListAvailable -Name 'Oh-My-Posh').Version) Avaible:$((Find-Module -Name 'Oh-My-Posh').Version)"
    $PendingUpdate = Read-Host 'Do you wish to update? [Y/N]'
    If ($PendingUpdate -eq 'Y') {
        Uninstall-Module -Name 'Oh-My-Posh' ; Install-Module -Name 'Oh-My-Posh' 
        Write-Output "Oh-My-Posh Module Updated! - v$((Get-Module -ListAvailable -Name 'Oh-My-Posh').Version)" `r
    }
    Else {
        Write-Output 'Oh-My-Posh Module Update Skipped' `r
    }
}

# Check for NerdFonts on Local System
Write-Warning -Message 'Checking Local System for NerdFonts'
Write-Output ''
If (!(Get-ItemProperty -Path 'C:\Windows\Fonts\*' | Where-Object Name -Match 'Nerd Font')) {
    Write-Warning -Message 'No Nerd Fonts Detected... Lanching Nerd Fonts Website'
    Start-Process -FilePath 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe' -ArgumentList 'https://www.nerdfonts.com/font-downloads'
}

# Checking for Nerd Font File Loop
While (!(Get-ItemProperty -Path 'C:\Windows\Fonts\*' | Where-Object Name -Match 'Nerd Font')) {

    Write-Output 'Checking for Nerd Font Files...'
    Start-Sleep -Seconds 5
}

# Posh Theme Selection
Get-PoshThemes
$PoshTheme = Read-Host -Prompt 'Please Enter Theme Name'

# Create PowerShell Profile based on Version
# PowerShell 5.x 'C:\Users\$User\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1'
# PowerShell 7.x 'C:\Users\$User\Documents\PowerShell\Microsoft.PowerShell_profile.ps1'
# VSCode         'C:\Users\$User\Documents\Documents\PowerShell\Microsoft.VSCode_profile.ps1'

If ($PSVersionTable.PSVersion -like '5.1*') {
    Write-Output ''
    Write-Warning 'PowerShell 5.x Detected'
    $PoshProfile = "$([Environment]::GetFolderPath("MyDocuments"))\WindowsPowerShell\Microsoft.PowerShell_profile.ps1"

    # Create Oh-My-Posh Profile
    Write-Output 'Creating PowerShell Profile File'
    "Import-Module -Name 'Oh-My-Posh'
    Set-PoshPrompt -Theme $PoshTheme
    " | Set-Content -Path $PoshProfile
    (Get-Content $PoshProfile).Trim() | Set-Content $PoshProfile

    # Create Symbolic Link for VSCode
    New-Item -ItemType SymbolicLink -Target $PoshProfile -Path "$([Environment]::GetFolderPath("MyDocuments"))\PowerShell\Microsoft.PowerShell_profile.ps1" -Force | Out-Null
    New-Item -ItemType SymbolicLink -Target $PoshProfile -Path "$([Environment]::GetFolderPath("MyDocuments"))\PowerShell\Microsoft.VSCode_profile.ps1" -Force | Out-Null

    # Verbose - Setup Complete
    Write-Output 'Oh-My-Posh Configured and Profile Reloading...'
    . $Profile

}

If ($PSVersionTable.PSVersion -like '7.1*') {
    Write-Output ''
    Write-Warning 'Powershell 7.x Detected'
    $PoshProfile = "$([Environment]::GetFolderPath("MyDocuments"))\PowerShell\Microsoft.PowerShell_profile.ps1"

    # Create Oh-My-Posh Profile
    Write-Output  'Creating PowerShell Profile File'
    "Import-Module -Name 'Oh-My-Posh'
    Set-PoshPrompt -Theme $PoshTheme
    " | Set-Content -Path $PoshProfile
    (Get-Content $PoshProfile).Trim() | Set-Content $PoshProfile

    # Create Symbolic Link for VSCode
    New-Item -ItemType SymbolicLink -Target $PoshProfile -Path "$([Environment]::GetFolderPath("MyDocuments"))\WindowsPowerShell\Microsoft.PowerShell_profile.ps1" -Force | Out-Null
    New-Item -ItemType SymbolicLink -Target $PoshProfile -Path "$([Environment]::GetFolderPath("MyDocuments"))\PowerShell\Microsoft.VSCode_profile.ps1" -Force | Out-Null

    # Verbose - Setup Complete
    Write-Output 'Oh-My-Posh Configured and Profile Reloading...'
    . $Profile

}
