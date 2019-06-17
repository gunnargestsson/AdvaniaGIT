$version = Get-NavContainerNavVersion -containerOrImageName $BranchSettings.dockerContainerName
foreach ($ALPath in (Get-ALPaths -SetupParameters $SetupParameters)) {
    $app = ((Get-Content -Path (Join-Path $ALPath.FullName "app.json")) | ConvertFrom-Json)
    Write-Host "Extracting ${app.Name} as Runtime from $($ALPath.Fullname)..."
    $path = Get-Item -Path (Get-NavContainerAppRuntimePackage -containerName $BranchSettings.dockerContainerName -appName $app.name -Tenant default)  
    $destPath = Join-Path $Repository "Artifacts\$($app.publisher)_$($path.BaseName)_$($app.version)_runtime.app"
    Copy-Item -Path $path.FullName -Destination $destPath
}

