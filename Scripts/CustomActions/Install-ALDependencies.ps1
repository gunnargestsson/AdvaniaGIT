if ([String]::IsNullOrEmpty($SetupParameters.dependenciesOrder)) {
    Write-Host "Installing in Last Write Time order"
    $Apps = Get-ChildItem -Path (Join-Path $SetupParameters.repository "Dependencies") -Filter "*.app" | Sort-Object -Property LastWriteTime -Descending
} else {
    Write-Host "Installing in $($SetupParameters.dependenciesOrder) order"
    $Apps = Get-ChildItem -Path (Join-Path $SetupParameters.repository "Dependencies") -Filter "*.app" | Sort-Object -Property $SetupParameters.dependenciesOrder     
}
foreach ($app in $Apps) {
    Publish-NavContainerApp -containerName $BranchSettings.dockerContainerName -appFile $app.FullName -skipVerification -sync -install 
}
Remove-Item -Path (Join-Path $SetupParameters.repository "Dependencies\*.*") -Recurse -ErrorAction SilentlyContinue
   
