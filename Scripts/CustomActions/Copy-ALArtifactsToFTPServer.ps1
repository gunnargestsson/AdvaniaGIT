if ($SetupParameters.BuildMode) {
    $version = Get-NavContainerNavVersion -containerOrImageName $BranchSettings.dockerContainerName
    foreach ($ALPath in (Get-ChildItem -Path (Join-Path $SetupParameters.repository 'Artifacts'))) { 
        $destFileName = ($ALPath.Name).Split(".")[0]
        $destFileName = $destFileName.Substring(0,$destFileName.Length - 3) + ".app"

        Write-Host "Uploading ${destFileName} to FTP Server..."
        Create-FtpDirectory -Server $SetupParameters.ftpServer -User $SetupParameters.ftpUser -Pass $SetupParameters.ftpPass -FtpDirectoryPath "Build"
        Create-FtpDirectory -Server $SetupParameters.ftpServer -User $SetupParameters.ftpUser -Pass $SetupParameters.ftpPass -FtpDirectoryPath (Join-Path "Build" $version)
        Put-FtpFile -Server $SetupParameters.ftpServer -User $SetupParameters.ftpUser -Pass $SetupParameters.ftpPass -LocalFilePath $ALPath.FullName -FtpFilePath (Join-Path (Join-Path "Build" $version) $destFileName)
    }
}

