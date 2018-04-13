Check-NAVServiceRunning -SetupParameters $SetupParameters -BranchSettings $BranchSettings

if ($BranchSettings.dockerContainerId -gt "") {
    $SetupParameters.navIdePath = Copy-DockerNAVClient -SetupParameters $SetupParameters -BranchSettings $BranchSettings
}

Write-Host "Updating database symbol references..."
Invoke-NAVDatabaseConversion -SetupParameters $SetupParameters -BranchSettings $BranchSettings



