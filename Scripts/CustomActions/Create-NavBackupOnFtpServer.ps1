if ($SetupParameters.ftpServer -gt "") {
    Check-NAVServiceRunning -SetupParameters $SetupParameters -BranchSettings $BranchSettings
    if ($BranchSettings.dockerContainerId -gt "") {
        Start-DockerCustomAction -BranchSettings $BranchSettings -ScriptName $MyInvocation.MyCommand.Name -BuildSettings $BuildSettings
    } else {    
        $BackupFilePath = Join-Path $SetupParameters.LogPath "NAVBackupToPublish.bak"
        Write-Host "Requesting new NAV backup for branch" $SetupParameters.projectName
        Write-Host "Removing NAV License from database before backing up..."
        Remove-NAVDatabaseLicense -BranchSettings $BranchSettings
        Create-NAVDatabaseBackup -SetupParameters $SetupParameters -BranchSettings $BranchSettings -BackupFilePath $BackupFilePath
        if ($SetupParameters.LicenseFilePath) {
            if (Test-Path $SetupParameters.LicenseFilePath) {  
                Load-InstanceAdminTools -SetupParameters $SetupParameters
                Update-NAVLicense -BranchSettings $BranchSettings -LicenseFilePath $SetupParameters.LicenseFilePath
                UnLoad-InstanceAdminTools
            }
        }

        Write-Host "Upload Results to $($SetupParameters.ftpServer)..."
        Create-FtpDirectory -Server $SetupParameters.ftpServer -User $SetupParameters.ftpUser -Pass $SetupParameters.ftpPass -FtpDirectoryPath $SetupParameters.navRelease
        Create-FtpDirectory -Server $SetupParameters.ftpServer -User $SetupParameters.ftpUser -Pass $SetupParameters.ftpPass -FtpDirectoryPath (Join-Path $SetupParameters.navRelease $SetupParameters.navVersion)
        $BackupFtpDestinationPath = Join-Path $SetupParameters.navRelease "$($SetupParameters.projectName).bak"
        Put-FtpFile -Server $SetupParameters.ftpServer -User $SetupParameters.ftpUser -Pass $SetupParameters.ftpPass -LocalFilePath $BackupFilePath -FtpFilePath $BackupFtpDestinationPath
        Remove-Item -Path $BackupFilePath -ErrorAction SilentlyContinue
    }
} else {
    Write-Error "No Ftp Server configured!"
}
