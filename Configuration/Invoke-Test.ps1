#params
params(
    [String]$PackagePath
)
$SandboxOperatingFolder = 'C:\SandboxEnvironment'
$SandboxFile = "$((get-item $PackagePath).BaseName).wsb"
$FolderPath = Split-Path (Split-Path "$ScriptPath" -Parent) -Leaf
$FileName = (get-item $ScriptPath).Name

$SandboxDesktopPath = "C:\Users\WDAGUtilityAccount\Desktop"
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
"<Configuration>"
"<VGpu>Enable</VGpu>"
"<Networking>Enable</Networking>"
"<MappedFolders>"	
"<MappedFolder>"	
"<HostFolder>$((get-item $PackagePath).Directory)</HostFolder>"	
"<ReadOnly>false</ReadOnly>"	
"</MappedFolder>"	
"</MappedFolders>"	
"<LogonCommand>"	
"<Command>$CommandtoRun</Command>"	
"</LogonCommand>"	
"</Configuration>"
"@
    Set-Content -Path $SandboxOperatingFolder -Name $SandboxFile -Value $Config
}

	
$ScriptBlock = {

    $FullStartupPath
}
$Script:Startup_Command = "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -sta -WindowStyle Hidden -noprofile -executionpolicy unrestricted -Command $ScriptBlock"			

New-WSB -CommandtoRun $Startup_Command		

Start-Process $SandboxFile