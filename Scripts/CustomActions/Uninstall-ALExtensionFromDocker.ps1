if ($SetupParameters.BuildMode) {
    $BranchWorkFolder = Join-Path $SetupParameters.rootPath "Log\$($SetupParameters.BranchId)"
}
$app = ((Get-Content -Path (Join-Path $ALPath.FullName "app.json")) | ConvertFrom-Json)
UnPublish-NavContainerApp -containerName $BranchSettings.dockerContainerName -appName $app.Name -unInstall -doNotSaveData -force -publisher $app.Publisher -version $app.Version -tenant default 

    