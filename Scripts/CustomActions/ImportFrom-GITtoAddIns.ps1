Check-NAVServiceRunning -SetupParameters $SetupParameters -BranchSettings $BranchSettings 
if ($BranchSettings.dockerContainerId -gt "") {
    $SetupParameters.navIdePath = Copy-DockerNAVClient -SetupParameters $SetupParameters -BranchSettings $BranchSettings
}

$AddInsDestPath = Join-Path $SetupParameters.navIdePath "Add-ins"
$AddInsSrcPath = Join-Path $SetupParameters.repository "Add-ins"

if (Test-Path -Path $AddInsSrcPath) {
    Copy-Item -Path (Join-Path $AddInsSrcPath "*.*") -Destination $AddInsDestPath -Recurse
}

