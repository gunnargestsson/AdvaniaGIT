Check-NAVServiceRunning -SetupParameters $SetupParameters -BranchSettings $BranchSettings 
if ($BranchSettings.dockerContainerId -gt "") {
    $SetupParameters.navIdePath = Copy-DockerNAVClient -SetupParameters $SetupParameters -BranchSettings $BranchSettings
}

$AddInsSrcPath = Join-Path $SetupParameters.repository "Add-ins"

if (Test-Path -Path $AddInsSrcPath) {
    Copy-Item -Path $AddInsSrcPath -Destination $SetupParameters.navIdePath -Recurse -Force
}

