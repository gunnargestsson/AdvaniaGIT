if ($SetupParameters.storeAllObjects -eq "false" -or $SetupParameters.storeAllObjects -eq $false) {
    Write-Host -ForegroundColor Red "This action does not support branches not storing all objects!"
    $anyKey = Read-Host "Press enter to continue..."
    break
}

if ($BranchSettings.dockerContainerId -gt "") {
    $SetupParameters.navIdePath = Copy-DockerNAVClient -SetupParameters $SetupParameters -BranchSettings $BranchSettings
}

Load-ModelTools -SetupParameters $SetupParameters
$ObjectFileName = (Join-Path $SetupParameters.workFolder 'Modified.txt')
if (Test-Path $ObjectFileName)
{
    Remove-Item -Path $ObjectFileName  -Force
}
Join-NAVApplicationObjectFile -Source (Join-Path $SetupParameters.NewSyntaxObjectsPath '*.txt') -Destination $ObjectFileName -Force
UnLoad-ModelTools
