#params
param(
    [String]$PackagePath
)

$SandboxOperatingFolder = 'C:\SandboxEnvironment' 
$SandboxFile = "$((get-item $PackagePath).BaseName).wsb"
$FolderPath = Split-Path (Split-Path "$PackagePath" -Parent) -Leaf
$FileName = (get-item $PackagePath).Name

$SandboxDesktopPath = "C:\Users\WDAGUtilityAccount\Desktop"
$SandboxTempFolder = 'C:\Temp' 
$SandboxSharedPath = "$SandboxDesktopPath\$FolderPath"
$FullStartupPath = "$SandboxSharedPath\$FileName"
$FullStartupPath = """$FullStartupPath"""

If (!(Test-Path -Path $SandboxOperatingFolder -PathType Container))
{
    New-Item -Path $SandboxOperatingFolder -ItemType Directory
}
Function New-WSB
{
    Param
    (
        [String]$CommandtoRun	
    )	
		
    new-item -Path $SandboxOperatingFolder -Name $SandboxFile -type file -force | out-null
    $Config = @"
<Configuration>
<VGpu>Enable</VGpu>
<Networking>Enable</Networking>
<MappedFolders>	
<MappedFolder>	
<HostFolder>$((get-item $PackagePath).Directory)</HostFolder>	
<ReadOnly>true</ReadOnly>	
</MappedFolder>
<MappedFolder>	
<HostFolder>C:\SandboxEnvironment\bin</HostFolder>	
<ReadOnly>true</ReadOnly>	
</MappedFolder>	
</MappedFolders>	
<LogonCommand>	
<Command>$CommandtoRun</Command>	
</LogonCommand>	
</Configuration>
"@
    Set-Content -Path "$SandboxOperatingFolder\$SandboxFile" -Value $Config
}


$ScriptBlock = @"
If (!(Test-Path -Path $SandboxTempFolder -PathType Container))
{
	New-Item -Path $SandboxTempFolder -ItemType Directory
}
Copy-Item -Path $FullStartupPath -Destination $SandboxTempFolder
`$Decoder = Start-Process -FilePath $SandboxDesktopPath\bin\IntuneWinAppUtilDecoder.exe -ArgumentList "$SandboxTempFolder\$FileName /s" -NoNewWindow -PassThru -Wait

Rename-Item -Path "$SandboxTempFolder\$FileName.decoded" -NewName `'$($FileName -replace '.intunewin','.zip')`' -Force;
Expand-Archive -Path "$SandboxTempFolder\$($FileName -replace '.intunewin','.zip')" -Destination $SandboxTempFolder -Force;
Remove-Item -Path "$SandboxTempFolder\$($FileName -replace '.intunewin','.zip')" -Force;
Start-Process powershell.exe -noprofile -executionpolicy bypass -File `'$SandboxTempFolder\$($FileName -replace '.intunewin','.ps1')`' -NoNewWindow -PassThru -Wait
"@

New-Item -Path $SandboxOperatingFolder\bin -Name LogonCommand.ps1 -ItemType File -Value $ScriptBlock -Force | Out-Null

$Script:Startup_Command = "powershell.exe -sta -WindowStyle Hidden -noprofile -executionpolicy bypass -File $SandboxDesktopPath\bin\LogonCommand.ps1"

New-WSB -CommandtoRun $Startup_Command		

Start-Process $SandboxOperatingFolder\$SandboxFile