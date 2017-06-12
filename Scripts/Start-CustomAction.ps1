param
(
[Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
[String]$Repository,
[Parameter(Mandatory=$True, ValueFromPipelineByPropertyName=$true)]
[String]$ScriptName,
[Parameter(Mandatory=$False, ValueFromPipelineByPropertyName=$true)]
[String]$InAdminMode='$false',
[Parameter(Mandatory=$False, ValueFromPipelineByPropertyName=$true)]
[String]$Wait='$false',
[Parameter(Mandatory=$False, ValueFromPipelineByPropertyName=$true)]
[String]$BuildFolder,
[Parameter(Mandatory=$False, ValueFromPipelineByPropertyName=$true)]
[HashTable]$BuildSettings
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
    $SetupParameters = (Combine-Settings (Get-Content (Join-Path $Repository $SetupParameters.setupPath) | Out-String | ConvertFrom-Json) $SetupParameters)
    $SetupParameters | Add-Member "Repository" $Repository
    $GitBranchName = (git.exe rev-parse --abbrev-ref HEAD)
    $SetupParameters | Add-Member "Branchname" $GitBranchName 
    
    # Find NAV major version based on the repository NAV version - client
    $mainVersion =  ($SetupParameters.navVersion).Split('.').GetValue(0) + ($SetupParameters.navVersion).Split('.').GetValue(1)
    $SetupParameters | Add-Member "mainVersion" $mainVersion
    $SetupParameters | Add-Member "navIdePath" (Get-NAVClientPath -SetupParameters $SetupParameters)
    $SetupParameters | Add-Member "navServicePath" (Get-NAVServicePath -SetupParameters $SetupParameters)
    
    # Find NAV Release
    $SetupParameters | Add-Member "navRelease" (Get-NAVRelease -mainVersion $mainVersion)

    # Find Branch Settings
    $BranchSettings = Get-BranchSettings -SetupParameters $SetupParameters
    
    # Set Global Parameters
    $Globals = New-Object -TypeName PSObject
    if ($BuildFolder) {
        $Globals | Add-Member WorkFolder $BuildFolder
        $Globals | Add-Member BackupPath  $BuildFolder
        $Globals | Add-Member DatabasePath  $BuildFolder
        $Globals | Add-Member SourcePath  $BuildFolder
        $Globals | Add-Member ExecutingBuild $true
    } else {
        $Globals | Add-Member WorkFolder $SetupParameters.workFolder
        $Globals | Add-Member BackupPath  (Join-Path $SetupParameters.rootPath "Backup")
        $Globals | Add-Member DatabasePath  (Join-Path $SetupParameters.rootPath "Database")
        $Globals | Add-Member SourcePath  (Join-Path $SetupParameters.rootPath "Source")
        $Globals | Add-Member ExecutingBuild $false
    }    
    $Globals | Add-Member SetupPath  (Join-Path $Repository $SetupParameters.setupPath)
    $Globals | Add-Member ObjectsPath  (Join-Path $Repository $SetupParameters.objectsPath)
    $Globals | Add-Member DeltasPath  (Join-Path $Repository $SetupParameters.deltasPath)
    $Globals | Add-Member ReverseDeltasPath  (Join-Path $Repository $SetupParameters.reverseDeltasPath)
    $Globals | Add-Member ExtensionPath  (Join-Path $Repository $SetupParameters.extensionPath)
    $Globals | Add-Member ImagesPath  (Join-Path $Repository $SetupParameters.imagesPath)
    $Globals | Add-Member ScreenshotsPath  (Join-Path $Repository $SetupParameters.screenshotsPath)
    $Globals | Add-Member PermissionSetsPath  (Join-Path $Repository $SetupParameters.permissionSetsPath)
    $Globals | Add-Member AddinsPath  (Join-Path $Repository $SetupParameters.addinsPath)
    $Globals | Add-Member LanguagePath  (Join-Path $Repository $SetupParameters.languagePath)
    $Globals | Add-Member TableDataPath  (Join-Path $Repository $SetupParameters.tableDataPath)
    $Globals | Add-Member CustomReportLayoutsPath  (Join-Path $Repository $SetupParameters.customReportLayoutsPath)
    $Globals | Add-Member WebServicesPath  (Join-Path $Repository $SetupParameters.webServicesPath)
    $Globals | Add-Member BinaryPath  (Join-Path $Repository $SetupParameters.binaryPath)
    $Globals | Add-Member LogPath  (Join-Path $SetupParameters.rootPath "Log\$([GUID]::NewGuid().GUID)")
    $Globals | Add-Member LicensePath  (Join-Path $SetupParameters.rootPath "License")
    $Globals | Add-Member LicenseFilePath (Join-Path $Globals.LicensePath $SetupParameters.licenseFile)
    $Globals | Add-Member DownloadPath  (Join-Path $SetupParameters.rootPath "Download")
    $SetupParameters = Combine-Settings $Globals $SetupParameters

    New-Item -Path (Split-Path -Path $SetupParameters.LogPath -Parent) -ItemType Directory -ErrorAction SilentlyContinue | Out-Null
    New-Item -Path $SetupParameters.LogPath -ItemType Directory -ErrorAction SilentlyContinue | Out-Null
    if ($IsInAdminMode) { For ($i=0; $i -le 10; $i++) { Write-Host "" }}
    
    # Start the script
    $ScriptToStart = (Join-Path (Join-path $PSScriptRoot 'CustomActions') $ScriptName)
    & $ScriptToStart 
    Pop-Location
}

if (($Wait -eq $true -or $Wait -eq '$true') -and $IsInAdminMode) {
    $anyKey = Read-Host "Press enter to continue..."
}
