# Download Latest CU

$installWorkFolder = Join-Path $SetupParameters.rootPath "$($SetupParameters.navRelease)$($SetupParameters.navSolution)"
Download-LatestNAVUpdate -SetupParameters $SetupParameters -InstallWorkFolder $InstallWorkFolder -Language $SetupParameters.navSolution

$zipFileVersion = (Get-ItemProperty -Path (Join-Path $installWorkFolder "ServiceTier\\program files\\Microsoft Dynamics NAV\\$($SetupParameters.mainVersion)\\Service\\Microsoft.Dynamics.Nav.Server.exe")).VersionInfo.FileVersion
$navGITVersion = $SetupParameters.navVersion
if ($zipFileVersion -gt $navGITVersion) {
    Write-Host "Copying backup file from installation media..."
    $BackupDestinationFilePath = Join-Path $SetupParameters.BackupPath "$($SetupParameters.navRelease)-$($SetupParameters.navSolution).bak"
    $BackupSourceFile = (Get-ChildItem -Path (Join-Path $installWorkFolder "SQLDemoDatabase\\CommonAppData\\Microsoft\\Microsoft Dynamics NAV\\$($SetupParameters.mainVersion)\\Database\\") -Filter "*.bak")[0]
    Copy-Item -Path $BackupSourceFile.FullName -Destination $BackupDestinationFilePath -Force
    
    & (Join-path $PSScriptRoot 'Remove-NavEnvironment.ps1')
    $BranchSettings = Get-BranchSettings -SetupParameters $SetupParameters
    $SetupParameters.navVersion = $zipFileVersion
    & (Join-path $PSScriptRoot 'Build-NavEnvironment.ps1')
    & (Join-path $PSScriptRoot 'ImportFrom-NAVtoTarget.ps1')
    if ($SetupParameters.storeAllObjects -ieq "true") {
        & (Join-path $PSScriptRoot 'Replace-GITwithTarget.ps1')
    }

    Write-Host "Copying source file from work folder..."
    $SourceDestinationFilePath = Join-Path $SetupParameters.SourcePath "$($SetupParameters.navRelease)-$($SetupParameters.navSolution).txt"
    Copy-Item -Path (Join-Path $SetupParameters.WorkFolder "target.txt") -Destination $SourceDestinationFilePath -Force

    Write-Host "Updating Setup.json..."
    $SetupJson = Get-Content $SetupParameters.setupPath | Out-String | ConvertFrom-Json
    $SetupJson.navVersion = $zipFileVersion
    $Article = Get-NAVLatestBlogArticle -SetupParameters $SetupParameters
    $CU = $Article.title -replace '\D+(\d+)','$1'
    $CU = ($CU.Substring(0,$CU.IndexOf($SetupParameters.navRelease))).TrimStart('0')
    $SetupJson | Add-Member -MemberType NoteProperty -Name navBuild -Value "$($SetupParameters.navRelease)-cu$CU" -Force
    Set-Content -Path $SetupParameters.setupPath -Value ($SetupJson | ConvertTo-Json)

    if ($SetupParameters.ftpServer -gt "") {
        Write-Host "Upload Results to $($SetupParameters.ftpServer)..."
        Create-FtpDirectory -Server $SetupParameters.ftpServer -User $SetupParameters.ftpUser -Pass $SetupParameters.ftpPass -FtpDirectoryPath $SetupParameters.navRelease
        Create-FtpDirectory -Server $SetupParameters.ftpServer -User $SetupParameters.ftpUser -Pass $SetupParameters.ftpPass -FtpDirectoryPath (Join-Path $SetupParameters.navRelease $SetupParameters.navVersion)
        $BackupFtpDestinationPath = Join-Path $SetupParameters.navRelease (Join-Path $SetupParameters.navVersion "$($SetupParameters.navSolution).bak")
        Put-FtpFile -Server $SetupParameters.ftpServer -User $SetupParameters.ftpUser -Pass $SetupParameters.ftpPass -LocalFilePath $BackupDestinationFilePath -FtpFilePath $BackupFtpDestinationPath
        $SourceFtpDestinationPath = Join-Path $SetupParameters.navRelease (Join-Path $SetupParameters.navVersion "$($SetupParameters.navSolution).txt")
        Put-FtpFile -Server $SetupParameters.ftpServer -User $SetupParameters.ftpUser -Pass $SetupParameters.ftpPass -LocalFilePath $SourceDestinationFilePath -FtpFilePath $SourceFtpDestinationPath
    }

} else {
    Write-host "$($SetupParameters.navRelease) already updated!"
}
