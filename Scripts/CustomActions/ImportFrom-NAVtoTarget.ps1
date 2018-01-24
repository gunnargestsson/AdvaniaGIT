Check-GitNotUnattached
Check-NAVServiceRunning -SetupParameters $SetupParameters -BranchSettings $BranchSettings 

if ($BranchSettings.dockerContainerId -gt "") {
    $SetupParameters.navIdePath = Copy-DockerNAVClient -SetupParameters $SetupParameters -BranchSettings $BranchSettings
}

$ExportPath = Join-Path $SetupParameters.WorkFolder 'Target.txt'
Remove-Item -Path $ExportPath -Force -ErrorAction SilentlyContinue
Write-Host -Object 'Exporting all files...'
Export-NAVApplicationGITObject -SetupParameters $SetupParameters -BranchSettings $BranchSettings -ExportTxtSkipUnlicensed -Path $ExportPath -Filter 'Compiled=0|1' 
