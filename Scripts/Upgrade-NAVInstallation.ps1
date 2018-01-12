Add-Type -AssemblyName System.IO.Compression.FileSystem

# Stop NAV Servers
& (Join-path $PSScriptRoot 'Stop-NAVServices.ps1')

# Get Environment Settings
$SetupParameters = Get-GITSettings

$navVersions = Get-NAVVersions
foreach ($navVersion in $navVersions.Releases) {
    Write-Host "Updating installation for $($navVersion.navRelease)..."
    $navInstallation = Get-Item -Path (Join-Path $env:ProgramFiles "Microsoft Dynamics NAV\\$($navVersion.mainVersion)\\Service\\Microsoft.Dynamics.Nav.Server.exe")
    $navInstallationVersion = (Get-ItemProperty -Path $navInstallation.FullName).VersionInfo.FileVersion    
    [String]$Language = Get-NAVInstallationCountry -NavInstallationPath (Split-Path $navInstallation -Parent)
    Write-Host "Updating folder $navInstallation with version $navInstallationVersion for language $($Language.SubString(0,2).ToUpper())..."
    $Package = $SetupParameters.navZipFiles.Replace('%navRelease%',$navVersion.navRelease).Replace('%navVersion%',$navVersion.mainVersion)
    $zipFile = (Get-ChildItem -Path $Package -Filter "CU * NAV $($navVersion.navRelease) $($Language.SubString(0,2).ToUpper()).zip" -File | Sort-Object LastAccessTime -Descending)[0].FullName
    Write-Host "Using $zipFile to update the current installation..."
    $installWorkFolder = Join-Path $SetupParameters.rootPath "$($navVersion.navRelease)$($Language.SubString(0,2).ToUpper())"
    Remove-Item -Path $installWorkFolder -Force -Recurse -ErrorAction SilentlyContinue
    New-Item -Path $installWorkFolder -ItemType Directory | Out-Null
    [System.IO.Compression.ZipFile]::ExtractToDirectory($zipFile, $installWorkFolder)
    $tempZipFile = Get-ChildItem -Path $installWorkFolder -Filter "NAV*.zip"
    [System.IO.Compression.ZipFile]::ExtractToDirectory($tempZipFile.FullName, $installWorkFolder) 
    Remove-Item -Path $tempZipFile.FullName -Force -Recurse

    $zipFileVersion = (Get-ItemProperty -Path (Join-Path $installWorkFolder "ServiceTier\\program files\\Microsoft Dynamics NAV\\$($navVersion.mainVersion)\\Service\\Microsoft.Dynamics.Nav.Server.exe")).VersionInfo.FileVersion
    if ($zipFileVersion -gt $navInstallationVersion) {
        Write-Host "Starting $($navVersion.navRelease) update by running Setup.exe /quiet /repair ..."
        Start-Process -FilePath (Join-Path $installWorkFolder "Setup.exe") -ArgumentList "/quiet /repair" -Wait
        Write-Host "$($navVersion.navRelease) updated!"
    } else {
        Write-host "$($navVersion.navRelease) already updated!"
    }
}

& (Join-path $PSScriptRoot 'Prepare-NAVEnvironment.ps1')