param
(
[Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
[String]$Repository = (Get-Location).Path,
[Parameter(Mandatory=$True, ValueFromPipelineByPropertyName=$true)]
[String]$ScriptName,
[Parameter(Mandatory=$False, ValueFromPipelineByPropertyName=$true)]
[String]$InAdminMode='$false',
[Parameter(Mandatory=$False, ValueFromPipelineByPropertyName=$true)]
[String]$Wait='$false',
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
    $ScriptToStart = (Join-path $PSScriptRoot $MyInvocation.MyCommand.Name)
    $ArgumentList = "-noprofile -file " + $ScriptToStart + " " + "`"$Repository`"" + " " + $ScriptName + " `$false $Wait" 
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
    try {
        $GitBranchName = (git.exe rev-parse --abbrev-ref HEAD)
        $SetupParameters | Add-Member "Branchname" $GitBranchName 
    } 
    catch
    {
        $SetupParameters | Add-Member "Branchname" ""
    }

    $SetupParameters | Add-Member "ConfigPath" (Join-Path $SetupParameters.rootPath "Data")

    # Create a dedicated Work Folder if running builds
    if (![String]::IsNullOrEmpty($BuildSettings)) { $SetupParameters = Combine-Settings (New-Object -TypeName PSObject -Property $BuildSettings) $SetupParameters }
    if ($SetupParameters.BuildMode) {
        $BranchWorkFolder = Join-Path $SetupParameters.rootPath "Log\$($SetupParameters.BranchId)"
        New-Item -Path $BranchWorkFolder -ItemType Directory -ErrorAction SilentlyContinue | Out-Null
        New-Item -Path (Join-Path $BranchWorkFolder "Data") -ItemType Directory -ErrorAction SilentlyContinue | Out-Null
        Copy-Item -Path (Join-Path $SetupParameters.ConfigPath "*.json") -Destination (Join-Path $BranchWorkFolder "Data")
        $SetupParameters.ConfigPath = (Join-Path $BranchWorkFolder "Data")
    }  
        
    # Find NAV major version based on the repository NAV version - client
    $mainVersion =  ($SetupParameters.navVersion).Split('.').GetValue(0) + ($SetupParameters.navVersion).Split('.').GetValue(1)
    $SetupParameters | Add-Member "mainVersion" $mainVersion
    $SetupParameters | Add-Member "developerService" ([int]$SetupParameters.mainVersion -gt 100)
    $SetupParameters | Add-Member "navIdePath" (Get-NAVClientPath -SetupParameters $SetupParameters)
    $SetupParameters | Add-Member "navServicePath" (Get-NAVServicePath -SetupParameters $SetupParameters)
    
    # Find NAV Release
    $SetupParameters | Add-Member "navRelease" (Get-NAVRelease -mainVersion $mainVersion)

    # Find Branch Settings
    $BranchSettings = Get-BranchSettings -SetupParameters $SetupParameters
    if ($IsInAdminMode) {
        if ($BranchSettings.dockerContainerName -gt "") {
            $DockerContainerConfiguration = Get-DockerContainerConfiguration -DockerContainerName $BranchSettings.dockerContainerName 
        }
    }
    
    # Set Global Parameters
    $Globals = New-Object -TypeName PSObject
    if ($SetupParameters.BuildMode) {
        $Globals | Add-Member WorkFolder $BranchWorkFolder
    } else {
        $Globals | Add-Member WorkFolder $SetupParameters.workFolder
    }
    $Globals | Add-Member BackupPath  (Join-Path $SetupParameters.rootPath "Backup")
    $Globals | Add-Member DatabasePath  (Join-Path $SetupParameters.rootPath "Database")
    $Globals | Add-Member SourcePath  (Join-Path $SetupParameters.rootPath "Source")
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
    $Globals | Add-Member testObjectsPath  (Join-Path $Repository $SetupParameters.testObjectsPath)
    $Globals | Add-Member buildSourcePath  (Join-Path $Repository $SetupParameters.buildSourcePath)
    $Globals | Add-Member LogPath  (Join-Path $SetupParameters.rootPath "Log\$([GUID]::NewGuid().GUID)")
    $Globals | Add-Member LicensePath  (Join-Path $SetupParameters.rootPath "License")

    if (![string]::IsNullOrEmpty($SetupParameters.licenseFile)) {
        $SetupParameters.licenseFile = ($SetupParameters.licenseFile).Replace("%1",($SetupParameters.navVersion).Split(".")[0])
        if (Test-Path -Path $SetupParameters.licenseFile) {
            $LicenseFileFullPath = $SetupParameters.licenseFile
        } elseif (Test-Path -Path (Join-Path $Globals.LicensePath $SetupParameters.licenseFile)) {
            $LicenseFileFullPath = (Join-Path $Globals.LicensePath $SetupParameters.licenseFile)
        } 
        if ($LicenseFileFullPath) {
            $Globals | Add-Member LicenseFilePath $LicenseFileFullPath 
            Write-Host -ForegroundColor Green "Using License: $($SetupParameters.licenseFile) on $($Globals.LicenseFilePath)"
        }
    }

    if (![string]::IsNullOrEmpty($SetupParameters.dependencyLicenseFile)) {
        $SetupParameters.dependencyLicenseFile = ($SetupParameters.dependencyLicenseFile).Replace("%1",($SetupParameters.navVersion).Split(".")[0])
        if (Test-Path -Path $SetupParameters.dependencyLicenseFile) {
            $dependencyLicenseFileFullPath = $SetupParameters.dependencyLicenseFile
        } elseif (Test-Path -Path (Join-Path $Globals.LicensePath $SetupParameters.dependencyLicenseFile)) {
            $dependencyLicenseFileFullPath = (Join-Path $Globals.LicensePath $SetupParameters.dependencyLicenseFile)
        } 
        if ($dependencyLicenseFileFullPath) {
            $Globals | Add-Member dependencyLicenseFilePath $dependencyLicenseFileFullPath
            Write-Host -ForegroundColor Green "Using License: $($SetupParameters.dependencyLicenseFile) on $($Globals.dependencyLicenseFilePath)" 
        }
    }
    $Globals | Add-Member DownloadPath  (Join-Path $SetupParameters.rootPath "Download")
    $Globals | Add-Member NewSyntaxTestObjectsPath  (Join-Path $Repository "$($SetupParameters.NewSyntaxPrefix)$($SetupParameters.testObjectsPath)")
    $Globals | Add-Member NewSyntaxObjectsPath  (Join-Path $Repository "$($SetupParameters.NewSyntaxPrefix)$($SetupParameters.objectsPath)")
    $Globals | Add-Member NewSyntaxDeltasPath  (Join-Path $Repository "$($SetupParameters.NewSyntaxPrefix)$($SetupParameters.deltasPath)")
    $Globals | Add-Member NewSyntaxReverseDeltasPath  (Join-Path $Repository "$($SetupParameters.NewSyntaxPrefix)$($SetupParameters.reverseDeltasPath)")
    $Globals | Add-Member VSCodePath  (Join-Path $Repository $SetupParameters.VSCodePath)
    if ([String]::IsNullOrEmpty($SetupParameters.VSCodeTestPath)) {
        $Globals | Add-Member VSCodeTestPath (Join-Path $Repository "$($SetupParameters.VSCodePath)$($SetupParameters.testObjectsPath)")
    } else {
        $Globals | Add-Member VSCodeTestPath (Join-Path $Repository $SetupParameters.VSCodeTestPath)
    }

    $SetupParameters = Combine-Settings $Globals $SetupParameters
    if (![String]::IsNullOrEmpty($BuildSettings)) { $SetupParameters = Combine-Settings (New-Object -TypeName PSObject -Property $BuildSettings) $SetupParameters }
    $SetupParameters = Expand-NAVConfigurationValues $SetupParameters

    New-Item -Path (Split-Path -Path $SetupParameters.LogPath -Parent) -ItemType Directory -ErrorAction SilentlyContinue | Out-Null
    New-Item -Path $SetupParameters.LogPath -ItemType Directory -ErrorAction SilentlyContinue | Out-Null
    if ($IsInAdminMode ) { Add-BlankLines -SetupParameters $SetupParameters }
    $env:WorkFolder = $SetupParameters.WorkFolder

    if (![bool]$SetupParameters.PSObject.Properties.Name -eq 'containerHelperModuleName') {
        $SetupParameters | Add-Member -MemberType NoteProperty -Name 'containerHelperModuleName' -Value 'NAVContainerHelper'
    }
    
    # Use NAV Container Helper if available
    if ($IsInAdminMode) {
        if (![Bool](Get-Module $SetupParameters.containerHelperModuleName)) {
            if ([Bool](Get-Module $SetupParameters.containerHelperModuleName -ListAvailable)) {
                if (!$SetupParameters.BuildMode) { Write-Host -ForegroundColor Green "Using NAV Container Helper from @freddydk..." }
                Import-Module $SetupParameters.containerHelperModuleName -DisableNameChecking
            }
        }
    }

    # Get the Sql Database Authentication for Containers
    if (![String]::IsNullOrEmpty($SetupParameters.dockerAuthentication) -and $SetupParameters.dockerAuthentication -ieq "NavUserPassword") {
        $DockerCredentials = Get-DockerAdminCredentials -Message "Enter credentials for the Docker Container" -DefaultUserName $env:USERNAME
        $SetupParameters | Add-Member SqlUsername $DockerCredentials.UserName
        $SetupParameters | Add-Member SqlPassword ([Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($DockerCredentials.Password)))
    }


    # Start the script
    $ScriptToStart = (Join-Path (Join-path $PSScriptRoot 'CustomActions') $ScriptName)
    if ($SetupParameters.BuildMode) {
        Write-Host "Starting ${ScriptName} in ${Repository}..."
        & $ScriptToStart
    } else {
        try { & $ScriptToStart }
        catch [Exception] {
          Write-Host $_.Exception.GetType().FullName, $_.Exception.Message
          if ($env:TERM_PROGRAM -eq $null -and $env:BAMBOO_AGENT_HOME -eq $null) {
            $anyKey = Read-Host "Press enter to continue..."
          }
          break
        }
    }
    Pop-Location
}

if (($Wait -eq $true -or $Wait -eq '$true') -and $IsInAdminMode) {
    $anyKey = Read-Host "Press enter to continue..."
}
