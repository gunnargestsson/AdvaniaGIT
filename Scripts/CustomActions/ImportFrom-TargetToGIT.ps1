Check-GitNotUnattached

Load-ModelTools -SetupParameters $SetupParameters
$ObjectFileName = (Join-Path $workFolder 'Target.txt')

if (Test-Path $ObjectFileName)
{
    Split-NAVApplicationObjectFile -Source $ObjectFileName -Destination $ObjectsPath -Force
}
else
{
    Write-Error $ObjectFileName "not found!" -ErrorAction Stop
}
