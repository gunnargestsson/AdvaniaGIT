if ($SetupParameters.BuildMode) {
    $BranchWorkFolder = Join-Path $SetupParameters.rootPath "Log\$($SetupParameters.BranchId)"

    $version = Get-NavContainerNavVersion -containerOrImageName $BranchSettings.dockerContainerName
    foreach ($ALPath in (Get-ChildItem -Path (Join-Path $BranchWorkFolder 'out'))) { 
        if (![String]::IsNullOrEmpty($SetupParameters.buildId)) {
            $destFileName = ($ALPath.Name).Replace("$($SetupParameters.buildId).app","0.app")
        } else {
            $destFileName = $ALPath.Name
        }

        Write-Host "Uploading ${destFileName} to FTP Server..."
        Create-FtpDirectory -Server $SetupParameters.ftpServer -User $SetupParameters.ftpUser -Pass $SetupParameters.ftpPass -FtpDirectoryPath "Build"
        Create-FtpDirectory -Server $SetupParameters.ftpServer -User $SetupParameters.ftpUser -Pass $SetupParameters.ftpPass -FtpDirectoryPath (Join-Path "Build" $version)
        Put-FtpFile -Server $SetupParameters.ftpServer -User $SetupParameters.ftpUser -Pass $SetupParameters.ftpPass -LocalFilePath $ALPath.FullName -FtpFilePath (Join-Path (Join-Path "Build" $version) $destFileName)
    }
}

