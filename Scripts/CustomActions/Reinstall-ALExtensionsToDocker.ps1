if ($SetupParameters.BuildMode) {
    $BranchWorkFolder = Join-Path $SetupParameters.rootPath "Log\$($SetupParameters.BranchId)"
}
$Apps = Get-ChildItem -Path (Join-Path $BranchWorkFolder "out") -Filter "*.app" 
foreach ($app in $Apps | Sort-Object -Property LastWriteTime) {
    Publish-NavContainerApp -containerName $BranchSettings.dockerContainerName -appFile $app.FullName -skipVerification -sync -install -syncMode Clean
}
     
