#Requires -RunAsAdministrator
<#
This is a configuration script which will create
folder at location C:\Sandbox for storing binaries, icons, scripts and wsb files.

It also adds options to system context menu for packing intuewin and testing
such package.

Such package should contain Install-Script.ps1 and all the neccessary binaries, executables.
To correctly create intunewin package, please name parent folder as the same as *.ps1 script within!

© 2020 Maciej Horbacz
#>
Clear-Host
Write-Host 'Thanks for using this tool!' -ForegroundColor Green
Write-Host 'Starting configuration process...' -ForegroundColor Yellow
Write-Host 'Checking for operating folder...' -ForegroundColor Yellow -NoNewline
$SandboxOperatingFolder = 'C:\SandboxEnvironment\bin'
If (!(Test-Path -Path $SandboxOperatingFolder -PathType Container)) {
    Start-Sleep 2
    Write-Host 'Not found!' -ForegroundColor Red
    Write-Host 'Adding operating folder...' -ForegroundColor Yellow
    New-Item -Path $SandboxOperatingFolder -ItemType Directory | out-null
    Start-Sleep 1
    Write-Host 'Folder found!' -ForegroundColor Green
    Write-Host "Copying crucial files to $SandboxOperatingFolder" -ForegroundColor Yellow
    Copy-Item -Path $PSScriptRoot\Configuration\* -Recurse -Destination $SandboxOperatingFolder -Force
}
else {
    Write-Host 'Folder found!' -ForegroundColor Green
    $FolderItems = Get-ChildItem $SandboxOperatingFolder
    $CrucialItems = @('Invoke-Test.ps1', 'intunewin-Box-icon.ico', 'IntuneWinAppUtilDecoder.exe', 'IntuneWinAppUtil.exe', 'sandbox.ico', 'Invoke-IntunewinUtil.ps1')
    foreach ($item in $CrucialItems) {
        if (!$FolderItems.Name.Contains($item)) {
            Copy-Item -Path $PSScriptRoot\Configuration\$item -Destination $SandboxOperatingFolder -Force
        }    
    }
}
Write-Host "
Contex menu options:
1 - Only 'Run test in Sandbox'
2 - Only 'Pack with IntunewinUtil'
3 - Both
" -ForegroundColor Yellow
Write-Host 'Please specify your choice: ' -ForegroundColor Yellow -NoNewline
$Option = Read-Host
New-PSDrive -PSProvider registry -Root HKEY_CLASSES_ROOT -Name HKCR_SD | out-null
switch ($Option) {
    1 {
        If (!(Test-Path -Path 'HKCR_SD:\.intunewin\Shell\Run test in Sandbox\Command')) {
            Write-Host 'Context menu item not present.' -ForegroundColor Green
            New-Item -Path HKCR_SD:\ -Name '.intunewin'
            New-Item -Path HKCR_SD:\.intunewin -Name 'Shell'
            Set-Item -Path HKCR_SD:\.intunewin\Shell -Value Open
            New-Item -Path HKCR_SD:\.intunewin\Shell -Name 'Run test in Sandbox'
            New-ItemProperty -Path 'HKCR_SD:\.intunewin\Shell\Run test in Sandbox' -Name icon -PropertyType 'String' -Value "$SandboxOperatingFolder\sandbox.ico"
            New-Item -Path 'HKCR_SD:\.intunewin\Shell\Run test in Sandbox' -Name 'Command'
            Set-Item -Path 'HKCR_SD:\.intunewin\Shell\Run test in Sandbox\Command' -Value "C:\Windows\system32\WindowsPowerShell\v1.0\powershell.exe -executionpolicy bypass -command $SandboxOperatingFolder\Invoke-Test.ps1 -PackagePath `"%V`""
        }
        else {
            Write-Host 'Context menu item already present!' -ForegroundColor Yellow
        }
    }
    2 {
        If (!(Test-Path -Path 'HKCR_SD:\Directory\Shell\Pack with IntunewinUtil\Command')) {
            Write-Host 'Context menu item not present.' -ForegroundColor Green
            New-Item -Path HKCR_SD:\Directory\Shell\ -Name 'Pack with IntunewinUtil'
            New-ItemProperty -Path 'HKCR_SD:\Directory\Shell\Pack with IntunewinUtil' -Name icon -PropertyType 'String' -Value "$SandboxOperatingFolder\intunewin-Box-icon.ico"
            New-Item -Path 'HKCR_SD:\Directory\Shell\Pack with IntunewinUtil' -Name 'Command'
            Set-Item -Path 'HKCR_SD:\Directory\Shell\Pack with IntunewinUtil\Command' -Value "C:\Windows\system32\WindowsPowerShell\v1.0\powershell.exe -executionpolicy bypass -file $SandboxOperatingFolder\Invoke-IntunewinUtil.ps1 -PackagePath `"%V`""
        }
        else {
            Write-Host 'Context menu item already present!' -ForegroundColor Yellow
        }
    }
    3 {
        If (!(Test-Path -Path 'HKCR_SD:\.intunewin\Shell\Run test in Sandbox\Command')) {
            Write-Host 'Context menu item not present.' -ForegroundColor Green
            New-Item -Path HKCR_SD:\ -Name '.intunewin'
            New-Item -Path HKCR_SD:\.intunewin -Name 'Shell'
            Set-Item -Path HKCR_SD:\.intunewin\Shell -Value Open
            New-Item -Path HKCR_SD:\.intunewin\Shell -Name 'Run test in Sandbox'
            New-ItemProperty -Path 'HKCR_SD:\.intunewin\Shell\Run test in Sandbox' -Name icon -PropertyType 'String' -Value "$SandboxOperatingFolder\sandbox.ico"
            New-Item -Path 'HKCR_SD:\.intunewin\Shell\Run test in Sandbox' -Name 'Command'
            Set-Item -Path 'HKCR_SD:\.intunewin\Shell\Run test in Sandbox\Command' -Value "C:\Windows\system32\WindowsPowerShell\v1.0\powershell.exe -executionpolicy bypass -command $SandboxOperatingFolder\Invoke-Test.ps1 -PackagePath `"%V`""
        }
        else {
            Write-Host 'Context menu item already present!' -ForegroundColor Yellow
        }
        If (!(Test-Path -Path 'HKCR_SD:\Directory\Shell\Pack with IntunewinUtil\Command')) {
            Write-Host 'Context menu item not present.' -ForegroundColor Green
            New-Item -Path HKCR_SD:\Directory\Shell\ -Name 'Pack with IntunewinUtil'
            New-ItemProperty -Path 'HKCR_SD:\Directory\Shell\Pack with IntunewinUtil' -Name icon -PropertyType 'String' -Value "$SandboxOperatingFolder\intunewin-Box-icon.ico"
            New-Item -Path 'HKCR_SD:\Directory\Shell\Pack with IntunewinUtil' -Name 'Command'
            Set-Item -Path 'HKCR_SD:\Directory\Shell\Pack with IntunewinUtil\Command' -Value "C:\Windows\system32\WindowsPowerShell\v1.0\powershell.exe -executionpolicy bypass -file $SandboxOperatingFolder\Invoke-IntunewinUtil.ps1 -PackagePath `"%V`""
        }
        else {
            Write-Host 'Context menu item already present!' -ForegroundColor Yellow
        }
    }
    Default {
        Write-Host 'Wrong option! Bye...' -ForegroundColor Red
        Exit
    }
}
Write-Host 'All done!' -ForegroundColor Green
Pause

