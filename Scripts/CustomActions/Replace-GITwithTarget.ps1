Check-GitNotUnattached

if ($BranchSettings.dockerContainerId -gt "") {
    $SetupParameters.navIdePath = Copy-DockerNAVClient -SetupParameters $SetupParameters -BranchSettings $BranchSettings
}

Load-ModelTools -SetupParameters $SetupParameters
$ObjectFileName = (Join-Path $SetupParameters.workFolder 'Target.txt')

if (!(Test-Path $SetupParameters.ObjectsPath)) {
  New-Item -Path $SetupParameters.ObjectsPath -ItemType Directory -ErrorAction SilentlyContinue | Out-Null
}

if (Test-Path $ObjectFileName) {
    Write-Host -Object "Deleting TXT files from Objects folder..."
    Remove-Item -Path (Join-Path $SetupParameters.ObjectsPath '*.*') -Force -ErrorAction SilentlyContinue 
    Write-Host -Object "Copying files from $ObjectFileName ..."   
    Split-NAVApplicationObjectFile -Source $ObjectFileName -Destination $SetupParameters.ObjectsPath -Force
}
else
{
    Write-Error $ObjectFileName "not found!" -ErrorAction Stop
}
UnLoad-ModelTools
