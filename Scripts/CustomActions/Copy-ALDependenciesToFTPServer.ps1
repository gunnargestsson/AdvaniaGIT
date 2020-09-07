if ($SetupParameters.BuildMode) {
    $version = [String]::Join('.',((Get-NavContainerNavVersion -containerOrImageName $BranchSettings.dockerContainerName).split('.')[0,1]))
    foreach ($ALPath in (Get-ChildItem -Path (Join-Path $SetupParameters.repository 'Dependencies'))) { 
        $destFileName = ($ALPath.Name).Split(".")[0]
        $destFileName = $destFileName.Substring(0,$destFileName.Length - 3) + ".app"
        $fullDestFileName = [String]::Join('.',(($ALPath.Name).Split(".")[0,1])) + "_BC${version}" + ".app"

        Write-Host "Uploading ${destFileName} to $($SetupParameters.ftpServer)..."
        Create-FtpDirectory -Server $SetupParameters.ftpServer -User $SetupParameters.ftpUser -Pass $SetupParameters.ftpPass -FtpDirectoryPath "Build"
        Create-FtpDirectory -Server $SetupParameters.ftpServer -User $SetupParameters.ftpUser -Pass $SetupParameters.ftpPass -FtpDirectoryPath (Join-Path "Build" $version)
        Create-FtpDirectory -Server $SetupParameters.ftpServer -User $SetupParameters.ftpUser -Pass $SetupParameters.ftpPass -FtpDirectoryPath (Join-Path (Join-Path "Build" $version) "latest")
        Put-FtpFile -Server $SetupParameters.ftpServer -User $SetupParameters.ftpUser -Pass $SetupParameters.ftpPass -LocalFilePath $ALPath.FullName -FtpFilePath (Join-Path (Join-Path "Build" $version) $fullDestFileName)
        Put-FtpFile -Server $SetupParameters.ftpServer -User $SetupParameters.ftpUser -Pass $SetupParameters.ftpPass -LocalFilePath $ALPath.FullName -FtpFilePath (Join-Path (Join-Path (Join-Path "Build" $version) "latest") $destFileName)
    }
}

