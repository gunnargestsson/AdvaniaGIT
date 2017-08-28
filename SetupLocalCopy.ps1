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

$DefaultPath = 'C:\AdvaniaGIT'
$InstallationPath = Read-Host -Prompt "Enter local path for AdvaniaGIT (default = C:\AdvaniaGIT)"
if ($InstallationPath -eq "") { $InstallationPath = $DefaultPath }
New-Item -Path $InstallationPath -ItemType Directory -ErrorAction SilentlyContinue
if (Test-Path -Path $InstallationPath) {
    Copy-Item -Path (Join-Path $PSScriptRoot 'TestDevel.ps1') -Destination $InstallationPath -Force -ErrorAction SilentlyContinue
    Copy-Item -Path (Join-Path $PSScriptRoot 'README.md') -Destination $InstallationPath -Force -ErrorAction SilentlyContinue
    $DirectoriesToCopy = @('Backup','Data','Database','Demo','License','Log','Source','Workspace')
    $DirectoriesToLink = @('Scripts','SourceTree')
    foreach ($Directory in $DirectoriesToCopy) {
        $Source = Join-Path $PSScriptRoot $Directory
        $Destination = Join-Path $InstallationPath $Directory
        New-Item -Path $Destination -ItemType Directory -ErrorAction SilentlyContinue
        $Items = Get-ChildItem -Path $Source 
        foreach ($Item in $Items) {
            if (!(Test-Path -Path (Join-Path $Destination $Item.Name))) {
                Copy-Item -Path $Item.FullName -Destination $Destination -Recurse -ErrorAction SilentlyContinue 
            }
        }
    }
    foreach ($Directory in $DirectoriesToLink) {
    $Source = Join-Path $PSScriptRoot $Directory
    $Destination = Join-Path $InstallationPath $Directory
    New-Item -Path $Destination -ItemType SymbolicLink -Value $Source -ErrorAction SilentlyContinue 
    }
}
else
{
    Write-Host -ForegroundColor Red "$InstallationPath not found!" 
    $input = Read-Host -Prompt "Press any key to continue..."
    break
}

$DefaultAnswer = 'Y'
$Answer = Read-Host -Prompt "Perform AdvaniaGIT Module Installation ? (Default = Yes)"
if ($Answer -iin ('Yes','Y','')) {
    $ScriptToStart = Join-Path $InstallationPath 'Scripts\Install-Modules.ps1'
    & $ScriptToStart

    Import-Module AdvaniaGIT -DisableNameChecking | Out-Null
    $GITSettings = Get-Content -Path (Join-Path $InstallationPath "Data\GITSettings.Json") | Out-String | ConvertFrom-Json
    $GITSettings.workFolder = (Join-Path $InstallationPath "Workspace")
    $NewGITSettings = Get-Content -Path (Join-Path $PSScriptRoot "Data\GITSettings.Json") | Out-String | ConvertFrom-Json
    $GITSettings = Combine-Settings $GITSettings $NewGITSettings
    Set-Content -Path (Join-Path $InstallationPath "Data\GITSettings.Json") -Value ($GITSettings | ConvertTo-Json) 


    Write-Host "Please update GITSettings.Json, DockerSettings.json and NAVVersions.Json to match your environment"
    Start-Process -FilePath (Join-Path $InstallationPath "Data\GITSettings.Json")
    Start-Process -FilePath (Join-Path $InstallationPath "Data\NAVVersions.Json")
    Start-Process -FilePath (Join-Path $InstallationPath "Data\DockerSettings.Json")
}

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
    $ScriptToStart = Join-Path $InstallationPath 'Scripts\Prepare-NAVEnvironment.ps1'
    & $ScriptToStart
}

$input = Read-Host -Prompt "Press any key to continue..."
