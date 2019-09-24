if ($BranchSettings.dockerContainerName -eq "") {
    Write-Host -ForegroundColor Red "Symbols required Docker Container!"
    throw
}

if ($SetupParameters.BuildMode) {
    $BranchWorkFolder = Join-Path $SetupParameters.rootPath "Log\$($SetupParameters.BranchId)"
    New-Item -Path $BranchWorkFolder -ItemType Directory -Force -ErrorAction SilentlyContinue | Out-Null
    New-Item -Path (Join-Path $BranchWorkFolder 'Symbols') -ItemType Directory -Force -ErrorAction SilentlyContinue | Out-Null        
    $baseUrl = "http://$($BranchSettings.dockerContainerName):$($BranchSettings.developerServicesPort)/$($BranchSettings.instanceName)/dev/packages"
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
                    $appUrl = $baseUrl + "?publisher=$($dependency.publisher)&appName=$($dependency.name)&versionText=$($dependency.version)"
                    Write-Host "Downloading App from $appUrl..."
                    Invoke-RestMethod -Method Get -Uri ($appUrl) -OutFile (Join-Path $SetupParameters.LogPath $DependencyAppName) -UseDefaultCredentials
                    Move-Item -Path (Join-Path $SetupParameters.LogPath $DependencyAppName) -Destination (Join-Path $BranchWorkFolder 'Symbols') -Force -ErrorAction SilentlyContinue
                }
            }
        }
    }                 
}
