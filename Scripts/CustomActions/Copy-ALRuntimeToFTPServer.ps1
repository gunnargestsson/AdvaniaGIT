$version = [String]::Join('.',((Get-NavContainerNavVersion -containerOrImageName $BranchSettings.dockerContainerName).split('.')[0,1]))
if (![String]::IsNullOrEmpty($SetupParameters.Publisher)) {
    $ALApps = Get-NavContainerAppInfo -containerName $BranchSettings.dockerContainerName | Where-Object -Property Publisher -EQ $SetupParameters.Publisher
    $appNameFromAppJson = $false
} else {
    $ALApps = (Get-ALPaths -SetupParameters $SetupParameters)
    $appNameFromAppJson = $true
}
        
foreach ($AlApp in $ALApps) {
    if ($appNameFromAppJson) {
        $AlApp = Get-NavContainerAppInfo -containerName $BranchSettings.dockerContainerName | Where-Object -Property Name -EQ ((Get-Content -Path (Join-Path $AlApp.FullName "app.json")) | ConvertFrom-Json).name
    }
    if ($AlApp) {
        Write-Host "Extracting $($AlApp.name) as Runtime..."
        $path = Get-Item -Path (Get-NavContainerAppRuntimePackage -containerName $BranchSettings.dockerContainerName -appName $AlApp.name -Tenant default)
        if (Test-Path $SetupParameters.SigToolExecutable) {
            if (Test-Path $SetupParameters.CodeSigningCertificate) {
                Write-Host "Signing APP package ${path}..."
                & $($SetupParameters.SigToolExecutable) sign /t http://timestamp.verisign.com/scripts/timestamp.dll /f "$($SetupParameters.CodeSigningCertificate)" /p "$($SetupParameters.CodeSigningCertificatePassword)" "${path}"
            }
            else
            {
                Write-Host -ForegroundColor Red "Code Signing Certificate not configured in GITSettings.json!"
            }    
        }
        
        $destFileName = $path.Name
        $fullDestFileName = $path.BaseName + '_' + $AlApp.version + '.app'

        Write-Host "Upload ${destFileName} to $($SetupParameters.ftpServer)..."
        Create-FtpDirectory -Server $SetupParameters.ftpServer -User $SetupParameters.ftpUser -Pass $SetupParameters.ftpPass -FtpDirectoryPath "Runtime"
        Create-FtpDirectory -Server $SetupParameters.ftpServer -User $SetupParameters.ftpUser -Pass $SetupParameters.ftpPass -FtpDirectoryPath (Join-Path "Runtime" $version)
        Create-FtpDirectory -Server $SetupParameters.ftpServer -User $SetupParameters.ftpUser -Pass $SetupParameters.ftpPass -FtpDirectoryPath (Join-Path (Join-Path "Runtime" $version) "latest")
        Put-FtpFile -Server $SetupParameters.ftpServer -User $SetupParameters.ftpUser -Pass $SetupParameters.ftpPass -LocalFilePath $path.FullName -FtpFilePath (Join-Path (Join-Path "Runtime" $version) $fullDestFileName)
        Put-FtpFile -Server $SetupParameters.ftpServer -User $SetupParameters.ftpUser -Pass $SetupParameters.ftpPass -LocalFilePath $path.FullName -FtpFilePath (Join-Path (Join-Path (Join-Path "Runtime" $version) "latest") $destFileName)

        Remove-Item -Path $path.FullName -ErrorAction SilentlyContinue
    }
}


