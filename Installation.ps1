# Make sure to only run this script in Admin Mode

# Get the ID and security principal of the current user account
$myWindowsID=[System.Security.Principal.WindowsIdentity]::GetCurrent()
$myWindowsPrincipal=new-object System.Security.Principal.WindowsPrincipal($myWindowsID)
 
# Get the security principal for the Administrator role
$adminRole=[System.Security.Principal.WindowsBuiltInRole]::Administrator
 
# Check to see if we are currently running "as Administrator"
$IsInAdminMode = $myWindowsPrincipal.IsInRole($adminRole)

if (!$IsInAdminMode) {
    Write-Host "Starting Script in Admin Mode..." 
    $ScriptToStart = (Join-path $PSScriptRoot $MyInvocation.MyCommand.Name)
    $ArgumentList = "-noprofile -file " + $ScriptToStart  
    Start-Process powershell -Verb runas -WorkingDirectory $PSScriptRoot -ArgumentList $ArgumentList -WindowStyle Normal -Wait
    break
}
Write-Host "Starting AdvaniaGIT Installation/Upgrade..."

Get-Module -Name "AdvaniaGIT" | Remove-Module
$Module = (Get-Module -ListAvailable | Where-Object -Property Name -EQ "AdvaniaGIT")
if ($Module) {
    $InstallationPath = Split-Path (Split-Path (Split-Path $Module.Path -Parent) -Parent) -Parent
    Write-Host "AdvaniaGIT module found on path $InstallationPath"
    Write-Host "Upgrading..."
} else {
    $DefaultPath = (Join-Path $env:SystemDrive 'AdvaniaGIT')
    Write-Host "This will install AdvaniaGIT on your computer.  Please select a local path for the module."
    Write-Host "Database, backups and installation media will be stored in this folder."
    Write-Host "Close this window to cancel installation/upgrade"
    Write-Host ""
    $InstallationPath = Read-Host -Prompt "Enter local path for AdvaniaGIT (default = $DefaultPath)"
    if ($InstallationPath -eq "") { $InstallationPath = $DefaultPath }
}
New-Item -Path $InstallationPath -ItemType Directory -ErrorAction SilentlyContinue
if (Test-Path -Path $InstallationPath) {
    if (!(Test-Path (Join-Path $InstallationPath 'TestDevel.ps1'))) {
        Copy-Item -Path (Join-Path $PSScriptRoot 'TestDevel.ps1') -Destination $InstallationPath -ErrorAction SilentlyContinue
    }
    Copy-Item -Path (Join-Path $PSScriptRoot 'README.md') -Destination $InstallationPath -Force -ErrorAction SilentlyContinue
    $DirectoriesToCopy = @('Backup','Database','Demo','License','Log','Source','Workspace','Scripts','SourceTree')
    foreach ($Directory in $DirectoriesToCopy) {
        $Source = Join-Path $PSScriptRoot $Directory
        $Destination = Join-Path $InstallationPath $Directory
        New-Item -Path $Destination -ItemType Directory -ErrorAction SilentlyContinue
        $Items = Get-ChildItem -Path $Source 
        foreach ($Item in $Items) {
            Copy-Item -Path $Item.FullName -Destination $Destination -Recurse -Force -ErrorAction SilentlyContinue             
        }
    }
    $Destination = Join-Path $InstallationPath 'Data'
    New-Item -Path $Destination -ItemType Directory -ErrorAction SilentlyContinue
}
else
{
    Write-Host -ForegroundColor Red "$InstallationPath not found!" 
    $input = Read-Host -Prompt "Press any key to continue..."
    break
}

$ScriptToStart = Join-Path $InstallationPath 'Scripts\Install-Modules.ps1'
& $ScriptToStart

Import-Module AdvaniaGIT -DisableNameChecking | Out-Null
foreach ($configFile in (Get-ChildItem -Path (Join-Path $PSScriptRoot 'Data\*.json'))) {
    $InstalledConfigFile = (Join-Path (Join-Path $InstallationPath 'Data') $configFile.Name)
    if (Test-Path $InstalledConfigFile) {
        if ($configFile.BaseName -iin ('DockerSettings','GITSettings')) {
            $installedConfig = Get-Content -Path $InstalledConfigFile -Encoding UTF8 | Out-String | ConvertFrom-Json
            $newConfig = Get-Content -Path $configFile.FullName -Encoding UTF8 | Out-String | ConvertFrom-Json
            $config = Combine-Settings $installedConfig $newconfig
            if ($configFile.Name -eq "GITSettings.Json") {
            $config.workFolder = (Join-Path $InstallationPath "Workspace")
            }
            Set-Content -Path $InstalledConfigFile -Encoding UTF8 -Value ($config | ConvertTo-Json) 
            Start-Process -FilePath $InstalledConfigFile
        }
    } else {
        Copy-Item -Path $configFile.FullName -Destination (Join-Path $InstallationPath 'Data')
        if ($configFile.BaseName -iin ('DockerSettings','GITSettings')) {
            Start-Process -FilePath $InstalledConfigFile
        }
    }    
}
Write-Host "Please update configuration files to match your environment (opened automatically)"


$DefaultAnswer = 'Y'
$Answer = Read-Host -Prompt "Perform Remote Administration Module Installation ? (Default = No)"
if ($Answer -iin ('Yes','Y')) {
    $ScriptToStart = Join-Path $InstallationPath 'Scripts\Install-RemoteManagementModules.ps1'
    & $ScriptToStart
    Start-Process -FilePath (Join-Path $InstallationPath "Data\RemoteSettings.Json")
}

$DefaultAnswer = 'Y'
$Answer = Read-Host -Prompt "Perform NAV Environment Configuration (required after NAV installation) ? (Default = Yes)"
if ($Answer -iin ('Yes','Y','')) {
    $SetupParameters = Get-Content -Path (Join-Path $InstallationPath "Data\GITSettings.Json") | Out-String | ConvertFrom-Json
    $ScriptToStart = Join-Path $InstallationPath 'Scripts\Prepare-NAVEnvironment.ps1'
    & $ScriptToStart
}

