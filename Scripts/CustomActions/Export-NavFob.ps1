Check-NAVServiceRunning -SetupParameters $SetupParameters -BranchSettings $BranchSettings

if ($BranchSettings.dockerContainerId -gt "") {
    $SetupParameters.navIdePath = Copy-DockerNAVClient -SetupParameters $SetupParameters -BranchSettings $BranchSettings
}
$ObjectFileName = (Join-Path $SetupParameters.workFolder "$($SetupParameters.navRelease)-$($SetupParameters.projectName).fob")

Write-Host -Object 'Exporting all objects...'            
Export-NAVApplicationGITObject -SetupParameters $SetupParameters -BranchSettings $BranchSettings -Path $ObjectFileName -Filter 'Compiled=0|1' 
Write-Host -Object "Export to $($ObjectFileName) completed"
