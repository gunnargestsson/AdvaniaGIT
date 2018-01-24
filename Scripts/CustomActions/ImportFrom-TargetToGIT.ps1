Check-GitNotUnattached

if ($BranchSettings.dockerContainerId -gt "") {
    $SetupParameters.navIdePath = Copy-DockerNAVClient -SetupParameters $SetupParameters -BranchSettings $BranchSettings
}

Load-ModelTools -SetupParameters $SetupParameters
$ObjectFileName = (Join-Path $SetupParameters.workFolder 'Target.txt')

if (Test-Path $ObjectFileName)
{
    Split-NAVApplicationObjectFile -Source $ObjectFileName -Destination $SetupParameters.ObjectsPath -Force
}
else
{
    Write-Error $ObjectFileName "not found!" -ErrorAction Stop
}
