$BackupDestinationFilePath = Join-Path $SetupParameters.BackupPath "$($SetupParameters.navRelease)-$($SetupParameters.navSolution).bak"
if (Test-Path $BackupDestinationFilePath) {
    if ($SetupParameters.ftpServer -gt "") {
        Write-Host "Upload Results to $($SetupParameters.ftpServer)..."
        Create-FtpDirectory -Server $SetupParameters.ftpServer -User $SetupParameters.ftpUser -Pass $SetupParameters.ftpPass -FtpDirectoryPath $SetupParameters.navRelease    
        $BackupFtpDestinationPath = Join-Path $SetupParameters.navRelease "$($SetupParameters.navSolution).bak"
        Put-FtpFile -Server $SetupParameters.ftpServer -User $SetupParameters.ftpUser -Pass $SetupParameters.ftpPass -LocalFilePath $BackupDestinationFilePath -FtpFilePath $BackupFtpDestinationPath
    }
}