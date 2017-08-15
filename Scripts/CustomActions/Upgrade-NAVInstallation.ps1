# Download Latest CU
$Language = Get-InstalledLanguage -SetupParameters $SetupParameters
$installWorkFolder = Join-Path $SetupParameters.rootPath "$($SetupParameters.navRelease)$($Language)\"

Download-LatestNAVUpdate -SetupParameters $SetupParameters -InstallWorkFolder $InstallWorkFolder -Language $Language

$zipFileVersion = (Get-ItemProperty -Path (Join-Path $installWorkFolder "ServiceTier\\program files\\Microsoft Dynamics NAV\\$($SetupParameters.mainVersion)\\Service\\Microsoft.Dynamics.Nav.Server.exe")).VersionInfo.FileVersion
$navInstallationVersion = Get-InstalledBuild -SetupParameters $SetupParameters
if (!$navInstallationVersion) {
    Write-Host "Starting $($SetupParameters.navRelease) installation ..."
    Start-Process -FilePath (Join-Path $installWorkFolder "Setup.exe") -Wait
    Write-Host "Update $($SetupParameters.navRelease) information in AdvaniaGIT ..."
    Start-Process -FilePath (Join-Path $SetupParameters.rootPath "Data\NAVVersions.json")
    & (Join-path $PSScriptRoot 'Prepare-NAVEnvironment.ps1')
}
elseif ($zipFileVersion -gt $navInstallationVersion) {
    # Stop NAV Servers
    & (Join-path $PSScriptRoot 'Stop-NAVServices.ps1')

    Update-CurrentInstallSource -MainVersion $SetupParameters.mainVersion -NewInstallSource $installWorkFolder
    Update-NAVInstallationParameter -MainVersion $SetupParameters.mainVersion -ParameterId SQLReplaceDb -NewValue DROPDATABASE
    Write-Host "Starting $($SetupParameters.navRelease) update by running Setup.exe /quiet /repair ..."
    Start-Process -FilePath (Join-Path $installWorkFolder "Setup.exe") -ArgumentList "/quiet /repair" -Wait
    Write-Host "$($SetupParameters.navRelease) updated!"

    Write-Host "Upgrading databases..."
    $databases = Get-DatabaseNames -SetupParameters $SetupParameters | Where-Object -Property Name -Match "NAV$($Setupparameters.navRelease)DEV" | Sort-Object -Property Name
    foreach ($database in $databases) {        
        $databaseBranchSettings = Get-DatabaseBranchSettings -DatabaseName $database.Name
        if ($databaseBranchSettings.instanceName -ne "") {
            Invoke-NAVDatabaseConversion -SetupParameters $SetupParameters -BranchSettings $databaseBranchSettings
        }
    }

    & (Join-path $PSScriptRoot 'Prepare-NAVEnvironment.ps1')
} else {
    Write-host "$($SetupParameters.navRelease) already updated!"
}
