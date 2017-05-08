Check-GitNotUnattached

Load-ModelTools -SetupParameters $SetupParameters
$ObjectFileName = (Join-Path $workFolder 'Target.txt')

if (!(Test-Path $ObjectsPath)) {
  New-Item -Path $ObjectsPath -ItemType Directory -ErrorAction SilentlyContinue | Out-Null
}

if (Test-Path $ObjectFileName) {
    Write-Host -Object "Deleting TXT files from Objects folder..."
    Remove-Item -Path (Join-Path $ObjectsPath '*.*') -Force -ErrorAction SilentlyContinue 
    Write-Host -Object "Copying files from $ObjectFileName ..."   
    Split-NAVApplicationObjectFile -Source $ObjectFileName -Destination $ObjectsPath -Force
}
else
{
    Write-Error $ObjectFileName "not found!" -ErrorAction Stop
}
UnLoad-ModelTools
