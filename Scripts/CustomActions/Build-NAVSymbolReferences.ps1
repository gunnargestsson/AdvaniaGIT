Check-NAVServiceRunning -SetupParameters $SetupParameters -BranchSettings $BranchSettings

if ($BranchSettings.dockerContainerId -gt "") {
    $SetupParameters.navIdePath = Copy-DockerNAVClient -SetupParameters $SetupParameters -BranchSettings $BranchSettings
}

if ($SetupParameters.BuildMode) {
    Write-Host "symbol reference already enabled on service"
} else {
    Write-Host "Enabling server instance symbol reference update..."
    & (Join-path $PSScriptRoot 'Start-ALSymbolReferenceGenerationOnServer')
}
Write-Host "Updating database symbol references..."
Invoke-NAVDatabaseSymbolReferenceUpdate -SetupParameters $SetupParameters -BranchSettings $BranchSettings
