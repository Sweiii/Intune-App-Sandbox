$SandboxOperatingFolder = 'C:\SandboxEnvironment\bin'
If (!(Test-Path -Path $SandboxOperatingFolder -PathType Container))
{
    New-Item -Path $SandboxOperatingFolder -ItemType Directory
}
Copy-Item -Path $PSScriptRoot\Configuration\* -Recurse  -Destination $SandboxOperatingFolder -Force

New-PSDrive -PSProvider registry -Root HKEY_CLASSES_ROOT -Name HKCR_SD | out-null

New-Item -Path HKCR_SD:\ -Name '.intunewin'
New-Item -Path HKCR_SD:\.intunewin -Name 'Shell'
Set-Item -Path HKCR_SD:\.intunewin\Shell -Value Open
New-Item -Path HKCR_SD:\.intunewin\Shell -Name 'Run test in Sandbox'
New-ItemProperty -Path 'HKCR_SD:\.intunewin\Shell\Run test in Sandbox' -Name icon -PropertyType 'String' -Value "$SandboxOperatingFolder\sandbox.ico"
New-Item -Path 'HKCR_SD:\.intunewin\Shell\Run test in Sandbox' -Name 'Command'
Set-Item -Path 'HKCR_SD:\.intunewin\Shell\Run test in Sandbox\Command' -Value "C:\Windows\system32\WindowsPowerShell\v1.0\powershell.exe -executionpolicy bypass -file $SandboxOperatingFolder\Invoke-Test.ps1 -PackagePath `"%V`""