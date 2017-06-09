Add-Type -AssemblyName System.IO.Compression.FileSystem

Write-Host "Downloading CU information from Microsoft Blog..."
$DownloadUrls = Get-LatestCUDownloadUrls -SetupParameters $SetupParameters 

# Stop NAV Servers
& (Join-path $PSScriptRoot 'Stop-NAVServices.ps1')

Write-Host "Updating installation for $($SetupParameters.navRelease)..."
$navInstallation = Get-Item -Path (Join-Path $env:ProgramFiles "Microsoft Dynamics NAV\\$($SetupParameters.mainVersion)\\Service\\Microsoft.Dynamics.Nav.Server.exe")
$navInstallationVersion = (Get-ItemProperty -Path $navInstallation.FullName).VersionInfo.FileVersion    
$Languages = (Get-ChildItem (Split-Path $navInstallation -Parent) -Filter '??-??' -Directory)
if ($Languages) {
    $Language = $Languages[0].Name.SubString(3,2).ToUpper()
} else { 
    $Language = 'W1' 
}
Write-Host "Updating folder $navInstallation with version $navInstallationVersion for language $($Language)..."
$DownloadUrl = ($DownloadUrls | Where-Object -Property LocalVersion -EQ $Language).DownloadUrl
$DownloadFileName = Split-Path $DownloadUrl -Leaf
$zipFile = Join-Path $SetupParameters.DownloadPath $DownloadFileName
New-Item -Path $SetupParameters.DownloadPath -ItemType Directory -ErrorAction SilentlyContinue | Out-Null
if (Test-Path $zipFile) {
    Write-Host "$DownloadFileName already downloaded..."
} else {
    Download-File -Url $DownloadUrl -FileName $zipFile
}

Write-Host "Using $zipFile to update the current installation..."
$installWorkFolder = Join-Path $SetupParameters.rootPath "$($SetupParameters.navRelease)$($Language)"
Remove-Item -Path $installWorkFolder -Force -Recurse -ErrorAction SilentlyContinue
New-Item -Path $installWorkFolder -ItemType Directory | Out-Null
[System.IO.Compression.ZipFile]::ExtractToDirectory($zipFile, $installWorkFolder)
$tempZipFile = Get-ChildItem -Path $installWorkFolder -Filter "NAV*.zip"
[System.IO.Compression.ZipFile]::ExtractToDirectory($tempZipFile.FullName, $installWorkFolder) 
Remove-Item -Path $tempZipFile.FullName -Force -Recurse

$zipFileVersion = (Get-ItemProperty -Path (Join-Path $installWorkFolder "ServiceTier\\program files\\Microsoft Dynamics NAV\\$($SetupParameters.mainVersion)\\Service\\Microsoft.Dynamics.Nav.Server.exe")).VersionInfo.FileVersion
if ($zipFileVersion -gt $navInstallationVersion) {
    Write-Host "Starting $($SetupParameters.navRelease) update by running Setup.exe /quiet /repair ..."
    Start-Process -FilePath (Join-Path $installWorkFolder "Setup.exe") -ArgumentList "/quiet /repair" -Wait
    Write-Host "$($SetupParameters.navRelease) updated!"
} else {
    Write-host "$($SetupParameters.navRelease) already updated!"
}

Write-Host "Upgrading databases..."
$databases = Get-DatabaseNames -SetupParameters $SetupParameters | Where-Object -Property Name -Match "NAV$($Setupparameters.navRelease)DEV" | Sort-Object -Property Name
foreach ($database in $databases) {        
    $databaseBranchSettings = Get-DatabaseBranchSettings -DatabaseName $database.Name
    if ($databaseBranchSettings.instanceName -ne "") {
        Invoke-NAVDatabaseConversion -SetupParameters $SetupParameters -BranchSettings $databaseBranchSettings
    }
}

& (Join-path $PSScriptRoot 'Prepare-NAVEnvironment.ps1')