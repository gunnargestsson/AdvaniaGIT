if ($SetupParameters.BuildMode) {
    $version = Get-NavContainerNavVersion -containerOrImageName $BranchSettings.dockerContainerName
    $dependencyPath = Join-Path $SetupParameters.repository "Dependencies"
    Remove-Item -Path $dependencyPath -Recurse -Force -ErrorAction SilentlyContinue
    New-Item -Path $dependencyPath -ItemType Directory -ErrorAction SilentlyContinue | Out-Null
    $includedApps = @()

    foreach ($ALPath in (Get-ALPaths -SetupParameters $SetupParameters)) {
        $ALProjectFolder = $ALPath.FullName
        $ExtensionAppJsonFile = Join-Path $ALProjectFolder 'app.json'
        $ExtensionAppJsonObject = Get-Content -Raw -Path $ExtensionAppJsonFile | ConvertFrom-Json
        $includedApps += $ExtensionAppJsonObject.id
        foreach ($dependency in $ExtensionAppJsonObject.Dependencies) {
            $DependencyAppName = "$($dependency.publisher) $($dependency.name)".Replace(" ","_") + ".app"
            if ($includedApps.Contains($dependency.appId)) {
                Write-Host "${DependencyAppName} included in build..."
            } else {         
                if (Test-Path -Path (Join-Path $dependencyPath $DependencyAppName)) {
                    Write-Host "${DependencyAppName} already downloaded..."
                } else {
                    $DependencyAppPath = "build/${version}/" + $DependencyAppName;
                    Write-Host "Trying to download ${DependencyAppPath} from FTP Server..."
                    Get-FtpFile -Server $SetupParameters.ftpServer -User $SetupParameters.ftpUser -Pass $SetupParameters.ftpPass -FtpFilePath $DependencyAppPath -LocalFilePath (Join-Path $dependencyPath $DependencyAppName)
                }
            }
        }
    }    
}
