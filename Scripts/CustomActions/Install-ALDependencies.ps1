$Apps = Get-ChildItem -Path (Join-Path $SetupParameters.repository "Dependencies") -Filter "*.app"
$AppsToInstall = @{}
foreach ($app in $Apps) {
    $AppJson = Get-NavContainerAppInfoFile -ContainerName $BranchSettings.dockerContainerName -AppPath $app.FullName
    $AppJson | Add-Member -MemberType NoteProperty -Name "AppPath" -Value $app.FullName
    $AppsToInstall.Add($AppJson.Name,$AppJson)   
}

foreach ($app in (Get-ALBuildOrder -Apps $AppsToInstall)) {
    if (Test-Path $app.AppPath) {
        Write-Host "Publishing App from $($app.AppPath)..."
        Publish-NavContainerApp -containerName $BranchSettings.dockerContainerName -appFile $app.AppPath -skipVerification -sync -install 
    }
}

Remove-Item -Path (Join-Path $SetupParameters.repository "Dependencies\*.*") -Recurse -ErrorAction SilentlyContinue
   

