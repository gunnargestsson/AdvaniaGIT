if ($BranchSettings.dockerContainerId -gt "") {
    $SetupParameters.navIdePath = Copy-DockerNAVClient -SetupParameters $SetupParameters -BranchSettings $BranchSettings
}

Write-Host "Updating database symbol references..."
Invoke-NAVDatabaseSymbolReferenceUpdate -SetupParameters $SetupParameters -BranchSettings $BranchSettings
