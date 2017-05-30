param
(
[Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
[String]$Repository,
[Parameter(Mandatory=$True, ValueFromPipelineByPropertyName=$true)]
[String]$ScriptName,
[Parameter(Mandatory=$False, ValueFromPipelineByPropertyName=$true)]
[String]$InAdminMode='$false',
[Parameter(Mandatory=$False, ValueFromPipelineByPropertyName=$true)]
[String]$Wait='$false'
)
# Get the ID and security principal of the current user account
$myWindowsID=[System.Security.Principal.WindowsIdentity]::GetCurrent()
$myWindowsPrincipal=new-object System.Security.Principal.WindowsPrincipal($myWindowsID)
 
# Get the security principal for the Administrator role
$adminRole=[System.Security.Principal.WindowsBuiltInRole]::Administrator
 
# Check to see if we are currently running "as Administrator"
$IsInAdminMode = $myWindowsPrincipal.IsInRole($adminRole)

if ($InAdminMode -eq '$true' -or $InAdminMode -eq $true) {
    Write-Host "Starting Script in Admin Mode..."
    $ScriptToStart = (Join-path $PSScriptRoot 'Start-CustomAction.ps1')
    $ArgumentList = "-noprofile -file " + $ScriptToStart + " " + $Repository + " " + $ScriptName + " `$false $Wait" 
    if ($Wait -eq $true -or $Wait -eq '$true') {
        Start-Process powershell -Verb runas -WorkingDirectory $Repository -ArgumentList $ArgumentList -WindowStyle Normal -Wait
    } else {
        Start-Process powershell -Verb runas -WorkingDirectory $Repository -ArgumentList $ArgumentList -WindowStyle Normal
    }
}
else
{
    # Import all needed modules
    Import-Module AdvaniaGIT -DisableNameChecking | Out-Null

    Push-Location 
    Set-Location $Repository
    
    # Get Environment Settings
    $SetupParameters = Get-GITSettings

    # Get Repository Settings
    $SetupParameters = (Combine-Settings $SetupParameters (Get-Content (Join-Path $Repository $SetupParameters.setupPath) | Out-String | ConvertFrom-Json))
    $SetupParameters | add-member "Repository" $Repository
    $GitBranchName = (git.exe rev-parse --abbrev-ref HEAD)
    $SetupParameters | add-member "Branchname" $GitBranchName 
    
    # Find NAV major version based on the repository NAV version - client
    $mainVersion =  ($SetupParameters.navVersion).Split('.').GetValue(0) + ($SetupParameters.navVersion).Split('.').GetValue(1)
    $SetupParameters | add-member "mainVersion" $mainVersion
    $SetupParameters | add-member "navIdePath" (Get-NAVClientPath -SetupParameters $SetupParameters)
    $SetupParameters | add-member "navServicePath" (Get-NAVServicePath -SetupParameters $SetupParameters)
    
    # Find NAV Release
    $SetupParameters | add-member "navRelease" (Get-NAVRelease -mainVersion $mainVersion)

    # Find Branch Settings
    $BranchSettings = Get-BranchSettings -SetupParameters $SetupParameters
    
    # Set Global Parameters
    $WorkFolder = $SetupParameters.workFolder
    $SetupPath = (Join-Path $Repository $SetupParameters.setupPath)
    $ObjectsPath = (Join-Path $Repository $SetupParameters.objectsPath)
    $DeltasPath = (Join-Path $Repository $SetupParameters.deltasPath)
    $ReverseDeltasPath = (Join-Path $Repository $SetupParameters.reverseDeltasPath)
    $ExtensionPath = (Join-Path $Repository $SetupParameters.extensionPath)
    $ImagesPath = (Join-Path $Repository $SetupParameters.imagesPath)
    $ScreenshotsPath = (Join-Path $Repository $SetupParameters.screenshotsPath)
    $PermissionSetsPath = (Join-Path $Repository $SetupParameters.permissionSetsPath)
    $AddinsPath = (Join-Path $Repository $SetupParameters.addinsPath)
    $LanguagePath = (Join-Path $Repository $SetupParameters.languagePath)
    $TableDataPath = (Join-Path $Repository $SetupParameters.tableDataPath)
    $CustomReportLayoutsPath = (Join-Path $Repository $SetupParameters.customReportLayoutsPath)
    $WebServicesPath = (Join-Path $Repository $SetupParameters.webServicesPath)
    $BinaryPath = (Join-Path $Repository $SetupParameters.binaryPath)
    $LogPath = (Join-Path $SetupParameters.rootPath "Log\$([GUID]::NewGuid().GUID)")
    $BackupPath = (Join-Path $SetupParameters.rootPath "Backup")
    $DatabasePath = (Join-Path $SetupParameters.rootPath "Database")
    
    New-Item -Path (Split-Path -Path $LogPath -Parent) -ItemType Directory -ErrorAction SilentlyContinue | Out-Null
    New-Item -Path $LogPath -ItemType Directory -ErrorAction SilentlyContinue | Out-Null
    if ($IsInAdminMode) { For ($i=0; $i -le 10; $i++) { Write-Host "" }}
    
    # Start the script
    $ScriptToStart = (Join-Path (Join-path $PSScriptRoot 'CustomActions') $ScriptName)
    & $ScriptToStart 
    Pop-Location
}

if (($Wait -eq $true -or $Wait -eq '$true') -and $IsInAdminMode) {
    $anyKey = Read-Host "Press enter to continue..."
}
