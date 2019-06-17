if ($SetupParameters.BuildMode) {
    $BranchWorkFolder = Join-Path $SetupParameters.rootPath "Log\$($SetupParameters.BranchId)"
}
foreach ($ALPath in (Get-ALPaths -SetupParameters $SetupParameters)) {
    $app = ((Get-Content -Path (Join-Path $ALPath.FullName "app.json")) | ConvertFrom-Json)
    UnPublish-NavContainerApp -containerName $BranchSettings.dockerContainerName -appName $app.Name -unInstall -doNotSaveData -force -publisher $app.Publisher -version $app.Version -tenant default 
}
    