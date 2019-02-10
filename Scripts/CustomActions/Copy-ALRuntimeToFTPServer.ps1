$version = Get-NavContainerNavVersion -containerOrImageName $BranchSettings.dockerContainerName
foreach ($ALPath in (Get-ALPaths -SetupParameters $SetupParameters)) {
    $appName = ((Get-Content -Path (Join-Path $ALPath.FullName "app.json")) | ConvertFrom-Json).name
    Write-Host "Extracting ${appName} as Runtime from $($ALPath.Fullname)..."
    $path = Get-Item -Path (Get-NavContainerAppRuntimePackage -containerName $BranchSettings.dockerContainerName -appName $appName -Tenant default)
    Write-Host "Upload Results to $($SetupParameters.ftpServer)..."
    Create-FtpDirectory -Server $SetupParameters.ftpServer -User $SetupParameters.ftpUser -Pass $SetupParameters.ftpPass -FtpDirectoryPath "Runtime"
    Create-FtpDirectory -Server $SetupParameters.ftpServer -User $SetupParameters.ftpUser -Pass $SetupParameters.ftpPass -FtpDirectoryPath (Join-Path "Runtime" $version)
    Put-FtpFile -Server $SetupParameters.ftpServer -User $SetupParameters.ftpUser -Pass $SetupParameters.ftpPass -LocalFilePath $path.FullName -FtpFilePath (Join-Path (Join-Path "Runtime" $version) $path.Name)
    Remove-Item -Path $path.FullName -ErrorAction SilentlyContinue


}

