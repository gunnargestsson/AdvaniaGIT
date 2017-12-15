$BackupDestinationFilePath = Join-Path $SetupParameters.BackupPath "$($SetupParameters.navRelease)-$($SetupParameters.projectName).bak"
if (Test-Path $BackupDestinationFilePath) {
    Write-Host "Found file $BackupDestinationFilePath"
    if ($SetupParameters.ftpServer -gt "") {
        Write-Host "Upload $(Split-Path $BackupDestinationFilePath -Leaf) to $($SetupParameters.ftpServer)..."
        Create-FtpDirectory -Server $SetupParameters.ftpServer -User $SetupParameters.ftpUser -Pass $SetupParameters.ftpPass -FtpDirectoryPath $SetupParameters.navRelease    
        $BackupFtpDestinationPath = Join-Path $SetupParameters.navRelease "$($SetupParameters.projectName).bak"
        Put-FtpFile -Server $SetupParameters.ftpServer -User $SetupParameters.ftpUser -Pass $SetupParameters.ftpPass -LocalFilePath $BackupDestinationFilePath -FtpFilePath $BackupFtpDestinationPath
    }
} else {
    Write-Host "Did not find file $BackupDestinationFilePath"
}