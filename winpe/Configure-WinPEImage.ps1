# Clear Previous Screen
Clear-Host

# PowerShell Menu Title
$host.UI.RawUI.WindowTitle = "WinPE Media Builder"

# Define WinPEBuilder Root Folder
$DriveLetter = [System.IO.DriveInfo]::GetDrives().Name
ForEach ($Letter in $DriveLetter) {
    If (Test-Path $("$Letter" + ":\WinPEBuilder")) {
        $WinPEDir = $("$Letter" + ":\WinPEBuilder") 
    }
}

do {
    [int]$WinPEMenu = 0
    while ( $WinPEMenu -lt 1 -or $WinPEMenu -gt 6 ) {
        # https://www.gregorystrike.com/2010/05/17/powershell-script-to-build-a-custom-winpe-v3-0-environment/
        Write-Host ""
        Write-Host "  _       __ _         ____   ______   __  ___           __ _           ____          _  __     __             " -ForegroundColor Yellow
        Write-Host " | |     / /(_)____   / __ \ / ____/  /  |/  /___   ____/ /(_)____ _   / __ ) __  __ (_)/ /____/ /___   _____  " -ForegroundColor Yellow
        Write-Host " | | /| / // // __ \ / /_/ // __/    / /|_/ // _ \ / __  // // __  `/  / __ | / / / // // // __  // _ \ / ___/ " -ForegroundColor Yellow
        Write-Host " | |/ |/ // // / / // ____// /___   / /  / //  __// /_/ // // /_/ /  / /_/ // /_/ // // // /_/ //  __// /      " -ForegroundColor Yellow
        Write-Host " |__/|__//_//_/ /_//_/    /_____/  /_/  /_/ \___/ \__,_//_/ \__,_/  /_____/ \__,_//_//_/ \__,_/ \___//_/       " -ForegroundColor Yellow
        Write-Host ""
        Write-Host "[1] Provision Vanilla WinPE_x86 ISO"
        Write-Host "[2] Provision Vanilla WinPE_amd64 ISO"
        Write-Host "[3] Provision Custom WinPE_x86 ISO"
        Write-Host "[4] Provision Custom WinPE_amd64 ISO"
        Write-Host "[5] Further Customisation"
        Write-Host "[6] Close WinPE Builder"
        Write-Host ""
        [Int]$WinPEMenu = read-Host "Please select an option."
    }
    Switch ( $WinPEMenu ) {
        1 {
            # Vanilla WinPE_x86 Image

            # Import-Modules
            Import-Module DISM
            Import-Module BitsTransfer
            Import-Module International

            # Copy WinPE Media
            $FilePath = Read-Host "Please Enter WinPE Directory"
            $TargetArch = "x86"
            $WinPEDir = "$FilePath"
            $WinADKLocation = "${env:ProgramFiles(x86)}\Windows Kits\10\Assessment and Deployment Kit"
            If (Test-Path "$FilePath" -IsValid) {
                Remove-Item $FilePath -Force -Recurse -ErrorAction SilentlyContinue
            } 
            If (Test-Path $WinADKLocation) {
                $WinPEDir, "$WinPEDir\ISO", "$WinPEDir\ISO\sources", "$WinPEDir\mount" | ForEach-Object {
                    If (-not(Test-Path $_ -PathType Container)) {
                        try {
                            New-Item -Path $_ -ItemType Container -ErrorAction Stop -Force
                        }
                        catch {
                            Write-Warning -Message "Failed to create target folders"
                        }
                    }
                }
                try {
                    Copy-Item -Path "$WinADKLocation\Windows Preinstallation Environment\$TargetArch\Media\bootmgr*" -Destination "$WinPEDir\ISO\"
                    Copy-Item -Path "$WinADKLocation\Deployment Tools\$TargetArch\Oscdimg\etfsboot.com" -Destination $WinPEDir
                    Copy-Item -Path "$WinADKLocation\Deployment Tools\$TargetArch\Oscdimg\efisys.bin" -Destination $WinPEDir
                    & (Get-Command "$env:systemroot\system32\robocopy.exe") @("$WinADKLocation\Windows Preinstallation Environment\$TargetArch\Media\boot", "$WinPEDir\ISO\boot", '/S', '/r:0', '/Z', '/PURGE') | Out-Null
                    Copy-Item -Path "$WinADKLocation\Windows Preinstallation Environment\$TargetArch\en-us\winpe.wim" -Destination $WinPEDir -ErrorAction Stop -Force
                }
                catch {
                    Write-Warning "Copy Failed"
                    break
                }
            }
            # Mount WIM File
            Mount-WindowsImage -ImagePath "$FilePath\winpe.wim" -Index 1 -Path $FilePath\mount

            # Configure WinPE Regional and Keyboard Settings
            dism /image:$FilePath\mount /Set-SysLocale:en-GB
            dism /image:$FilePath\mount /Set-UserLocale:en-GB
            dism /image:$FilePath\mount /Set-InputLocale:0809:00000809
            dism /image:$FilePath\mount /Set-TimeZone:"GMT Standard Time"

            # Add Windows Preinstallation Environment Cab Files
            # MS TechNet Reference: https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/winpe-add-packages--optional-components-reference
            Dism /Add-Package /Image:"$FilePath\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\$TargetArch\WinPE_OCs\WinPE-WMI.cab"
            Dism /Add-Package /Image:"$FilePath\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\$TargetArch\WinPE_OCs\en-gb\WinPE-WMI_en-gb.cab"
            Dism /Add-Package /Image:"$FilePath\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\$TargetArch\WinPE_OCs\WinPE-NetFX.cab"
            Dism /Add-Package /Image:"$FilePath\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\$TargetArch\WinPE_OCs\en-gb\WinPE-NetFX_en-gb.cab"
            Dism /Add-Package /Image:"$FilePath\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\$TargetArch\WinPE_OCs\WinPE-Scripting.cab"
            Dism /Add-Package /Image:"$FilePath\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\$TargetArch\WinPE_OCs\en-gb\WinPE-Scripting_en-gb.cab"
            Dism /Add-Package /Image:"$FilePath\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\$TargetArch\WinPE_OCs\WinPE-PowerShell.cab"
            Dism /Add-Package /Image:"$FilePath\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\$TargetArch\WinPE_OCs\en-gb\WinPE-PowerShell_en-gb.cab"
            Dism /Add-Package /Image:"$FilePath\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\$TargetArch\WinPE_OCs\WinPE-StorageWMI.cab"
            Dism /Add-Package /Image:"$FilePath\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\$TargetArch\WinPE_OCs\en-gb\WinPE-StorageWMI_en-gb.cab"
            Dism /Add-Package /Image:"$FilePath\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\$TargetArch\WinPE_OCs\WinPE-DismCmdlets.cab"
            Dism /Add-Package /Image:"$FilePath\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\$TargetArch\WinPE_OCs\en-gb\WinPE-DismCmdlets_en-gb.cab"
            Dism /Add-Package /Image:"$FilePath\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\$TargetArch\WinPE_OCs\WinPE-SecureStartup.cab"
            Dism /Add-Package /Image:"$FilePath\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\$TargetArch\WinPE_OCs\WinPE-SecureBootCmdlets.cab"
            Dism /Add-Package /Image:"$FilePath\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\$TargetArch\WinPE_OCs\WinPE-WinReCfg.cab"
            Dism /Add-Package /Image:"$FilePath\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\$TargetArch\WinPE_OCs\en-gb\WinPE-WinReCfg_en-gb.cab"

            Write-Host ""
            $DriverInstall = Read-Host -Prompt "Do you require 3rd Party Drive Support [Y] or [N]" 
            If ($DriverInstall -eq "Y") {
                # Intel Rapid Storage Driver 32x
                Add-WindowsDriver -Path $FilePath\mount -Driver "$WinPEDir\WinPE_Drivers\Intel_RST32x" -ForceUnsigned
			
                # HPE Gen9 Pxe Boot Solution 32x
                # https://social.technet.microsoft.com/Forums/office/en-US/4e6e7937-7efa-45d7-aede-d64119cb75e4/winpe-boot-issue-proliant-gen9-server-with-winpe-1709-where-is-the-fix-kb4055537?forum=ConfigMgrCBOSD
                Add-WindowsPackage -Path $FilePath\mount -PackagePath "$WinPEDir\WinPE_Patches\hpe_gen9_pxe_boot_solution\windows10.0-kb4056892-x86_d3aaf1048d6f314240b8c6fe27932aa52a5e6733.msu" -Verbose
            }
            Else {

                Write-Host ""
                Write-Host "Skipping Driver Injection..." -ForegroundColor Cyan
                Write-Host ""

            }

            # Unmount WIM File
            Dismount-WindowsImage -Path $FilePath\mount -Save

            # Create ISO Media
            Copy-Item -Path "$WinPEDir\winpe.wim" -Destination "$WinPEDir\ISO\sources\boot.wim" -ErrorAction Stop
            $BOOTDATA = '2#p0,e,b"{0}"#pEF,e,b"{1}"' -f "$WinPEDir\etfsboot.com", "$WinPEDir\efisys.bin"
            & (Get-Command "$WinADKLocation\Deployment Tools\$TargetArch\Oscdimg\oscdimg.exe") @("-bootdata:$BOOTDATA", '-u1', '-udfver102', "$WinPEDir\ISO", "$WinPEDir\WinPE5_$TargetArch.iso")
        }
        2 {
            # Vanilla WinPE_amd64 Image

            # Import-Modules
            Import-Module DISM
            Import-Module BitsTransfer
            Import-Module International

            # Copy WinPE Media
            $FilePath = Read-Host "Please Enter WinPE Directory"
            $TargetArch = "amd64"
            $WinPEDir = "$FilePath"
            $WinADKLocation = "${env:ProgramFiles(x86)}\Windows Kits\10\Assessment and Deployment Kit"
            If (Test-Path "$FilePath" -IsValid) {
                Remove-Item $FilePath -Force -Recurse -ErrorAction SilentlyContinue
            }
            If (Test-Path $WinADKLocation) {
                $WinPEDir, "$WinPEDir\ISO", "$WinPEDir\ISO\sources", "$WinPEDir\mount" | ForEach-Object {
                    If (-not(Test-Path $_ -PathType Container)) {
                        try {
                            New-Item -Path $_ -ItemType Container -ErrorAction Stop -Force
                        }
                        catch {
                            Write-Warning -Message "Failed to create target folders"
                        }
                    }
                }
                try {
                    Copy-Item -Path "$WinADKLocation\Windows Preinstallation Environment\$TargetArch\Media\bootmgr*" -Destination "$WinPEDir\ISO\" -Force
                    Copy-Item -Path "$WinADKLocation\Windows Preinstallation Environment\$TargetArch\Media\EFI*" -Destination "$WinPEDir\ISO\" -Recurse
                    Copy-Item -Path "$WinADKLocation\Deployment Tools\$TargetArch\Oscdimg\etfsboot.com" -Destination $WinPEDir -Force
                    Copy-Item -Path "$WinADKLocation\Deployment Tools\$TargetArch\Oscdimg\efisys_noprompt.bin" -Destination $WinPEDir\efisys.bin -Force
                    & (Get-Command "$env:systemroot\system32\robocopy.exe") @("$WinADKLocation\Windows Preinstallation Environment\$TargetArch\Media\boot", "$WinPEDir\ISO\boot", '/S', '/r:0', '/Z', '/PURGE') | Out-Null
                    Copy-Item -Path "$WinADKLocation\Windows Preinstallation Environment\$TargetArch\en-us\winpe.wim" -Destination $WinPEDir
                }
                catch {
                    Write-Warning "Copy Failed"
                    break
                }
            }
            # Mount WIM File
            Mount-WindowsImage -ImagePath "$FilePath\winpe.wim" -Index 1 -Path $FilePath\mount

            # Configure WinPE Regional and Keyboard Settings
            dism /image:$FilePath\mount /Set-SysLocale:en-GB
            dism /image:$FilePath\mount /Set-UserLocale:en-GB
            dism /image:$FilePath\mount /Set-InputLocale:0809:00000809
            dism /image:$FilePath\mount /Set-TimeZone:"GMT Standard Time"

            # Add Windows Preinstallation Environment Cab Files
            # MS TechNet Reference: https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/winpe-add-packages--optional-components-reference
            Dism /Add-Package /Image:"$FilePath\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\$TargetArch\WinPE_OCs\WinPE-WMI.cab"
            Dism /Add-Package /Image:"$FilePath\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\$TargetArch\WinPE_OCs\en-gb\WinPE-WMI_en-gb.cab"
            Dism /Add-Package /Image:"$FilePath\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\$TargetArch\WinPE_OCs\WinPE-NetFX.cab"
            Dism /Add-Package /Image:"$FilePath\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\$TargetArch\WinPE_OCs\en-gb\WinPE-NetFX_en-gb.cab"
            Dism /Add-Package /Image:"$FilePath\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\$TargetArch\WinPE_OCs\WinPE-Scripting.cab"
            Dism /Add-Package /Image:"$FilePath\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\$TargetArch\WinPE_OCs\en-gb\WinPE-Scripting_en-gb.cab"
            Dism /Add-Package /Image:"$FilePath\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\$TargetArch\WinPE_OCs\WinPE-PowerShell.cab"
            Dism /Add-Package /Image:"$FilePath\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\$TargetArch\WinPE_OCs\en-gb\WinPE-PowerShell_en-gb.cab"
            Dism /Add-Package /Image:"$FilePath\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\$TargetArch\WinPE_OCs\WinPE-StorageWMI.cab"
            Dism /Add-Package /Image:"$FilePath\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\$TargetArch\WinPE_OCs\en-gb\WinPE-StorageWMI_en-gb.cab"
            Dism /Add-Package /Image:"$FilePath\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\$TargetArch\WinPE_OCs\WinPE-DismCmdlets.cab"
            Dism /Add-Package /Image:"$FilePath\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\$TargetArch\WinPE_OCs\en-gb\WinPE-DismCmdlets_en-gb.cab"
            Dism /Add-Package /Image:"$FilePath\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\$TargetArch\WinPE_OCs\WinPE-SecureStartup.cab"
            Dism /Add-Package /Image:"$FilePath\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\$TargetArch\WinPE_OCs\WinPE-SecureBootCmdlets.cab"
            Dism /Add-Package /Image:"$FilePath\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\$TargetArch\WinPE_OCs\WinPE-WinReCfg.cab"
            Dism /Add-Package /Image:"$FilePath\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\$TargetArch\WinPE_OCs\en-gb\WinPE-WinReCfg_en-gb.cab"

            Write-Host ""
            $DriverInstall = Read-Host -Prompt "Do you require 3rd Party Drive Support [Y] or [N]"
            If ($DriverInstall -eq "Y") {            
                # Intel Rapid Storage Driver 64x
                Add-WindowsDriver -Path $FilePath\mount -Driver "$WinPEDir\WinPE_Drivers\Intel_RST64x" -ForceUnsigned
			
                # HPE Gen9 Pxe Boot Solution 32x
                # https://social.technet.microsoft.com/Forums/office/en-US/4e6e7937-7efa-45d7-aede-d64119cb75e4/winpe-boot-issue-proliant-gen9-server-with-winpe-1709-where-is-the-fix-kb4055537?forum=ConfigMgrCBOSD
                Add-WindowsPackage -Path $FilePath\mount -PackagePath "$WinPEDir\WinPE_Patches\hpe_gen9_pxe_boot_solution\windows10.0-kb4056892-x64_a41a378cf9ae609152b505c40e691ca1228e28ea.msu" -Verbose
            }
            Else {

                Write-Host ""
                Write-Host "Skipping Driver Injection..." -ForegroundColor Cyan
                Write-Host ""

            }

            # Unmount WIM File
            Dismount-WindowsImage -Path $FilePath\mount -Save

            # Create ISO Media
            Copy-Item -Path "$WinPEDir\winpe.wim" -Destination "$WinPEDir\ISO\sources\boot.wim" -ErrorAction Stop
            $BOOTDATA = '2#p0,e,b"{0}"#pEF,e,b"{1}"' -f "$WinPEDir\etfsboot.com", "$WinPEDir\efisys.bin"
            & (Get-Command "$WinADKLocation\Deployment Tools\$TargetArch\Oscdimg\oscdimg.exe") @("-bootdata:$BOOTDATA", '-u2', '-udfver102', "$WinPEDir\ISO", "$WinPEDir\WinPE5_$TargetArch.iso")
        }
        3 {
            # Custom WinPE_x86 Image

            # Import-Modules
            Import-Module DISM
            Import-Module BitsTransfer
            Import-Module International
            Import-Module Microsoft.PowerShell.Archive

            # Copy WinPE Media
            $FilePath = Read-Host "Please Enter WinPE Directory"
            $TargetArch = "x86"
            $WinPEDir = "$FilePath"
            $WinADKLocation = "${env:ProgramFiles(x86)}\Windows Kits\10\Assessment and Deployment Kit"
            If (Test-Path "$FilePath" -IsValid) {
                Remove-Item $FilePath -Force -Recurse -ErrorAction SilentlyContinue
            }
            If (Test-Path $WinADKLocation) {
                $WinPEDir, "$WinPEDir\ISO", "$WinPEDir\ISO\sources", "$WinPEDir\mount" | ForEach-Object {
                    If (-not(Test-Path $_ -PathType Container)) {
                        try {
                            New-Item -Path $_ -ItemType Container -ErrorAction Stop -Force
                        }
                        catch {
                            Write-Warning -Message "Failed to create target folders"
                        }
                    }
                }
                try {
                    Copy-Item -Path "$WinADKLocation\Windows Preinstallation Environment\$TargetArch\Media\bootmgr*" -Destination "$WinPEDir\ISO\"
                    Copy-Item -Path "$WinADKLocation\Deployment Tools\$TargetArch\Oscdimg\etfsboot.com" -Destination $WinPEDir
                    Copy-Item -Path "$WinADKLocation\Deployment Tools\$TargetArch\Oscdimg\efisys.bin" -Destination $WinPEDir
                    & (Get-Command "$env:systemroot\system32\robocopy.exe") @("$WinADKLocation\Windows Preinstallation Environment\$TargetArch\Media\boot", "$WinPEDir\ISO\boot", '/S', '/r:0', '/Z', '/PURGE') | Out-Null
                    Copy-Item -Path "$WinADKLocation\Windows Preinstallation Environment\$TargetArch\en-us\winpe.wim" -Destination $WinPEDir -ErrorAction Stop -Force
                }
                catch {
                    Write-Warning "Copy Failed"
                    break
                }
            }
            # Mount WIM File
            Mount-WindowsImage -ImagePath "$FilePath\winpe.wim" -Index 1 -Path $FilePath\mount

            # Configure WinPE Regional and Keyboard Settings
            dism /image:$FilePath\mount /Set-SysLocale:en-GB
            dism /image:$FilePath\mount /Set-UserLocale:en-GB
            dism /image:$FilePath\mount /Set-InputLocale:0809:00000809
            dism /image:$FilePath\mount /Set-TimeZone:"GMT Standard Time"

            # Add Windows Preinstallation Environment Cab Files
            # MS TechNet Reference: https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/winpe-add-packages--optional-components-reference
            Dism /Add-Package /Image:"$FilePath\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\$TargetArch\WinPE_OCs\WinPE-WMI.cab"
            Dism /Add-Package /Image:"$FilePath\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\$TargetArch\WinPE_OCs\en-gb\WinPE-WMI_en-gb.cab"
            Dism /Add-Package /Image:"$FilePath\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\$TargetArch\WinPE_OCs\WinPE-NetFX.cab"
            Dism /Add-Package /Image:"$FilePath\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\$TargetArch\WinPE_OCs\en-gb\WinPE-NetFX_en-gb.cab"
            Dism /Add-Package /Image:"$FilePath\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\$TargetArch\WinPE_OCs\WinPE-Scripting.cab"
            Dism /Add-Package /Image:"$FilePath\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\$TargetArch\WinPE_OCs\en-gb\WinPE-Scripting_en-gb.cab"
            Dism /Add-Package /Image:"$FilePath\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\$TargetArch\WinPE_OCs\WinPE-PowerShell.cab"
            Dism /Add-Package /Image:"$FilePath\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\$TargetArch\WinPE_OCs\en-gb\WinPE-PowerShell_en-gb.cab"
            Dism /Add-Package /Image:"$FilePath\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\$TargetArch\WinPE_OCs\WinPE-StorageWMI.cab"
            Dism /Add-Package /Image:"$FilePath\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\$TargetArch\WinPE_OCs\en-gb\WinPE-StorageWMI_en-gb.cab"
            Dism /Add-Package /Image:"$FilePath\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\$TargetArch\WinPE_OCs\WinPE-DismCmdlets.cab"
            Dism /Add-Package /Image:"$FilePath\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\$TargetArch\WinPE_OCs\en-gb\WinPE-DismCmdlets_en-gb.cab"
            Dism /Add-Package /Image:"$FilePath\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\$TargetArch\WinPE_OCs\WinPE-SecureStartup.cab"
            Dism /Add-Package /Image:"$FilePath\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\$TargetArch\WinPE_OCs\WinPE-SecureBootCmdlets.cab"
            Dism /Add-Package /Image:"$FilePath\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\$TargetArch\WinPE_OCs\WinPE-WinReCfg.cab"
            Dism /Add-Package /Image:"$FilePath\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\$TargetArch\WinPE_OCs\en-gb\WinPE-WinReCfg_en-gb.cab"

            # Configure Applications
            New-Item -ItemType Directory -Path $FilePath\mount\Applications
            Invoke-WebRequest -Uri https://download.sysinternals.com/files/SysinternalsSuite.zip -OutFile $FilePath\mount\Applications\SysinternalsSuite.zip ; Expand-Archive -Path $FilePath\mount\Applications\SysinternalsSuite.zip -DestinationPath $FilePath\mount\Applications\SysinternalsSuite ; Remove-Item -Path $FilePath\mount\Applications\SysinternalsSuite.zip
            Expand-Archive -Path "$WinPEDir\WinPE_Applications\hw32_570.zip" -DestinationPath $FilePath\mount\Applications\HWInfo
            Copy-Item -Path "$WinPEDir\WinPE_Applications\HWiNFO32.INI" -Destination $FilePath\mount\Applications\HWInfo\HWiNFO32.ini -Force
            Copy-Item -Path "$WinPEDir\WinPE_Applications\CMTrace_32\CMTrace_32.exe" -Destination $FilePath\mount\Applications\CMTrace.exe
            # DeploymentResearch CMTrace in WinPE Solution: https://deploymentresearch.com/Research/Post/525/Adding-CMTrace-to-your-MDT-Lite-Touch-boot-images
            Copy-Item -Path "$WinPEDir\WinPE_Applications\CMTrace_32\CMtracex86.inf" -Destination $FilePath\mount\Windows\System32\CMtracex86.inf

            # Configure WinPE Background
            $ACL = Get-ACL $FilePath\mount\Windows\System32\winpe.jpg
            $Group = New-Object System.Security.Principal.NTAccount("Builtin", "Users")
            $ACL.SetOwner($Group)
            Set-Acl -Path $FilePath\mount\Windows\System32\winpe.jpg -AclObject $ACL

            icacls $FilePath\mount\Windows\System32\winpe.jpg /grant BUILTIN\Users:M
            #Copy-Item -Path "$WinPEDir\WinPE_Backgrounds\winpe_azureblue.jpg" -Destination $FilePath\mount\Windows\System32\winpe.jpg
            Copy-Item -Path "$WinPEDir\WinPE_Backgrounds\winpe_slate.jpg" -Destination $FilePath\mount\Windows\System32\winpe.jpg

            # Intel Rapid Storage Driver 32x
            Add-WindowsDriver -Path $FilePath\mount -Driver "$WinPEDir\WinPE_Drivers\Intel_RST32x" -ForceUnsigned

            # Remove CMTrace Default Log Application Prompt
            # https://miketerrill.net/2017/05/13/how-to-open-cmtrace-in-winpe-like-a-boss/
            
            # Load WinPE Registry Hive
            Reg load HKLM\WinPE $FilePath\mount\Windows\System32\config\default

            # Add Registry Keys and Values
            New-Item -Path "HKLM:\WinPE\Software\Classes\.lo_" ; New-ItemProperty -Path "HKLM:\WinPE\Software\Classes\.lo_" -Name "(default)" -Value "Log.File"
            New-Item -Path "HKLM:\WinPE\Software\Classes\.log" ; New-ItemProperty -Path "HKLM:\WinPE\Software\Classes\.log" -Name "(default)" -Value "Log.File"
            New-Item -Path "HKLM:\WinPE\Software\Classes\Log.File\" ; New-Item -Path "HKLM:\WinPE\Software\Classes\Log.File\shell\" ; New-Item -Path "HKLM:\WinPE\Software\Classes\Log.File\shell\open" ; New-Item -Path "HKLM:\WinPE\Software\Classes\Log.File\shell\open\command"
            New-ItemProperty -Path "HKLM:\WinPE\Software\Classes\Log.File\shell\open\command" -Name "(Default)" -Value """x:\Applications\CMTrace.exe"" ""%1"""

            # Save and Unload WinPE Registry Hive
            [gc]::Collect()
            Reg Unload HKLM\WinPE
            
            # Unmount WIM File
            Dismount-WindowsImage -Path $FilePath\mount -Save

            # Create ISO Media
            Copy-Item -Path "$WinPEDir\winpe.wim" -Destination "$WinPEDir\ISO\sources\boot.wim" -ErrorAction Stop
            $BOOTDATA = '2#p0,e,b"{0}"#pEF,e,b"{1}"' -f "$WinPEDir\etfsboot.com", "$WinPEDir\efisys.bin"
            & (Get-Command "$WinADKLocation\Deployment Tools\$TargetArch\Oscdimg\oscdimg.exe") @("-bootdata:$BOOTDATA", '-u1', '-udfver102', "$WinPEDir\ISO", "$WinPEDir\WinPE5_$TargetArch.iso")
        }
        4 {
            # Custom WinPE_amd64 Image

            # Import-Modules
            Import-Module DISM
            Import-Module BitsTransfer
            Import-Module International
            Import-Module Microsoft.PowerShell.Archive

            # Copy WinPE Media
            $FilePath = Read-Host "Please Enter WinPE Directory"
            $TargetArch = "amd64"
            $WinPEDir = "$FilePath"
            $WinADKLocation = "${env:ProgramFiles(x86)}\Windows Kits\10\Assessment and Deployment Kit"
            If (Test-Path "$FilePath" -IsValid) {
                Remove-Item $FilePath -Force -Recurse -ErrorAction SilentlyContinue
            }
            If (Test-Path $WinADKLocation) {
                $WinPEDir, "$WinPEDir\ISO", "$WinPEDir\ISO\sources", "$WinPEDir\mount" | ForEach-Object {
                    If (-not(Test-Path $_ -PathType Container)) {
                        try {
                            New-Item -Path $_ -ItemType Container -ErrorAction Stop -Force
                        }
                        catch {
                            Write-Warning -Message "Failed to create target folders"
                        }
                    }
                }
                try {
                    Copy-Item -Path "$WinADKLocation\Windows Preinstallation Environment\$TargetArch\Media\bootmgr*" -Destination "$WinPEDir\ISO\" -Force
                    Copy-Item -Path "$WinADKLocation\Windows Preinstallation Environment\$TargetArch\Media\EFI*" -Destination "$WinPEDir\ISO\" -Recurse
                    Copy-Item -Path "$WinADKLocation\Deployment Tools\$TargetArch\Oscdimg\etfsboot.com" -Destination $WinPEDir -Force
                    Copy-Item -Path "$WinADKLocation\Deployment Tools\$TargetArch\Oscdimg\efisys_noprompt.bin" -Destination $WinPEDir\efisys.bin -Force
                    & (Get-Command "$env:systemroot\system32\robocopy.exe") @("$WinADKLocation\Windows Preinstallation Environment\$TargetArch\Media\boot", "$WinPEDir\ISO\boot", '/S', '/r:0', '/Z', '/PURGE') | Out-Null
                    Copy-Item -Path "$WinADKLocation\Windows Preinstallation Environment\$TargetArch\en-us\winpe.wim" -Destination $WinPEDir
                }
                catch {
                    Write-Warning "Copy Failed"
                    break
                }
            }
            # Mount WIM File
            Mount-WindowsImage -ImagePath "$FilePath\winpe.wim" -Index 1 -Path $FilePath\mount

            # Configure WinPE Regional and Keyboard Settings
            dism /image:$FilePath\mount /Set-SysLocale:en-GB
            dism /image:$FilePath\mount /Set-UserLocale:en-GB
            dism /image:$FilePath\mount /Set-InputLocale:0809:00000809
            dism /image:$FilePath\mount /Set-TimeZone:"GMT Standard Time"

            # Add Windows Preinstallation Environment Cab Files
            # MS TechNet Reference: https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/winpe-add-packages--optional-components-reference
            Dism /Add-Package /Image:"$FilePath\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\$TargetArch\WinPE_OCs\WinPE-WMI.cab"
            Dism /Add-Package /Image:"$FilePath\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\$TargetArch\WinPE_OCs\en-gb\WinPE-WMI_en-gb.cab"
            Dism /Add-Package /Image:"$FilePath\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\$TargetArch\WinPE_OCs\WinPE-NetFX.cab"
            Dism /Add-Package /Image:"$FilePath\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\$TargetArch\WinPE_OCs\en-gb\WinPE-NetFX_en-gb.cab"
            Dism /Add-Package /Image:"$FilePath\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\$TargetArch\WinPE_OCs\WinPE-Scripting.cab"
            Dism /Add-Package /Image:"$FilePath\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\$TargetArch\WinPE_OCs\en-gb\WinPE-Scripting_en-gb.cab"
            Dism /Add-Package /Image:"$FilePath\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\$TargetArch\WinPE_OCs\WinPE-PowerShell.cab"
            Dism /Add-Package /Image:"$FilePath\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\$TargetArch\WinPE_OCs\en-gb\WinPE-PowerShell_en-gb.cab"
            Dism /Add-Package /Image:"$FilePath\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\$TargetArch\WinPE_OCs\WinPE-StorageWMI.cab"
            Dism /Add-Package /Image:"$FilePath\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\$TargetArch\WinPE_OCs\en-gb\WinPE-StorageWMI_en-gb.cab"
            Dism /Add-Package /Image:"$FilePath\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\$TargetArch\WinPE_OCs\WinPE-DismCmdlets.cab"
            Dism /Add-Package /Image:"$FilePath\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\$TargetArch\WinPE_OCs\en-gb\WinPE-DismCmdlets_en-gb.cab"
            Dism /Add-Package /Image:"$FilePath\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\$TargetArch\WinPE_OCs\WinPE-SecureStartup.cab"
            Dism /Add-Package /Image:"$FilePath\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\$TargetArch\WinPE_OCs\WinPE-SecureBootCmdlets.cab"
            Dism /Add-Package /Image:"$FilePath\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\$TargetArch\WinPE_OCs\WinPE-WinReCfg.cab"
            Dism /Add-Package /Image:"$FilePath\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\$TargetArch\WinPE_OCs\en-gb\WinPE-WinReCfg_en-gb.cab"

            # Configure Applications
            New-Item -ItemType Directory -Path $FilePath\mount\Applications
            Invoke-WebRequest -Uri https://download.sysinternals.com/files/SysinternalsSuite.zip -OutFile $FilePath\mount\Applications\SysinternalsSuite.zip ; Expand-Archive -Path $FilePath\mount\Applications\SysinternalsSuite.zip -DestinationPath $FilePath\mount\Applications\SysinternalsSuite ; Remove-Item -Path $FilePath\mount\Applications\SysinternalsSuite.zip
            Expand-Archive -Path "$WinPEDir\WinPE_Applications\hw64_570.zip" -DestinationPath $FilePath\mount\Applications\HWInfo
            Copy-Item -Path "$WinPEDir\WinPE_Applications\HWiNFO64.INI" -Destination $FilePath\mount\Applications\HWInfo\HWiNFO32.ini -Force
            Copy-Item -Path "$WinPEDir\WinPE_Applications\CMTrace_64\CMTrace_64.exe" -Destination $FilePath\mount\Applications\CMTrace.exe
            # DeploymentResearch CMTrace in WinPE Solution: https://deploymentresearch.com/Research/Post/525/Adding-CMTrace-to-your-MDT-Lite-Touch-boot-images
            Copy-Item -Path "$WinPEDir\WinPE_Applications\CMTrace_64\CMtracex64.inf" -Destination $FilePath\mount\Windows\System32\CMtracex64.inf

            # Remove CMTrace Default Log Application Prompt
            # https://miketerrill.net/2017/05/13/how-to-open-cmtrace-in-winpe-like-a-boss/
            
            # Load WinPE Registry Hive
            Reg load HKLM\WinPE $FilePath\mount\Windows\System32\config\default

            # Add Registry Keys and Values
            New-Item -Path "HKLM:\WinPE\Software\Classes\.lo_" ; New-ItemProperty -Path "HKLM:\WinPE\Software\Classes\.lo_" -Name "(default)" -Value "Log.File"
            New-Item -Path "HKLM:\WinPE\Software\Classes\.log" ; New-ItemProperty -Path "HKLM:\WinPE\Software\Classes\.log" -Name "(default)" -Value "Log.File"
            New-Item -Path "HKLM:\WinPE\Software\Classes\Log.File\" ; New-Item -Path "HKLM:\WinPE\Software\Classes\Log.File\shell\" ; New-Item -Path "HKLM:\WinPE\Software\Classes\Log.File\shell\open" ; New-Item -Path "HKLM:\WinPE\Software\Classes\Log.File\shell\open\command"
            New-ItemProperty -Path "HKLM:\WinPE\Software\Classes\Log.File\shell\open\command" -Name "(Default)" -Value """x:\Applications\CMTrace.exe"" ""%1"""

            # Save and Unload WinPE Registry Hive
            [gc]::Collect()
            Reg Unload HKLM\WinPE          
        
            # Configure WinPE Background
            $ACL = Get-ACL $FilePath\mount\Windows\System32\winpe.jpg
            $Group = New-Object System.Security.Principal.NTAccount("Builtin", "Users")
            $ACL.SetOwner($Group)
            Set-Acl -Path $FilePath\mount\Windows\System32\winpe.jpg -AclObject $ACL

            icacls $FilePath\mount\Windows\System32\winpe.jpg /grant BUILTIN\Users:M
            #Copy-Item -Path "$WinPEDir\WinPE_Backgrounds\winpe_azureblue.jpg" -Destination $FilePath\mount\Windows\System32\winpe.jpg
            Copy-Item -Path "$WinPEDir\WinPE_Backgrounds\winpe_slate.jpg" -Destination $FilePath\mount\Windows\System32\winpe.jpg

            # Configure WinPE Drivers
            # Intel Rapid Storage Driver 64x
            Add-WindowsDriver -Path $FilePath\mount -Driver "$WinPEDir\WinPE_Drivers\Intel_RST64x" -ForceUnsigned

            # Unmount WIM File
            Dismount-WindowsImage -Path $FilePath\mount -Save

            # Create ISO Media
            Copy-Item -Path "$WinPEDir\winpe.wim" -Destination "$WinPEDir\ISO\sources\boot.wim" -ErrorAction Stop
            $BOOTDATA = '2#p0,e,b"{0}"#pEF,e,b"{1}"' -f "$WinPEDir\etfsboot.com", "$WinPEDir\efisys.bin"
            & (Get-Command "$WinADKLocation\Deployment Tools\$TargetArch\Oscdimg\oscdimg.exe") @("-bootdata:$BOOTDATA", '-u2', '-udfver102', "$WinPEDir\ISO", "$WinPEDir\WinPE5_$TargetArch.iso")
        }
        5 {
            # WinPE Customization Menu
            do {
                [int]$WIMEditMenu = 0
                while ( $WIMEditMenu -lt 1 -or $WIMEditMenu -gt 9 ) {
                    Write-Host ""
                    Write-Host "[1] Mount WinPE Boot File"
                    Write-Host "[2] Check Mounted WIM File"
                    Write-Host "[3] Open Mounted WIM File "
                    Write-Host "[4] Commit WinPE Changes"
                    Write-Host "[5] Drop WinPE Changes"
                    Write-Host "[6] Cleanse Mount Dir"
                    Write-Host "[7] Generate WinPE ISO"
                    Write-Host "[8] Return to Main Menu"
                    Write-Host "[9] Close WinPE Builder"
                    Write-Host ""
                    [Int]$WIMEditMenu = read-Host "Please select an option."
                }
                Switch ( $WIMEditMenu ) {
                    1 {
                        # Mount WIM Image
                        If ( $FilePath -eq $null ) {
                            $FilePath = Read-Host "Please Enter WinPE Directory"
                        }
                        Mount-WindowsImage -ImagePath "$FilePath\ISO\sources\boot.wim" -Index 1 -Path "$FilePath\mount" | Out-Null
                        explorer.exe "$FilePath\mount"
                    }
                    2 {
                        # Get WIM Information
                        If ( $FilePath -eq $null ) {
                            $FilePath = Read-Host "Please Enter WinPE Directory"
                        }
                        Get-WindowsImage -Mounted
                    }
                    3 {
                        # Open Mount Folder in Windows Explorer
                        If ( $FilePath -eq $null ) {
                            $FilePath = Read-Host "Please Enter WinPE Directory"
                        }
                        explorer.exe $FilePath\mount
                    }
                    4 {
                        # Save WIM Changes and Dismount
                        If ( $FilePath -eq $null ) {
                            $FilePath = Read-Host "Please Enter WinPE Directory"
                        }
                        Dismount-WindowsImage -Path $FilePath\mount -Save
                    }
                    5 {
                        # Discard WIM Changes and Dismount
                        If ( $FilePath -eq $null ) {
                            $FilePath = Read-Host "Please Enter WinPE Directory"
                        }
                        Dismount-WindowsImage -Path $FilePath\mount -Discard
                    }
                    6 {
                        # Clean WIm Mount Point
                        If ( $FilePath -eq $null ) {
                            $FilePath = Read-Host "Please Enter WinPE Directory"
                        }
                        Stop-Process -ProcessName explorer
                        Clear-WindowsCorruptMountPoint -Verbose
                        Remove-Item -Path $FilePath\mount -Force | Out-Null ; New-Item -ItemType Directory -Path $FilePath\mount | Out-Null
                    }
                    7 {
                        # Build Rebuild ISO Media - Post Customization
                        do {
                            [int]$WinPEISOMenu = 0
                            while ( $WinPEISOMenu -lt 1 -or $WinPEISOMenu -gt 3 ) {
                                Write-Host ""
                                Write-Host "[1] Generate Legacy ISO"
                                Write-Host "[2] Generate UEFI ISO"
                                Write-Host "[3] Return to Customisation Menu"
                                Write-Host ""
                                [Int]$WinPEISOMenu = read-Host "Please select an option."
                            }
                            Switch ( $WinPEISOMenu ) {
                                1 {
                                    # Generate Legacy ISO
                                    If ( $FilePath -eq $null ) {
                                        $FilePath = Read-Host "Please Enter WinPE Directory"
                                    }
                                    $TargetArch = "x86"
                                    $WinPEDir = "$FilePath"
                                    $WinADKLocation = "${env:ProgramFiles(x86)}\Windows Kits\10\Assessment and Deployment Kit"

                                    #Copy-Item -Path "$WinPEDir\winpe.wim" -Destination "$WinPEDir\ISO\sources\boot.wim" -ErrorAction Stop
                                    $BOOTDATA = '2#p0,e,b"{0}"#pEF,e,b"{1}"' -f "$WinPEDir\etfsboot.com", "$WinPEDir\efisys.bin"
                                    & (Get-Command "$WinADKLocation\Deployment Tools\$TargetArch\Oscdimg\oscdimg.exe") @("-bootdata:$BOOTDATA", '-u1', '-udfver102', "$WinPEDir\ISO", "$WinPEDir\WinPE5_$TargetArch.iso")
                                }
                                2 {
                                    # Generate UEFI ISO
                                    If ( $FilePath -eq $null ) {
                                        $FilePath = Read-Host "Please Enter WinPE Directory"
                                    }
                                    $TargetArch = "amd64"
                                    $WinPEDir = "$FilePath"
                                    $WinADKLocation = "${env:ProgramFiles(x86)}\Windows Kits\10\Assessment and Deployment Kit"

                                    #Copy-Item -Path "$WinPEDir\winpe.wim" -Destination "$WinPEDir\ISO\sources\boot.wim" -ErrorAction Stop
                                    $BOOTDATA = '2#p0,e,b"{0}"#pEF,e,b"{1}"' -f "$WinPEDir\etfsboot.com", "$WinPEDir\efisys.bin"
                                    & (Get-Command "$WinADKLocation\Deployment Tools\$TargetArch\Oscdimg\oscdimg.exe") @("-bootdata:$BOOTDATA", '-u2', '-udfver102', "$WinPEDir\ISO", "$WinPEDir\WinPE5_$TargetArch.iso")
                                    
                                }
                            }
                        } while ( $WinPEISOMenu -ne 3 )
                    }
                    9 {
                        exit
                    }
                }
            } while ( $WIMEditMenu -ne 8 )
        }
    }
} while ( $WinPEMenu -ne 6 )