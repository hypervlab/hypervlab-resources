<#
.NAME
    Automated Oh-My-Posh Deployment

.AUTHOR
    Simon Lee
    @smoon_lee
    
.CHANGELOG
  13.08.2021 - Script Release Version 1.0

#>

# Check Powershell Gallery Installation Policy 
Write-Output 'Checking Powershell Gallery Installation Policy' `r
If ((Get-PSRepository -Name PSGallery).InstallationPolicy -ne 'Trusted' ) {
    Write-Warning 'InstallationPolicy is not Trusted!'
    Install-PackageProvider -Name 'NuGet' -Force | Out-Null
    Write-Output 'NuGet Package Providor Installed'
    Set-PSRepository -Name 'PSGallery' -InstallationPolicy 'Trusted' 
    Write-Output 'InstallationPolicy Update - now Trusted'
}
Else {
    Write-Warning 'InstallationPolicy is Trusted!'
}

# Checking Windows Fonts for 'Nerd Font'
# https://ohmyposh.dev/docs/fonts
If (!(Get-ItemProperty C:\Windows\Fonts\* | Where-Object  Name -Like *Nerd*)) {
    Write-Warning 'No Nerd Fonts Found '
    Start-Process "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe" -ArgumentList 'https://www.nerdfonts.com/font-downloads'
    # Wait
    Write-Output -NoNewLine 'Press any key to continue...';
    $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
}

# Installing Oh-My-Posh 
If (!(Get-Module -ListAvailable -Name 'Oh-My-Posh')) {
    Write-Warning 'Module Missing... Installing Oh-My-Posh'
    Install-Module -Name 'Oh-My-Posh' ; Import-Module -Name 'Oh-My-Posh'

}
Else {
    Import-Module -Name 'Oh-My-Posh'
    Write-Warning 'Module Imported!'
}

# Configure Oh-My-Posh Theme
#Get-PoshThemes
$PoshTheme = Read-Host -Prompt 'Please Enter Theme Name'

# PowerShell 5.1
If ($host.Version -match 5.1) {
    # C:\Users\$User\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1
    $PoshProfile = "$([Environment]::GetFolderPath("MyDocuments"))\WindowsPowerShell\Microsoft.PowerShell_profile.ps1"
    If (Test-Path $PoshProfile) {
        Write-Warning -Message 'PowerShell Profile Detected!'
        [int]$PoshThemeMenu = 0
        while ( $PoshThemeMenu -lt 1 -or $PoshThemeMenu -gt 2) {
            Write-Output '[1] Create Fresh Microsoft.PowerShell_profile.ps1 '
            Write-Output '[2] Add to Microsoft.PowerShell_profile.ps1'
            [int]$PoshThemeMenu = Read-Host 'Please choose an option'
            switch ($PoshThemeMenu) {
                1 { 
                    # Clear Previous PowerShell Profile
                    Write-Warning -Message 'Renaming Microsoft.PowerShell_profile.ps1 to Microsoft.PowerShell_profile.ps1.backup'
                    Move-Item -Path "$([Environment]::GetFolderPath("MyDocuments"))\WindowsPowerShell\Microsoft.PowerShell_profile.ps1" -Destination "$([Environment]::GetFolderPath("MyDocuments"))\WindowsPowerShell\Microsoft.PowerShell_profile.ps1.backup" -Force
                        
                    # Create New PoweShell Profile
                    New-Item -ItemType 'File' -Path $PoshProfile | Out-Null

                    # Create Oh-My-Posh Profile
                    "Import-Module -Name 'Oh-My-Posh'
                     Set-PoshPrompt -Theme $PoshTheme
                    " | Set-Content -Path $PoshProfile
                    (Get-Content $PoshProfile).Trim() | Set-Content $PoshProfile
                    
                    # Creating Symbolic Links 
                    If (!( Test-Path "$([Environment]::GetFolderPath("MyDocuments"))\PowerShell" )) {
                        New-Item -ItemType 'Directory' -Path "$([Environment]::GetFolderPath("MyDocuments"))\PowerShell" | Out-Null
                    }
                    New-Item -ItemType SymbolicLink -Target $PoshProfile -Path "$([Environment]::GetFolderPath("MyDocuments"))\PowerShell\Microsoft.PowerShell_profile.ps1" -Force | Out-Null   
                    New-Item -ItemType SymbolicLink -Target $PoshProfile -Path "$([Environment]::GetFolderPath("MyDocuments"))\PowerShell\Microsoft.VSCode_profile.ps1" -Force | Out-Null                     
                }
                2 { 
                    # Clear Previous PowerShell Profile
                    Write-Warning -Message 'Renaming Microsoft.PowerShell_profile.ps1 to Microsoft.PowerShell_profile.ps1.backup'
                    Copy-Item -Path "$([Environment]::GetFolderPath("MyDocuments"))\WindowsPowerShell\Microsoft.PowerShell_profile.ps1" -Destination "$([Environment]::GetFolderPath("MyDocuments"))\WindowsPowerShell\Microsoft.PowerShell_profile.ps1.backup" -Force

                    # Add Oh-My-Posh to Profile
                    "Import-Module -Name 'Oh-My-Posh'
                     Set-PoshPrompt -Theme $PoshTheme
                    " | Add-Content -Path $PoshProfile
                    (Get-Content $PoshProfile).Trim() | Set-Content $PoshProfile
                    
                    # Creating Symbolic Links 
                    If (!( Test-Path "$([Environment]::GetFolderPath("MyDocuments"))\PowerShell" )) {
                        New-Item -ItemType 'Directory' -Path "$([Environment]::GetFolderPath("MyDocuments"))\PowerShell" | Out-Null
                    }
                    New-Item -ItemType SymbolicLink -Target $PoshProfile -Path "$([Environment]::GetFolderPath("MyDocuments"))\PowerShell\Microsoft.PowerShell_profile.ps1" -Force | Out-Null    
                    New-Item -ItemType SymbolicLink -Target $PoshProfile -Path "$([Environment]::GetFolderPath("MyDocuments"))\PowerShell\Microsoft.VSCode_profile.ps1" -Force | Out-Null 

                }
            }
        } 
    }
    Else {
        If (!(Test-Path $(Split-Path $PoshProfile))) {

            # Creating PowerShell Profile Root Folder and Microsoft.PowerShell_profile.ps1"
            New-Item -ItemType 'Directory' -Path $(Split-Path $PoshProfile) | Out-Null
            New-Item -ItemType 'File' -Path $PoshProfile | Out-Null

            # Add Oh-My-Posh to Profile
            "Import-Module -Name 'Oh-My-Posh'
            Set-PoshPrompt -Theme $PoshTheme
            " | Set-Content -Path $PoshProfile
            (Get-Content $PoshProfile).Trim() | Set-Content $PoshProfile
            Write-Warning -Message 'Microsoft.PowerShell_profile.ps1 Created!'

            # Creating Symbolic Links 
            If (!( Test-Path "$([Environment]::GetFolderPath("MyDocuments"))\PowerShell" )) {
                New-Item -ItemType 'Directory' -Path "$([Environment]::GetFolderPath("MyDocuments"))\PowerShell" | Out-Null
            }
            New-Item -ItemType SymbolicLink -Target $PoshProfile -Path "$([Environment]::GetFolderPath("MyDocuments"))\PowerShell\Microsoft.PowerShell_profile.ps1" | Out-Null    
            New-Item -ItemType SymbolicLink -Target $PoshProfile -Path "$([Environment]::GetFolderPath("MyDocuments"))\PowerShell\Microsoft.VSCode_profile.ps1" | Out-Null  
        }     
    }
}

# Powershell 7.x
If ($host.Version -match 7) {
    # C:\Users\$User\Documents\PowerShell\Microsoft.PowerShell_profile.ps1
    $PoshProfile = "$([Environment]::GetFolderPath("MyDocuments"))\PowerShell\Microsoft.PowerShell_profile.ps1"
    If (Test-Path $PoshProfile) {
        Write-Warning -Message 'PowerShell Profile Detected!'
        [int]$PoshThemeMenu = 0
        while ( $PoshThemeMenu -lt 1 -or $PoshThemeMenu -gt 2) {
            Write-Output '[1] Create Fresh Microsoft.PowerShell_profile.ps1 '
            Write-Output '[2] Add to Microsoft.PowerShell_profile.ps1'
            [int]$PoshThemeMenu = Read-Host 'Please choose an option'
            switch ($PoshThemeMenu) {
                1 { 
                    # Clear Previous PowerShell Profile
                    Write-Warning -Message 'Renaming Microsoft.PowerShell_profile.ps1 to Microsoft.PowerShell_profile.ps1.backup'
                    Move-Item -Path "$([Environment]::GetFolderPath("MyDocuments"))\PowerShell\Microsoft.PowerShell_profile.ps1" -Destination "$([Environment]::GetFolderPath("MyDocuments"))\PowerShell\Microsoft.PowerShell_profile.ps1.backup" -Force
                        
                    # Create New PoweShell Profile
                    New-Item -ItemType 'File' -Path $PoshProfile | Out-Null
                    New-Item -ItemType SymbolicLink -Target $PoshProfile -Path "$([Environment]::GetFolderPath("MyDocuments"))\PowerShell\Microsoft.VSCode_profile.ps1" -Force | Out-Null                     

                    # Create Oh-My-Posh Profile
                    "Import-Module -Name 'Oh-My-Posh'
                     Set-PoshPrompt -Theme $PoshTheme
                    " | Set-Content -Path $PoshProfile
                    (Get-Content $PoshProfile).Trim() | Set-Content $PoshProfile
                    
                    # Creating Symbolic Links 
                    If (!( Test-Path "$([Environment]::GetFolderPath("MyDocuments"))\WindowsPowerShell" )) {
                        New-Item -ItemType 'Directory' -Path "$([Environment]::GetFolderPath("MyDocuments"))\WindowsPowerShell" | Out-Null
                    }
                    New-Item -ItemType SymbolicLink -Target $PoshProfile -Path "$([Environment]::GetFolderPath("MyDocuments"))\WindowsPowerShell\Microsoft.PowerShell_profile.ps1" -Force | Out-Null   
                   
                }
                2 { 
                    # Clear Previous PowerShell Profile
                    Write-Warning -Message 'Renaming Microsoft.PowerShell_profile.ps1 to Microsoft.PowerShell_profile.ps1.backup'
                    Copy-Item -Path "$([Environment]::GetFolderPath("MyDocuments"))\PowerShell\Microsoft.PowerShell_profile.ps1" -Destination "$([Environment]::GetFolderPath("MyDocuments"))\PowerShell\Microsoft.PowerShell_profile.ps1.backup" -Force

                    # Add Oh-My-Posh to Profile
                    "Import-Module -Name 'Oh-My-Posh'
                     Set-PoshPrompt -Theme $PoshTheme
                    " | Add-Content -Path $PoshProfile
                    (Get-Content $PoshProfile).Trim() | Set-Content $PoshProfile
                    
                    # Creating Symbolic Links 
                    If (!( Test-Path "$([Environment]::GetFolderPath("MyDocuments"))\WindowsPowerShell" )) {
                        New-Item -ItemType 'Directory' -Path "$([Environment]::GetFolderPath("MyDocuments"))\WindowsPowerShell" | Out-Null
                    }
                    New-Item -ItemType SymbolicLink -Target $PoshProfile -Path "$([Environment]::GetFolderPath("MyDocuments"))\PowerShell\Microsoft.PowerShell_profile.ps1" -Force | Out-Null    
                    New-Item -ItemType SymbolicLink -Target $PoshProfile -Path "$([Environment]::GetFolderPath("MyDocuments"))\PowerShell\Microsoft.VSCode_profile.ps1" -Force | Out-Null 

                }
            }
        } 
    }
    Else {
        If (!(Test-Path $(Split-Path $PoshProfile))) {

            # Creating PowerShell Profile Root Folder and Microsoft.PowerShell_profile.ps1"
            New-Item -ItemType 'Directory' -Path $(Split-Path $PoshProfile) | Out-Null
            New-Item -ItemType 'File' -Path $PoshProfile | Out-Null

            # Add Oh-My-Posh to Profile
            "Import-Module -Name 'Oh-My-Posh'
            Set-PoshPrompt -Theme $PoshTheme
            " | Set-Content -Path $PoshProfile
            (Get-Content $PoshProfile).Trim() | Set-Content $PoshProfile
            Write-Warning -Message 'Microsoft.PowerShell_profile.ps1 Created!'

            # Creating Symbolic Links 
            If (!( Test-Path "$([Environment]::GetFolderPath("MyDocuments"))\PowerShell" )) {
                New-Item -ItemType 'Directory' -Path "$([Environment]::GetFolderPath("MyDocuments"))\PowerShell" | Out-Null
            }
            New-Item -ItemType SymbolicLink -Target $PoshProfile -Path "$([Environment]::GetFolderPath("MyDocuments"))\PowerShell\Microsoft.PowerShell_profile.ps1" | Out-Null    
            New-Item -ItemType SymbolicLink -Target $PoshProfile -Path "$([Environment]::GetFolderPath("MyDocuments"))\PowerShell\Microsoft.VSCode_profile.ps1" | Out-Null  
        }     
    }
}

# Reload Powershell Profile 
. $Profile
