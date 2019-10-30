if ([String]::IsNullOrEmpty($SetupParameters.dependenciesOrder)) {
    $Apps = Get-ChildItem -Path (Join-Path $SetupParameters.repository "Dependencies") -Filter "*.app" | Sort-Object -Property LastWriteTime
} else {
    $Apps = Get-ChildItem -Path (Join-Path $SetupParameters.repository "Dependencies") -Filter "*.app" | Sort-Object -Property $SetupParameters.dependenciesOrder    
}
foreach ($app in $Apps | Sort-Object -Property LastWriteTime) {
    Publish-NavContainerApp -containerName $BranchSettings.dockerContainerName -appFile $app.FullName -skipVerification -sync -install 
}
Remove-Item -Path (Join-Path $SetupParameters.repository "Dependencies\*.*") -Recurse -ErrorAction SilentlyContinue
   
